# Supabase access only through repositories

The app uses Supabase (Postgres, Auth, Realtime, PostgREST) as its backend, but screens and widgets never call the Supabase client directly. Every read, write and realtime subscription goes through a repository interface per area (for example `HouseholdRepository`), with a Supabase implementation behind it. This keeps a future move away from Supabase (self-hosted Supabase, another Postgres host with our own API, or a different auth service) down to writing new repository implementations, instead of touching every screen. It also lets tests swap in fake repositories.

Business rules that must hold no matter who calls the database, such as "the last Admin cannot leave", live in Postgres (RLS policies, constraints, SQL functions) rather than only in Dart, because plain Postgres moves with the data.

## Considered Options

- **Call `supabase.from(...)` straight from screens**: the quickest to write, but it ties every screen to Supabase's query API and makes leaving Supabase a rewrite of the UI layer. Rejected.
- **Our own API server between the app and Postgres from day one**: the most portable, but it adds a server to build and run before v1 needs it. Rejected for v1; the repository layer leaves this path open.

## Consequences

- RLS policies use Supabase's `auth.uid()`. Moving to another auth system means supplying the signed-in person's id another way, or moving those checks into a server.
- Sign-in is Google, Apple and email one-time codes with no passwords, so accounts can move to another auth system by matching provider identities exported from Supabase.
- Prefer plain Postgres features over Supabase-only extras (Edge Functions, Storage-specific features) unless a ticket clearly needs them.
