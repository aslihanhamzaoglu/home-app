-- Profiles: each person has one, readable by people they share a Household with.
begin;
select plan(7);

insert into auth.users (id, email, raw_user_meta_data) values
  ('00000000-0000-0000-0000-00000000000a', 'ayse@pgtap.local', '{"display_name":"Ayşe","language":"en"}'),
  ('00000000-0000-0000-0000-00000000000b', 'bora@pgtap.local', '{"display_name":"Bora"}'),
  ('00000000-0000-0000-0000-00000000000c', 'can@pgtap.local', '{}');

select results_eq(
  $$ select display_name, language from public.profiles
     where id = '00000000-0000-0000-0000-00000000000a' $$,
  $$ values ('Ayşe', 'en') $$,
  'signing up creates a profile from the sign-up details'
);
select results_eq(
  $$ select language from public.profiles
     where id = '00000000-0000-0000-0000-00000000000c' $$,
  array['tr'],
  'the language falls back to Turkish'
);

insert into public.households (id, name, time_zone) values
  ('aaaaaaaa-0000-0000-0000-000000000000', 'Household A', 'Europe/Istanbul');
insert into public.members (household_id, user_id, is_admin) values
  ('aaaaaaaa-0000-0000-0000-000000000000', '00000000-0000-0000-0000-00000000000a', true),
  ('aaaaaaaa-0000-0000-0000-000000000000', '00000000-0000-0000-0000-00000000000b', false);

set local role authenticated;

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}', true);
select results_eq(
  $$ select display_name from public.profiles order by display_name $$,
  array['Ayşe', 'Bora'],
  'a person reads their own profile and those of their housemates'
);
update public.profiles set display_name = 'Hacked'
  where id = '00000000-0000-0000-0000-00000000000b';
select lives_ok(
  $$ update public.profiles set display_name = 'Ayşe H.', language = 'tr'
     where id = '00000000-0000-0000-0000-00000000000a' $$,
  'a person can change their own name and language'
);

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}', true);
select results_eq(
  $$ select id from public.profiles $$,
  array['00000000-0000-0000-0000-00000000000c'::uuid],
  'a person cannot read the profiles of people outside their Households'
);
select throws_ok(
  $$ update public.profiles set language = 'de'
     where id = '00000000-0000-0000-0000-00000000000c' $$,
  '23514',
  null,
  'the language is Turkish or English'
);

reset role;
select results_eq(
  $$ select p.display_name from public.profiles p
     join auth.users u on u.id = p.id
     where u.email like '%@pgtap.local'
     order by p.display_name $$,
  array['', 'Ayşe H.', 'Bora'],
  'a person cannot change someone else''s profile'
);

select * from finish();
rollback;
