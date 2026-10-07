---
name: hub_kernel-interface-install
description: Use to hook hub_kernel-interface into a project — adding the gem, naming the hubs every interface serves, and filling the permission check and the account scope.
tools: Bash, Read, Edit
scope: hub interface contract — a hub declaring the methods outside callers may reach by name, calling one by name for a person and an account behind the permission check and account scope, the host's one list of served hubs and its boot check, and the reasons every interface gives for an unlisted value or a missing record
---

This local follows these steps exactly and invents none. Where a step needs a choice, it asks the developer.

## What hub_kernel-interface is

The contract between an app's hubs and the interfaces that call them from outside, such as a JSON API or an MCP server; hook it in when a Rails app wants its hubs callable by name, or when an interface gem is added that needs it.

## Interface

- `gem "hub_kernel-interface"` — adds the gem to the host's `Gemfile`.
- `HubKernel::Interface.hubs=` — sets the one list of hubs every interface serves, and the name each is served at.
- `HubKernel::Authz.check=` — sets the permission check every call by name is asked before it runs.
- `HubKernel::Context.scope=` — sets the account scope every call by name runs inside.

## How to use it

1. Add the gem to the host's `Gemfile` and run `bundle install`:

   ```ruby
   gem "hub_kernel-interface"
   ```

   It needs Ruby 3.2 or later and activesupport 8.1.3 or later. Bundler requires it on boot, so no `require` line is needed in the host.

2. Create `config/initializers/hub_kernel_interface.rb` holding one `to_prepare` block. The three settings name the host's own classes, and Rails refuses to load reloadable app constants while initializers run, so they go inside it:

   ```ruby
   Rails.application.config.to_prepare do
     # steps 3, 4 and 5 go here
   end
   ```

3. Ask the developer which hubs to serve, and at what names. Then set the list:

   ```ruby
   HubKernel::Interface.hubs = [ Supplies, { "money" => Billing::Ledger } ]
   ```

   - A hub listed on its own is served at its module name in snake case, without its namespace: `Supplies` at `supplies`, `Billing::Ledger` at `ledger`.
   - A hub listed as a one-pair hash is served only at the name given.
   - Every listed hub must already declare at least one callable method, and no two entries may answer at the same name. An interface's boot check fails on either.
   - Leaving the list unset serves no hubs.

4. Ask the developer how the app decides whether a person may act on an account. Then set the permission check to a callable taking the person, the action and the account:

   ```ruby
   HubKernel::Authz.check = ->(person, action, account) { person.can?(action, account) }
   ```

   - `action` is a string written `hub:method`, such as `supplies:price_of`.
   - The hub part is the hub's own module name in snake case, even when it is served under another name, so `Billing::Ledger` served as `money` is still asked about as `ledger:record_spend`.
   - It must return exactly `true` or `false`. Any other value, including `nil` or a record, fails the call.
   - Do not set `->(*) { true }` unless the developer says every person may call every method on every account.

5. Ask the developer how the app scopes work to one account, such as a tenancy gem or a `Current.account` attribute. Then set the account scope to a callable taking the account and a block:

   ```ruby
   HubKernel::Context.scope = ->(account, &call) { ActsAsTenant.with_tenant(account) { call.call } }
   ```

   - It must call the block exactly once, inside the scope.
   - It must return the block's value, since that value is what the call by name returns.
   - If the app has no account scoping, ask before using `->(account, &call) { call.call }`.

6. Run `bin/rails runner 'p HubKernel::Interface.hubs, HubKernel::Authz.check, HubKernel::Context.scope'` and confirm it prints the hub list and two callables, none of them empty or `nil`.

## Conventions

- A call by name made while the permission check or the account scope is unset fails as unwired. Both must be set before any interface serves a request.
- Rails reruns the `to_prepare` block on every code reload in development, so the three settings stay pointed at the current classes. Keep all three in it.
- Re-sync the hub list whenever a hub is added, renamed, or removed, or when an interface should stop serving one.
- Making a hub's methods callable, writing an interface gem, and handling the errors a call raises are out of scope here. They belong to the hub_kernel-interface-develop local.
