-- Hardening after review of the data foundation migration.

-- 1. Two Admins demoting or removing each other at the same moment could both
--    see "another Admin remains" and leave the Household with none. Lock the
--    Household row first so these changes run one after another.
create or replace function public.keep_an_admin()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not old.is_admin then
    return coalesce(new, old);
  end if;
  if tg_op = 'UPDATE' and new.is_admin then
    return new;
  end if;
  perform 1 from public.households where id = old.household_id for update;
  if not found then
    -- The whole Household is being deleted.
    return old;
  end if;
  if not exists (
    select 1 from public.members
    where household_id = old.household_id
      and is_admin
      and id <> old.id
  ) then
    -- The app recognises this error by its hint (see SupabaseMemberRepository).
    raise exception 'The last Admin of a Household cannot leave or stop being an Admin'
      using errcode = 'P0001', hint = 'last_admin';
  end if;
  return coalesce(new, old);
end;
$$;

-- 2. A CHECK constraint must be immutable, but the list of time zones can
--    change with tzdata. Validate on write with a trigger instead.
alter table public.households
  drop constraint households_time_zone_check;

create function public.check_time_zone()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if not public.is_valid_time_zone(new.time_zone) then
    raise exception 'Unknown time zone: %', new.time_zone
      using errcode = '23514';
  end if;
  return new;
end;
$$;

create trigger households_check_time_zone
  before insert or update of time_zone on public.households
  for each row execute function public.check_time_zone();

-- 3. Helper and trigger functions are not part of the API.
revoke execute on function
  public.is_valid_time_zone(text),
  public.is_member(uuid),
  public.is_admin(uuid),
  public.shares_household_with(uuid)
from public, anon;
grant execute on function
  public.is_valid_time_zone(text),
  public.is_member(uuid),
  public.is_admin(uuid),
  public.shares_household_with(uuid)
to authenticated;

revoke execute on function
  public.handle_new_user(),
  public.keep_an_admin(),
  public.check_time_zone()
from public, anon, authenticated;
