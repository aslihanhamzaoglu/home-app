-- Modules on a new Household, and each person's Default Household.
begin;
select plan(12);

-- Ayşe creates Households; Can creates his own; Deniz joins Ayşe's first one.
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-00000000000a', 'ayse@pgtap.local'),
  ('00000000-0000-0000-0000-00000000000c', 'can@pgtap.local'),
  ('00000000-0000-0000-0000-00000000000d', 'deniz@pgtap.local');

set local role authenticated;

-- Modules ---------------------------------------------------------------------

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}', true);
select public.create_household('First', 'Europe/Istanbul', array['presence', 'meals']);
select results_eq(
  $$ select modules from public.households where name = 'First' $$,
  $$ values (array['presence', 'meals']) $$,
  'a new Household has the chosen Modules on'
);
select public.create_household('Second', 'Europe/Istanbul');
select results_eq(
  $$ select modules from public.households where name = 'Second' $$,
  $$ values (array['shopping_list', 'presence', 'announcements', 'tasks', 'house_info', 'meals']) $$,
  'without a choice, a new Household has all six Modules on'
);
select throws_ok(
  $$ select public.create_household('Pets', 'Europe/Istanbul', array['presence', 'pets']) $$,
  '23514',
  null,
  'only built-in Modules can be switched on'
);
select throws_ok(
  $$ select public.create_household('Empty', 'Europe/Istanbul', array[]::text[]) $$,
  '23514',
  null,
  'a Household has at least one Module on'
);

-- Default Household -----------------------------------------------------------

select results_eq(
  $$ select h.name from public.profiles p
     join public.households h on h.id = p.default_household_id
     where p.id = '00000000-0000-0000-0000-00000000000a' $$,
  array['First'],
  'the first Household a person creates becomes their Default Household, and later ones do not replace it'
);
select lives_ok(
  $$ update public.profiles
     set default_household_id = (select id from public.households where name = 'Second')
     where id = '00000000-0000-0000-0000-00000000000a' $$,
  'a person can make another of their Households the Default Household'
);

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}', true);
select public.create_household('Can''s', 'Europe/Berlin');
update public.profiles
set default_household_id = (select id from public.households where name = 'Can''s')
where id = '00000000-0000-0000-0000-00000000000d';

reset role;
select is(
  (select default_household_id from public.profiles where id = '00000000-0000-0000-0000-00000000000d'),
  null,
  'nobody can set someone else''s Default Household'
);
insert into public.members (household_id, user_id)
select id, '00000000-0000-0000-0000-00000000000d' from public.households where name = 'First';
-- Deniz cannot read Can's Household, so keep its id where he can.
create temp table cans_household as
  select id from public.households where name = 'Can''s';
grant select on cans_household to authenticated;
set local role authenticated;

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000d","role":"authenticated"}', true);
select throws_ok(
  $$ update public.profiles
     set default_household_id = (select id from cans_household)
     where id = '00000000-0000-0000-0000-00000000000d' $$,
  '23514',
  null,
  'the Default Household must be one of the person''s Households'
);
reset role;
select throws_ok(
  $$ update public.profiles
     set default_household_id = (select id from public.households where name = 'Can''s')
     where id = '00000000-0000-0000-0000-00000000000d' $$,
  '23514',
  null,
  'the database enforces it whoever writes the profile'
);
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000d","role":"authenticated"}', true);
select lives_ok(
  $$ update public.profiles
     set default_household_id = (select id from public.households where name = 'First')
     where id = '00000000-0000-0000-0000-00000000000d' $$,
  'a Member can make a Household they joined their Default Household'
);

delete from public.members
where user_id = '00000000-0000-0000-0000-00000000000d';
reset role;
select is(
  (select default_household_id from public.profiles where id = '00000000-0000-0000-0000-00000000000d'),
  null,
  'leaving a Household clears it as the Default Household'
);

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}', true);
delete from public.households where name = 'Second';
reset role;
select is(
  (select default_household_id from public.profiles where id = '00000000-0000-0000-0000-00000000000a'),
  null,
  'deleting a Household clears it as the Default Household'
);

select * from finish();
rollback;
