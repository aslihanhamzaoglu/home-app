-- The app follows the signed-in person's profile live, so that saving their
-- display name on first sign-in moves them on without reloading.
-- Realtime applies the profiles RLS policies to what each person receives.
alter publication supabase_realtime add table public.profiles;
