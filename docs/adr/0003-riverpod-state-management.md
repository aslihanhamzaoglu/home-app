# Riverpod for state management, without code generation

Screens get their data through Riverpod (`flutter_riverpod`). Each repository from ADR-0002 is exposed as a provider of its interface type, and live data reaches screens through `StreamProvider`s fed by the repositories' Realtime streams. Tests override the repository providers with fakes, which is what makes screens testable without a database. Providers are written by hand rather than with `riverpod_generator`, in line with ADR-0004.

Switching state management later means touching every screen, so this is hard to reverse.

## Considered Options

- **Bloc**: very structured, but needs an event and state class per screen, which is a lot of boilerplate for an app of small Modules.
- **Provider**: simpler and older; its own author recommends Riverpod instead.
- **Riverpod with `riverpod_generator`**: less typing, but adds a `build_runner` step. Rejected for the same reasons as ADR-0004.
