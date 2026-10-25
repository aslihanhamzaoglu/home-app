# Hand-written models, no code generation

Models (Household, Member, Item, Task and so on) are plain Dart classes written by hand, with `fromJson`, `toJson`, `copyWith`, `==` and `hashCode`. The project does not use `build_runner`, so no `freezed`, `json_serializable` or `riverpod_generator`.

Code generation saves typing, but agents do the typing here. Its costs land on every fresh session and on the human reading the code: a build step to remember, generated files in the repo, and confusing "missing `_$Household`" errors when generated code goes stale. The models are small and few, so the boilerplate stays manageable.

## Considered Options

- **`freezed` + `json_serializable` everywhere**: the common Flutter default. Rejected for v1 for the reasons above.
- **`freezed` for a single complex model**: allowed later if one model, such as a Recurring Task's schedule, becomes painful to maintain by hand. Record it in a new ADR when that happens.
