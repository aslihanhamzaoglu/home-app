-- Members: Admin-only actions and "the last Admin cannot leave".
begin;
select plan(13);

-- Household A: Ayşe (Admin), Bora and Deniz. Household B: Can (Admin).
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-00000000000a', 'ayse@pgtap.local'),
  ('00000000-0000-0000-0000-00000000000b', 'bora@pgtap.local'),
  ('00000000-0000-0000-0000-00000000000c', 'can@pgtap.local'),
  ('00000000-0000-0000-0000-00000000000d', 'deniz@pgtap.local');

insert into public.households (id, name, time_zone) values
  ('aaaaaaaa-0000-0000-0000-000000000000', 'Household A', 'Europe/Istanbul'),
  ('bbbbbbbb-0000-0000-0000-000000000000', 'Household B', 'Europe/Istanbul');

insert into public.members (household_id, user_id, is_admin) values
  ('aaaaaaaa-0000-0000-0000-000000000000', '00000000-0000-0000-0000-00000000000a', true),
  ('aaaaaaaa-0000-0000-0000-000000000000', '00000000-0000-0000-0000-00000000000b', false),
  ('aaaaaaaa-0000-0000-0000-000000000000', '00000000-0000-0000-0000-00000000000d', false),
  ('bbbbbbbb-0000-0000-0000-000000000000', '00000000-0000-0000-0000-00000000000c', true);

set local role authenticated;

-- Can, an outsider to Household A.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}', true);
update public.members set is_admin = true
  where household_id = 'aaaaaaaa-0000-0000-0000-000000000000';
delete from public.members
  where household_id = 'aaaaaaaa-0000-0000-0000-000000000000';
select throws_ok(
  $$ insert into public.members (household_id, user_id)
     values ('aaaaaaaa-0000-0000-0000-000000000000', '00000000-0000-0000-0000-00000000000c') $$,
  '42501',
  null,
  'a person cannot add themselves to a Household'
);

-- Bora, a Member who is not an Admin.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated"}', true);
update public.members set is_admin = true
  where user_id = '00000000-0000-0000-0000-00000000000b';
delete from public.members
  where user_id = '00000000-0000-0000-0000-00000000000d';

reset role;
select results_eq(
  $$ select count(*)::int from public.members
     where household_id = 'aaaaaaaa-0000-0000-0000-000000000000' $$,
  array[3],
  'neither an outsider nor a non-Admin can remove Members'
);
select results_eq(
  $$ select user_id from public.members
     where household_id = 'aaaaaaaa-0000-0000-0000-000000000000' and is_admin $$,
  array['00000000-0000-0000-0000-00000000000a'::uuid],
  'neither an outsider nor a non-Admin can make Admins'
);

set local role authenticated;
select throws_ok(
  $$ update public.members set household_id = 'bbbbbbbb-0000-0000-0000-000000000000'
     where user_id = '00000000-0000-0000-0000-00000000000b' $$,
  '42501',
  null,
  'a Member cannot move a membership to another Household'
);

-- Ayşe, the only Admin.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}', true);
select throws_ok(
  $$ delete from public.members where user_id = '00000000-0000-0000-0000-00000000000a' $$,
  'P0001',
  'The last Admin of a Household cannot leave or stop being an Admin',
  'the last Admin cannot leave'
);
select throws_ok(
  $$ update public.members set is_admin = false
     where user_id = '00000000-0000-0000-0000-00000000000a' $$,
  'P0001',
  'The last Admin of a Household cannot leave or stop being an Admin',
  'the last Admin cannot stop being an Admin'
);
select lives_ok(
  $$ update public.members set is_admin = true
     where user_id = '00000000-0000-0000-0000-00000000000b' $$,
  'an Admin can make another Member an Admin'
);
select lives_ok(
  $$ delete from public.members where user_id = '00000000-0000-0000-0000-00000000000a' $$,
  'an Admin can leave while another Admin remains'
);

-- Bora, now the only Admin.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated"}', true);
select lives_ok(
  $$ delete from public.members where user_id = '00000000-0000-0000-0000-00000000000d' $$,
  'an Admin can remove a Member'
);
select results_eq(
  $$ select user_id from public.members order by user_id $$,
  array['00000000-0000-0000-0000-00000000000b'::uuid],
  'only Bora remains in Household A'
);

-- Can again: a Member who is not an Admin can leave on their own.
reset role;
insert into public.members (household_id, user_id) values
  ('bbbbbbbb-0000-0000-0000-000000000000', '00000000-0000-0000-0000-00000000000d');
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000d","role":"authenticated"}', true);
select lives_ok(
  $$ delete from public.members where user_id = '00000000-0000-0000-0000-00000000000d' $$,
  'a Member can leave a Household'
);

-- Bora deletes the whole Household, even though he is its last Admin.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated"}', true);
select lives_ok(
  $$ delete from public.households where id = 'aaaaaaaa-0000-0000-0000-000000000000' $$,
  'the last Admin can delete the Household'
);
reset role;
select is_empty(
  $$ select 1 from public.members
     where household_id = 'aaaaaaaa-0000-0000-0000-000000000000' $$,
  'deleting a Household removes its Members'
);

select * from finish();
rollback;
