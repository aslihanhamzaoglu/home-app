-- People, Households and Members, with row-level security.
-- A person can only read or write data of Households they are a Member of.
-- Admin-only actions and "the last Admin cannot leave" are enforced here.

-- Profiles --------------------------------------------------------------------

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null default '' check (char_length(display_name) <= 50),
  -- Push notifications are sent in this language.
  language text not null default 'tr' check (language in ('tr', 'en')),
  created_at timestamptz not null default now()
);

-- Every new auth user gets a profile. The app may pass `display_name` and
-- `language` in the sign-up metadata.
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name, language)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'display_name', ''),
    case when new.raw_user_meta_data ->> 'language' in ('tr', 'en')
      then new.raw_user_meta_data ->> 'language'
      else 'tr'
    end
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Households ------------------------------------------------------------------

create function public.is_valid_time_zone(tz text)
returns boolean
language sql
stable
set search_path = ''
as $$
  select exists (select 1 from pg_catalog.pg_timezone_names where name = tz);
$$;

create table public.households (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(btrim(name)) between 1 and 60),
  -- IANA name such as Europe/Istanbul. Times of day are computed in it.
  time_zone text not null check (public.is_valid_time_zone(time_zone)),
  created_at timestamptz not null default now()
);

-- Members ---------------------------------------------------------------------

create table public.members (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  is_admin boolean not null default false,
  joined_at timestamptz not null default now(),
  unique (household_id, user_id)
);

create index members_user_id_idx on public.members (user_id);

-- Membership checks used by RLS policies. Security definer so that policies on
-- `members` can look at `members` without recursing into their own RLS.

create function public.is_member(target_household_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.members
    where household_id = target_household_id
      and user_id = (select auth.uid())
  );
$$;

create function public.is_admin(target_household_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.members
    where household_id = target_household_id
      and user_id = (select auth.uid())
      and is_admin
  );
$$;

create function public.shares_household_with(other_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.members mine
    join public.members theirs on theirs.household_id = mine.household_id
    where mine.user_id = (select auth.uid())
      and theirs.user_id = other_user_id
  );
$$;

-- The last Admin cannot leave or stop being an Admin. Deleting the whole
-- Household (which cascades to its Members) is still allowed.
create function public.keep_an_admin()
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
  if tg_op = 'DELETE'
    and not exists (select 1 from public.households where id = old.household_id) then
    return old;
  end if;
  if not exists (
    select 1 from public.members
    where household_id = old.household_id
      and is_admin
      and id <> old.id
  ) then
    raise exception 'The last Admin of a Household cannot leave or stop being an Admin'
      using errcode = 'P0001', hint = 'last_admin';
  end if;
  return coalesce(new, old);
end;
$$;

create trigger members_keep_an_admin
  before update of is_admin or delete on public.members
  for each row execute function public.keep_an_admin();

-- Creating a Household makes the creator its first Admin, in one step.
create function public.create_household(name text, time_zone text)
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
  insert into public.households (name, time_zone)
  values (create_household.name, create_household.time_zone)
  returning * into household;
  insert into public.members (household_id, user_id, is_admin)
  values (household.id, (select auth.uid()), true);
  return household;
end;
$$;

revoke execute on function public.create_household(text, text) from public, anon;
grant execute on function public.create_household(text, text) to authenticated;

-- Row-level security ----------------------------------------------------------

alter table public.profiles enable row level security;
alter table public.households enable row level security;
alter table public.members enable row level security;

-- Only what each table allows is granted; RLS then narrows it to rows.
revoke all on public.profiles, public.households, public.members from anon, authenticated;
grant select on public.profiles to authenticated;
grant update (display_name, language) on public.profiles to authenticated;
grant select, update (name, time_zone), delete on public.households to authenticated;
grant select, update (is_admin), delete on public.members to authenticated;

create policy "People read their own profile and their housemates'"
  on public.profiles for select to authenticated
  using (id = (select auth.uid()) or public.shares_household_with(id));

create policy "People update their own profile"
  on public.profiles for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

create policy "Members read their Households"
  on public.households for select to authenticated
  using (public.is_member(id));

create policy "Admins update their Households"
  on public.households for update to authenticated
  using (public.is_admin(id))
  with check (public.is_admin(id));

create policy "Admins delete their Households"
  on public.households for delete to authenticated
  using (public.is_admin(id));

create policy "Members read the Members of their Households"
  on public.members for select to authenticated
  using (public.is_member(household_id));

create policy "Admins make or unmake Admins"
  on public.members for update to authenticated
  using (public.is_admin(household_id))
  with check (public.is_admin(household_id));

create policy "Members leave, Admins remove Members"
  on public.members for delete to authenticated
  using (user_id = (select auth.uid()) or public.is_admin(household_id));

-- Realtime --------------------------------------------------------------------

alter publication supabase_realtime add table public.households, public.members;
