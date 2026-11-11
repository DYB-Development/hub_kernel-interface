# Changelog

## [Unreleased]

### Added
- `HubKernel::Authz.caller_kind`, where a host answers `:client` or `:staff` for the person and the account a call is made as.
- `exposes` takes an optional `for_clients: true` that marks a method for clients, read back with `exposure.for_clients`.
- A client caller is listed and may call only the methods marked for clients, a staff caller only the methods not marked, and a host that sets no caller kind has every method listed and served as in 0.11.0.
- A client caller who calls a method not marked for clients is refused with `HubKernel::NotAllowed`, and `allows?` answers `false` for a method the caller's kind may not reach.
- A caller kind that answers anything but `:client` or `:staff` raises `HubKernel::UnknownCallerKindError`.
- `HubKernel::Authz.caller_organization`, where a host names the organization a caller belongs to from the person and the account a call is made as.
- `exposes` takes an optional `organization:` naming the value a method is given the caller's organization in, read back with `exposure.organization` and never listed in `exposure.takes`.
- A call that sends a method's organization value is refused with `HubKernel::Refused`, and a caller the host names no organization for is refused with `HubKernel::NotAllowed` before the method runs.
- The exposure check passes a method that requires its organization value without listing it in `takes:`.

## [0.11.0] - 2026-11-03

### Added
- A hub method called by name reads the person who made the call with `HubKernel::Context.person`, which gives `nil` outside a call.
- An account scope that declares a `person:` keyword is given the calling person as well as the account, and a scope that takes only the account keeps working.

## [0.10.0] - 2026-10-29

### Added
- `exposes` takes an optional `earlier_answers:` hash that maps an older major version's number to a translation from the answer of the major after it, read back with `exposure.earlier_answers` and `exposure.earlier_answer(major)`.
- `exposes` takes an optional `answer_shape:` with the JSON Schema of the method's answer, read back with `exposure.answer_shape`.
- An earlier answer may be given as `{ translation:, answer_shape: }` to carry the JSON Schema of the answer at that major, read back with `earlier_answer.answer_shape`.

## [0.9.0] - 2026-10-14

### Added
- With no served list set, `HubKernel::Interface.hubs` is every hub that exposes a method, each served at its own name, and setting it to `nil` restores that default.
- `HubKernel::Interface.person_method` and `HubKernel::Interface.account_method`, where a host names the methods that give the calling person and account once for every interface gem.

## [0.8.0] - 2026-10-07

### Added
- Loading hub_kernel-interface beside a hub_kernel release older than 0.19.0 raises `HubKernel::Interface::OlderHubKernelError`, naming the hub_kernel release to upgrade to.

## [0.7.0] - 2026-10-07

### Added
- hub_kernel-interface is a the_local provider: installing it gives an app or gem its info, install and develop agents.

## [0.6.0] - 2026-10-06

### Added
- `allows?`, which asks the permission check about one exposed method.

### Fixed
- `CallReasons.refuse_unlisted_values` asks the permission check nothing for a call that sends only listed values, and once about the called method otherwise, rather than about every exposed method on every call.

## [0.5.0] - 2026-10-06

### Added
- `HubKernel::Interface::CallReasons`, which refuses a call's unlisted values after the permission check and describes a missing record by its kind and id.

## [0.4.0] - 2026-10-06

### Added
- `HubKernel::Interface.check!`, which raises `HubKernel::Interface::UnservableHubError` naming every problem in the served list.

## [0.3.0] - 2026-10-06

### Added
- `HubKernel::Interface.served`, every served name with the hub served at it.

## [0.2.0] - 2026-10-06

### Added
- `HubKernel::Interface.hubs`, the one list of hubs a host serves over every interface, and `HubKernel::Interface.find`, which returns the hub served at a name.

## [0.1.0] - 2026-10-06

### Added
- `HubKernel::Exposes`, `HubKernel::Authz`, `HubKernel::Context` and the errors they raise, under the names hub_kernel uses for them.
- `HubKernel::Interface::ExposingHubs`, a record of every hub that declares an exposed method.
