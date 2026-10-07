# Changelog

## [Unreleased]

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
