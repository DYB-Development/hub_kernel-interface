# hub_kernel-interface

The exposed-method contract every hub_kernel interface gem builds on: what a hub exposes, who
may call it, and calling it in an account's scope. An interface gem, such as a JSON API or an
MCP server, depends on this gem alone rather than on all of hub_kernel.

## Usage

A hub lists the methods outside callers may reach by name, the values each takes, and whether
it writes:

```ruby
module Supplies
  extend HubKernel::Exposes

  exposes :price_of, takes: %i[item], writes: false

  def self.price_of(item:) = "#{item} costs 3"
end
```

The host sets the permission check, asked with the person, `hub:method` and the account, and
the account scope, wrapped around every call:

```ruby
HubKernel::Authz.check = ->(person, action, account) { true }
HubKernel::Context.scope = ->(account, &call) { call.call }
```

An interface gem lists the methods a person may call on an account, and calls one by name:

```ruby
Supplies.exposures_for(person: person, account: account)
Supplies.call_exposed("price_of", values: { item: "soap" }, person: person, account: account)
```

A call is refused with `HubKernel::UnexposedMethodError` for a name the hub does not expose,
`HubKernel::NotAllowed` when the permission check refuses, and `HubKernel::MissingArgumentError`
for a missing person, account or required value. A hub refuses with `HubKernel::Refused` and a
reason a person can read. A call made while the permission check or the account scope is unset
raises `HubKernel::UnwiredPortError`.

The host names the hubs every interface serves, once. A hub listed alone is served at its
module name in snake case, and a hub listed as a one-pair hash is served only at the name
given. An interface gem finds the hub served at a name, or `nil` when none is:

```ruby
HubKernel::Interface.hubs = [ Supplies, { "money" => Billing::Ledger } ]

HubKernel::Interface.find("supplies") # => Supplies
HubKernel::Interface.find("money")    # => Billing::Ledger
HubKernel::Interface.served           # => { "supplies" => Supplies, "money" => Billing::Ledger }
```

The permission check is still asked about a hub served under a chosen name by its own name,
such as `ledger:record_spend`.

`Supplies.exposure_problems` names each exposed method the hub has no method for, or lists
with values it does not take. `HubKernel::Interface::ExposingHubs.list` holds every hub that
declares an exposed method.

## Installation

```ruby
gem "hub_kernel-interface"
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
