-- A Household always has at least one Module switched on.
alter table public.households
  add constraint households_modules_not_empty check (cardinality(modules) >= 1);
