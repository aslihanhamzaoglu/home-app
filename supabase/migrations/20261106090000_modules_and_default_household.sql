-- Which Modules each Household has on, and each person's Default Household.

-- Modules ---------------------------------------------------------------------

-- The built-in Modules a Household has switched on (see ADR-0001). New
-- Households start with all of them.
alter table public.households
  add column modules text[] not null
    default array['shopping_list', 'presence', 'announcements', 'tasks', 'house_info', 'meals']
    check (modules <@ array['shopping_list', 'presence', 'announcements', 'tasks', 'house_info', 'meals']);

-- Default Household -----------------------------------------------------------

-- The Household the person's app opens to. Null until they create or pick one.
alter table public.profiles
  add column default_household_id uuid
    references public.households (id) on delete set null;

grant update (default_household_id) on public.profiles to authenticated;

-- A person's Default Household is always one they are a Member of.
create function public.check_default_household()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.default_household_id is not null and not exists (
    select 1 from public.members
    where household_id = new.default_household_id
      and user_id = new.id
  ) then
    raise exception 'The Default Household must be one of the person''s Households'
      using errcode = '23514';
  end if;
  return new;
end;
$$;

create trigger profiles_check_default_household
  before insert or update of default_household_id on public.profiles
  for each row execute function public.check_default_household();

-- Leaving a Household (or being removed) clears it as the Default Household.
create function public.clear_default_household()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.profiles
  set default_household_id = null
  where id = old.user_id
    and default_household_id = old.household_id;
  return old;
end;
$$;

create trigger members_clear_default_household
  after delete on public.members
  for each row execute function public.clear_default_household();

revoke execute on function
  public.check_default_household(),
  public.clear_default_household()
from public, anon, authenticated;

-- Creating a Household --------------------------------------------------------

-- Now also takes the Modules to switch on, and makes the new Household the
-- creator's Default Household when they have none yet.
drop function public.create_household(text, text);

create function public.create_household(
  name text,
  time_zone text,
  modules text[] default array['shopping_list', 'presence', 'announcements', 'tasks', 'house_info', 'meals']
)
returns public.households
language plpgsql
security definer
set search_path = ''
as $$
declare
  household public.households;
begin
  if (select auth.uid()) is null then
    raise exception 'Not signed in' using errcode = '42501';
  end if;
  insert into public.households (name, time_zone, modules)
  values (create_household.name, create_household.time_zone, create_household.modules)
  returning * into household;
  insert into public.members (household_id, user_id, is_admin)
  values (household.id, (select auth.uid()), true);
  update public.profiles
  set default_household_id = household.id
  where id = (select auth.uid())
    and default_household_id is null;
  return household;
end;
$$;

revoke execute on function public.create_household(text, text, text[]) from public, anon;
grant execute on function public.create_household(text, text, text[]) to authenticated;
