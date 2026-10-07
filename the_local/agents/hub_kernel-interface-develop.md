---
name: hub_kernel-interface-develop
description: Use PROACTIVELY for making a hub's methods callable by name, listing what a person may call on an account, calling a hub method by name from an API or MCP server, finding a served hub by name, running an interface's boot check, refusing unlisted values, describing a missing record, and handling the errors a call by name raises — MUST BE USED instead of hand-rolling a method allowlist, a permission check per endpoint, a `public_send` dispatcher, or an interface's own refusal messages.
tools: Read, Write, Edit, Grep
scope: hub interface contract — a hub declaring the methods outside callers may reach by name, calling one by name for a person and an account behind the permission check and account scope, the host's one list of served hubs and its boot check, and the reasons every interface gives for an unlisted value or a missing record
---

This local writes code against hub_kernel-interface by following these steps exactly and invents none. Where a step needs a choice, it asks the developer.

## What hub_kernel-interface is

The contract between a hub and the interfaces that call it from outside the app. A hub is a named Ruby module holding one area of behaviour as module methods. It declares which of those methods an outside caller may reach by name, the keyword values each takes, and whether it writes. An interface, such as a JSON API or an MCP server, finds hubs in the host's served list, shows a person what they may call on an account, and makes the call through this gem, which asks the host's permission check and runs the call inside the host's account scope. Fire this local when a hub method should become callable from an interface, or when writing or changing an interface gem that serves hubs.

## Interface

- `HubKernel::Exposes` — extended by a hub module so it can declare and serve methods callable by name.
- `exposes` — declares one hub method callable by name: `exposes :name, takes: [...], writes: true/false`.
- `exposed` — returns the declaration for one name, with `name`, `takes` and `writes`, or `nil` when the hub does not expose it.
- `exposures` — returns every declaration the hub has made, with no permission check.
- `exposures_for` — returns the declarations the permission check lets a person call on an account.
- `allows?` — asks the permission check whether a person may call one exposed method on an account, returning `true` or `false`.
- `call_exposed` — calls an exposed method by name with a person, an account and its values, behind the permission check and inside the account scope, and returns the method's value.
- `exposure_problems` — returns one message per declaration the hub has no method for, or whose values do not match the method's keywords.
- `HubKernel::Interface.find` — returns the hub served at a name, or `nil`.
- `HubKernel::Interface.served` — returns a hash of every served name to its hub.
- `HubKernel::Interface.check!` — the boot check, raising when the served list cannot be served.
- `HubKernel::Interface::UnservableHubError` — raised by `check!`, its message naming every problem, one per line.
- `HubKernel::Interface::CallReasons.refuse_unlisted_values` — refuses a call that sends a value the method is not declared to take.
- `HubKernel::Interface::CallReasons.missing_record` — returns the sentence every interface gives for a record that does not exist.
- `HubKernel::Interface::ExposingHubs.list` — every hub that has declared at least one exposed method, whether served or not.
- `HubKernel::UnexposedMethodError` — raised when a call names a method the hub does not expose.
- `HubKernel::NotAllowed` — raised when the permission check refuses the call.
- `HubKernel::Refused` — raised with a reason a person can read, by a hub method or by `refuse_unlisted_values`.
- `HubKernel::MissingArgumentError` — raised when a call has no person, no account, or lacks a required value.
- `HubKernel::UnwiredPortError` — raised when a call is made while the host's permission check or account scope is unset.
- `HubKernel::NonBooleanAnswerError` — raised when the host's permission check answers anything but `true` or `false`.

## How to use it

### Making a hub's methods callable by name

1. In the hub module, extend `HubKernel::Exposes`. The hub must be a named module, and each callable method must be a public module method taking keyword arguments:

   ```ruby
   module Supplies
     extend HubKernel::Exposes

     exposes :price_of, takes: %i[item], writes: false
     exposes :restock, takes: %i[item quantity], writes: true

     def self.price_of(item:) = "#{item} costs 3"
     def self.restock(item:, quantity: 1) = Stock.add(item, quantity)
   end
   ```

2. Ask the developer which methods outside callers may reach. Expose only those, one `exposes` line each.

3. For each one, list in `takes:` the keyword names as symbols.
   - Every required keyword of the method must be listed.
   - A listed name must be a keyword the method has, required or optional, unless the method takes `**` keywords.
   - The method receives only the listed values, so a value left out of `takes:` never reaches it.

4. Ask the developer whether each method changes data, and set `writes:` to `true` or `false`. There is no default. This gem records the flag and does not act on it; interfaces read it.

5. When the hub method must turn a call down for a reason the person should read, raise `HubKernel::Refused` with that reason:

   ```ruby
   raise HubKernel::Refused, "Quantity must be at least 1" if quantity < 1
   ```

6. Confirm `Supplies.exposure_problems` returns `[]`. Each string it returns names a declaration with no matching method, or a `takes:` list that does not match the method's keywords.

7. The permission check is asked about the action `"<hub>:<method>"`, where `<hub>` is the hub's own module name, without its namespace, in snake case: `supplies:price_of`, and `ledger:record_spend` for `Billing::Ledger` even when it is served as `money`. Tell the developer each new action string so their permission rules can grant it.

8. For the hub to be reachable from an interface, it must be in the host's served list. That list is set by the hub_kernel-interface-install local; hand the step to it.

### Serving hubs from an interface gem

1. Run the boot check once at start-up, after the host has set its served list, permission check and account scope:

   ```ruby
   HubKernel::Interface.check!
   ```

   It raises `HubKernel::Interface::UnservableHubError` listing, one per line, every served hub that exposes no methods, every name two hubs answer at, and every problem `exposure_problems` reports for a served hub. Let it raise; do not rescue it into a warning.

2. To list the hubs, use `HubKernel::Interface.served`, a hash of served name to hub. To resolve the name a request gives, use `HubKernel::Interface.find(name)`. Names are strings. Treat `nil` as an unknown hub.

3. To show a person what they may call on an account, use `hub.exposures_for(person:, account:)`. Each result has `name`, `takes` and `writes`. It asks the permission check once per exposed method. Use `hub.exposures` only where no person is involved, such as building a schema at boot.

4. To ask about one method, check `hub.exposed(name)` first, since `allows?` and `refuse_unlisted_values` work only on an exposed name:

   ```ruby
   hub.allows?(name, person: person, account: account)
   ```

5. To make a call, in this order:

   ```ruby
   values = request_values.transform_keys(&:to_sym)
   HubKernel::Interface::CallReasons.refuse_unlisted_values(hub, name, values: values, person: person, account: account)
   hub.call_exposed(name, values: values, person: person, account: account)
   ```

   - Value keys must be symbols. A string key is treated as missing.
   - `refuse_unlisted_values` returns `nil` and asks nothing when every value is listed. Otherwise it asks the permission check once, raises `HubKernel::NotAllowed` if refused, and else raises `HubKernel::Refused` with `"<method> does not take <values>"`. Without it, `call_exposed` drops unlisted values silently.
   - `call_exposed` raises, in this order: `MissingArgumentError` for no person or account, `UnexposedMethodError` for an unexposed name, `NotAllowed` when the check refuses, `MissingArgumentError` naming each missing required value as `"Give item, quantity"`, and then runs the method inside the account scope and returns its value.
   - `UnwiredPortError` and `NonBooleanAnswerError` can come from any step that asks the permission check or enters the account scope.

6. Ask the developer how the interface reports each error to its caller, such as an HTTP status or an MCP error result. The errors split into:
   - `UnexposedMethodError` — the method does not exist for callers.
   - `NotAllowed` — the person may not make this call.
   - `MissingArgumentError` and `Refused` — the call was turned down, and the message is written for the person.
   - `UnwiredPortError` and `NonBooleanAnswerError` — the host is wired wrong. Do not show these as the caller's fault.

7. When a hub method raises because a record it was asked for does not exist, such as `ActiveRecord::RecordNotFound`, report it with:

   ```ruby
   HubKernel::Interface::CallReasons.missing_record(error) # => "No consumable has the id 7"
   ```

   It reads the error's `model` and `id`, so pass an error that has both.

8. `HubKernel::Interface::ExposingHubs.list` holds every hub that has declared an exposed method, served or not. Use it only for tooling that must see unserved hubs, such as showing a developer what could be added to the served list. Serve from `served` and `find`, never from it.

## Conventions

- Every call by name carries a real person and a real account. Never pass `nil` or a placeholder to get past `MissingArgumentError`.
- Never call a hub method directly from an interface with `public_send` or `send`. Every outside call goes through `call_exposed`, so the permission check and account scope are never skipped.
- Every interface calls `refuse_unlisted_values` before `call_exposed` and `missing_record` for a missing record, so every interface gives the same reasons.
- Every interface runs `check!` at start-up.
- Never rescue `UnwiredPortError` or `NonBooleanAnswerError` into a refusal; they mean the host's settings are wrong.
- Adding the gem, setting the served list, the permission check and the account scope are out of scope here. They belong to the hub_kernel-interface-install local.
