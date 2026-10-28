-- Local test data: two Households and four people.
-- Sign in with any of these emails; the one-time code lands in the local inbox
-- at http://localhost:54324.
--
--   ayse@test.local   Admin of Moda Flat
--   bora@test.local   Member of Moda Flat
--   can@test.local    Admin of Berlin Flat
--   deniz@test.local  Member of both

insert into auth.users (
  instance_id, id, aud, role, email, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, recovery_token, email_change_token_new, email_change
)
select
  '00000000-0000-0000-0000-000000000000', id, 'authenticated', 'authenticated',
  email, now(),
  '{"provider":"email","providers":["email"]}', meta, now(), now(),
  '', '', '', ''
from (values
  ('10000000-0000-4000-8000-00000000000a'::uuid, 'ayse@test.local', '{"display_name":"Ayşe","language":"tr"}'::jsonb),
  ('10000000-0000-4000-8000-00000000000b'::uuid, 'bora@test.local', '{"display_name":"Bora","language":"tr"}'::jsonb),
  ('10000000-0000-4000-8000-00000000000c'::uuid, 'can@test.local', '{"display_name":"Can","language":"en"}'::jsonb),
  ('10000000-0000-4000-8000-00000000000d'::uuid, 'deniz@test.local', '{"display_name":"Deniz","language":"en"}'::jsonb)
) as people (id, email, meta);

insert into auth.identities (
  id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
)
select
  gen_random_uuid(), id::text, id,
  jsonb_build_object('sub', id::text, 'email', email, 'email_verified', true),
  'email', now(), now(), now()
from auth.users
where email like '%@test.local';

insert into public.households (id, name, time_zone) values
  ('20000000-0000-4000-8000-000000000001', 'Moda Flat', 'Europe/Istanbul'),
  ('20000000-0000-4000-8000-000000000002', 'Berlin Flat', 'Europe/Berlin');

insert into public.members (household_id, user_id, is_admin) values
  ('20000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-00000000000a', true),
  ('20000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-00000000000b', false),
  ('20000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-00000000000d', false),
  ('20000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-00000000000c', true),
  ('20000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-00000000000d', false);
