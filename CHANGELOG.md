# Changelog

## [Unreleased]

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
