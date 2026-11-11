require "active_support/core_ext/string/inflections"
require "hub_kernel/authz"
require "hub_kernel/context"
require "hub_kernel/interface/exposing_hubs"

module HubKernel
  class MissingArgumentError < ArgumentError; end
  class UnwiredPortError < StandardError; end
  class NonBooleanAnswerError < StandardError; end
  class UnknownCallerKindError < StandardError; end
  class UnexposedMethodError < StandardError; end
  class NotAllowed < StandardError; end
  class Refused < StandardError; end

  module Exposes
    Exposed = Data.define(:name, :takes, :writes, :earlier_answers, :answer_shape, :for_clients, :organization) do
      def earlier_answer(major) = earlier_answers.find { |earlier| earlier.major == major }
    end
    EarlierAnswer = Data.define(:major, :translation, :answer_shape) do
      def translate(answer) = translation.call(answer)
    end

    def exposes(name, takes:, writes:, earlier_answers: {}, answer_shape: nil, for_clients: false, organization: nil)
      Interface::ExposingHubs.add(self)
      exposed_methods[name.to_s] = Exposed.new(name: name, takes: takes - [ organization ], writes: writes, earlier_answers: earlier_answers.map { |major, declared| earlier_answer_from(major, declared) }, answer_shape: answer_shape, for_clients: for_clients, organization: organization)
    end

    def exposed(name) = exposed_methods[name.to_s]

    def exposures = exposed_methods.values

    def exposures_for(person:, account:)
      refuse_without_caller(person, account)

      kind = caller_kind(person, account)
      exposures.select { |exposure| reachable?(exposure, kind) && allowed?(exposure, person, account) }
    end

    def allows?(name, person:, account:)
      refuse_without_caller(person, account)

      callable?(exposed(name), person, account)
    end

    def call_exposed(name, values:, person:, account:)
      refuse_without_caller(person, account)

      exposure = exposed(name) || raise(UnexposedMethodError, "#{exposing_hub} does not expose #{name}")
      refuse_unless_allowed(exposure, person, account)
      refuse_sent_organization(exposure, values)
      refuse_missing_values(exposure, values)
      organization = organization_value(exposure, person, account)
      Context.with_person(person) { within_account(account, person) { public_send(exposure.name, **values.slice(*exposure.takes), **organization) } }
    end

    def exposure_problems
      exposed_methods.values.filter_map { |exposure| exposure_problem(exposure) }
    end

    private

    def exposed_methods = @exposed_methods ||= {}

    def exposing_hub = name.demodulize

    def earlier_answer_from(major, declared)
      return EarlierAnswer.new(major: major, translation: declared, answer_shape: nil) if declared.respond_to?(:call)

      EarlierAnswer.new(major: major, translation: declared[:translation], answer_shape: declared[:answer_shape])
    end

    def refuse_without_caller(person, account)
      raise MissingArgumentError, "A call by name needs a person" if person.nil?
      raise MissingArgumentError, "A call by name needs an account" if account.nil?
    end

    def refuse_unless_allowed(exposure, person, account)
      raise NotAllowed, "#{exposing_hub} #{exposure.name}" unless callable?(exposure, person, account)
    end

    def callable?(exposure, person, account) = reachable?(exposure, caller_kind(person, account)) && allowed?(exposure, person, account)

    def caller_kind(person, account)
      return unless Authz.caller_kind

      kind = Authz.caller_kind.call(person, account)
      raise UnknownCallerKindError, "The caller kind must answer :client or :staff, got #{kind.inspect}" unless %i[client staff].include?(kind)

      kind
    end

    def reachable?(exposure, kind) = kind.nil? || (kind == :client) == exposure.for_clients

    def allowed?(exposure, person, account)
      raise UnwiredPortError, "hub_kernel's permission check is not filled" unless Authz.check

      answer = Authz.check.call(person, "#{exposing_hub.underscore}:#{exposure.name}", account)
      raise NonBooleanAnswerError, "The permission check must answer true or false, got #{answer.inspect}" unless [ true, false ].include?(answer)

      answer
    end

    def within_account(account, person, &call)
      raise UnwiredPortError, "hub_kernel's account scope is not filled" unless Context.scope
      return Context.scope.call(account, person: person, &call) if scope_takes_person?

      Context.scope.call(account, &call)
    end

    def scope_takes_person? = (Context.scope.respond_to?(:parameters) ? Context.scope : Context.scope.method(:call)).parameters.any? { |kind, name| %i[key keyreq].include?(kind) && name == :person }

    def refuse_sent_organization(exposure, values)
      raise Refused, "#{exposure.name} does not take #{exposure.organization}" if exposure.organization && values.key?(exposure.organization)
    end

    def organization_value(exposure, person, account)
      return {} unless exposure.organization

      organization = Authz.caller_organization.call(person, account)
      raise NotAllowed, "#{exposing_hub} #{exposure.name}" if organization.nil?

      { exposure.organization => organization }
    end

    def refuse_missing_values(exposure, values)
      missing = keywords(exposure, :keyreq) - values.keys - [ exposure.organization ]
      raise MissingArgumentError, "Give #{missing.join(", ")}" if missing.any?
    end

    def exposure_problem(exposure)
      return "#{exposing_hub} exposes #{exposure.name}, which it has no method for" unless respond_to?(exposure.name)
      return if takes_listed_values?(exposure)

      "#{exposing_hub} exposes #{exposure.name} with #{exposure.takes.join(", ")}, but it takes #{keywords(exposure, :keyreq, :key).join(", ")}"
    end

    def takes_listed_values?(exposure)
      (keywords(exposure, :keyreq) - exposure.takes - [ exposure.organization ]).empty? && (takes_any_values?(exposure) || (exposure.takes - keywords(exposure, :keyreq, :key)).empty?)
    end

    def takes_any_values?(exposure) = method(exposure.name).parameters.any? { |kind, _| kind == :keyrest }

    def keywords(exposure, *kinds) = method(exposure.name).parameters.filter_map { |kind, value| value if kinds.include?(kind) }
  end
end
