---
name: hub_kernel-interface-info
description: Use to learn what hub_kernel-interface offers — hubs listing the methods outside callers may reach by name, permission-checked calls in an account's scope, the host's list of served hubs, and the shared reasons interfaces give when a call is turned down.
tools: Read
scope: hub interface contract — a hub declaring the methods outside callers may reach by name, calling one by name for a person and an account behind the permission check and account scope, the host's one list of served hubs and its boot check, and the reasons every interface gives for an unlisted value or a missing record
---

This local explains hub_kernel-interface and makes no changes.

## What hub_kernel-interface is

hub_kernel-interface is the contract between a hub and the interfaces that call it from outside the app. A hub is a module holding one area of the application's behaviour. It names which of its methods an outside caller may reach by name, the values each one takes, and whether it writes. An interface, such as a JSON API or an MCP server, uses that list to show a person what they may call on an account, and to make the call.

Every call by name carries a person and an account. The host's permission check is asked whether that person may run that method on that account, and the call runs inside the host's account scope. The host also keeps one list of the hubs every interface serves, with a boot check that fails loudly when that list cannot be served. Interface gems depend on this gem alone, not on the rest of hub_kernel.

Reach for it when a Rails app wants its hubs callable from an API or an agent server, or when building a gem that serves hubs to outside callers.

## Interface

This local declares no commands of its own. The surface belongs to the other two locals:

- **hub_kernel-interface-install** owns adding the gem to a host and filling the three host settings: the served hub list, the permission check, and the account scope.
- **hub_kernel-interface-develop** owns everything a hub or an interface gem writes against: declaring a hub's callable methods, listing and making calls by name, finding served hubs, the boot check, the shared refusal reasons, and the errors a call can raise.

## How to use it

- Wiring the gem into an app, or a call fails because a host setting is empty: go to the install local.
- Making a hub's methods callable by name, writing an interface gem that serves hubs, or handling the errors a call raises: go to the develop local.

## Conventions

- **Hub** — a module that groups one area of behaviour and lists which of its methods outside callers may reach.
- **Host** — the Rails app that runs the hubs and fills the gem's three settings.
- **Interface gem** — a gem that serves hubs to outside callers, such as an API or an MCP server.
- **Served name** — the name an interface reaches a hub by. A hub listed on its own is served at its module name in snake case, and a hub listed as a one-pair hash is served only at the name given.
- **Permission action** — the string the permission check is asked about, written `hub:method` with the hub's own snake-case name, even when it is served under another name.
- **Person and account** — the caller and the account a call acts on. Every call by name needs both.
- **Values** — the keyword arguments a call passes. Each callable method lists the values it takes, and a value outside that list is a reason to turn the call down.
- **Boot check** — the check an interface gem runs at start-up that reports every problem in the served list at once: a hub with no callable methods, two hubs at one name, and a listed method the hub does not have or whose values do not match.
- **Port** — a host setting the gem calls but does not fill: the permission check and the account scope. A call made while either is empty fails as unwired.
