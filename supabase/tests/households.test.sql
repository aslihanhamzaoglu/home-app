-- Households: only Members can read a Household, only Admins can change it.
begin;
select plan(12);

-- Ayşe is in Household A, Can is in Household B, Deniz is in both.
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-00000000000a', 'ayse@pgtap.local'),
  ('00000000-0000-0000-0000-00000000000c', 'can@pgtap.local'),
  ('00000000-0000-0000-0000-00000000000d', 'deniz@pgtap.local');

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}', true);
select lives_ok(
  $$ select public.create_household('Household A', 'Europe/Istanbul') $$,
  'a signed-in person can create a Household'
);
select results_eq(
  $$ select m.is_admin from public.members m
     join public.households h on h.id = m.household_id
     where h.name = 'Household A'
       and m.user_id = '00000000-0000-0000-0000-00000000000a' $$,
  array[true],
  'the creator of a Household is its first Admin'
);

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}', true);
select public.create_household('Household B', 'Europe/Berlin');

reset role;
-- Deniz joins both Households as a plain Member (joining by Invite comes later).
insert into public.members (household_id, user_id)
select id, '00000000-0000-0000-0000-00000000000d' from public.households
where name in ('Household A', 'Household B');

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}', true);
select results_eq(
  $$ select name from public.households order by name $$,
  array['Household A'],
  'a person sees only the Households they are a Member of'
);
select is_empty(
  $$ select 1 from public.members m
     join public.households h on h.id = m.household_id
     where h.name = 'Household B' $$,
  'a person cannot read the Members of another Household'
);
select lives_ok(
  $$ update public.households set name = 'Household B hacked' where name = 'Household B' $$,
  'updating another Household runs without error'
);
select throws_ok(
  $$ select public.create_household('Bad zone', 'Mars/Olympus') $$,
  '23514',
  null,
  'a Household needs a valid IANA time zone'
);

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000d","role":"authenticated"}', true);
select results_eq(
  $$ select name from public.households order by name $$,
  array['Household A', 'Household B'],
  'a person can be a Member of several Households'
);
update public.households set name = 'Renamed by Deniz' where name = 'Household A';
select results_eq(
  $$ select name from public.households order by name $$,
  array['Household A', 'Household B'],
  'a Member who is not an Admin cannot change the Household'
);
select throws_ok(
  $$ insert into public.households (name, time_zone) values ('Direct', 'UTC') $$,
  '42501',
  null,
  'Households are created only through create_household'
);

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}', true);
update public.households set time_zone = 'Europe/London' where name = 'Household A';
select results_eq(
  $$ select time_zone from public.households where name = 'Household A' $$,
  array['Europe/London'],
  'an Admin can change the Household'
);

reset role;
select results_eq(
  $$ select name from public.households where name like 'Household %' order by name $$,
  array['Household A', 'Household B'],
  'the outsider''s update did not change Household B'
);

set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select throws_ok(
  $$ select 1 from public.households $$,
  '42501',
  null,
  'a signed-out person cannot read Households'
);

select * from finish();
rollback;
