# Coding Standards

How code in this repo is written. `/implement` sessions follow these rules and `/code-review` enforces them. Use the vocabulary in `GLOSSARY.md` for names in code, and read the ADRs in `docs/adr/` that touch the area you work in.

## Platforms

- Targets are Android and iOS only. Do not add web or desktop code or folders.
- Development happens on Windows with a physical Android phone, so everything is verified on Android. Write platform-neutral code, but leave iOS-only setup (Sign in with Apple, APNs) to the iOS bring-up ticket. See ADR-0006.
- The app ID is `io.github.aslihanhamzaoglu.homeapp`. It can never change after publishing, so never rename it. The display name is "Ev" for now.

## Folder structure

Organise `lib/` by feature, using glossary names. No `domain/` / `data/` / `presentation/` layers and no use-case classes.

```
lib/
  app/            startup, router, theme
  core/           shared helpers, Supabase client setup, connectivity
  households/     Households, Members, Admin, Invite
  presence/
  meals/
  announcements/  includes Hangouts
  shopping_list/
  tasks/
  house_info/
  l10n/           ARB translation files
```

Inside a feature folder, use flat files named after what they hold: `household.dart` (model), `household_repository.dart` (interface), `supabase_household_repository.dart` (implementation), `household_providers.dart`, and `*_screen.dart` / widgets. `test/` mirrors `lib/`.

## Data access

- Screens and widgets never import or call the Supabase client. All data access goes through a repository interface with a Supabase implementation behind it. See ADR-0002.
- Repositories expose live data as streams (`watchItems(householdId)`) backed by Supabase Realtime, and writes as `Future`s. After a write, the UI updates when the stream delivers the change; do not also patch local state by hand.
- Build those streams with `liveRows` (`lib/core/live_rows.dart`), not the client's `.stream()`. `.stream()` lists a just-inserted row twice when Realtime delivers its INSERT late.
- Rules that must hold whoever calls the database (membership, Admin-only actions, "the last Admin cannot leave") are enforced in Postgres: RLS policies, constraints or SQL functions. The UI may hide an action, but the database is what forbids it.

## State management

- Use Riverpod (`flutter_riverpod`) without code generation. See ADR-0003.
- Each repository is provided by a `Provider` that returns the interface type, so tests can override it with a fake.
- Screens read streams through `StreamProvider`s and handle the loading, data and error states explicitly.

## Models

- Models are hand-written immutable classes with `fromJson`, `toJson`, `copyWith`, `==` and `hashCode`. No `build_runner`, `freezed` or `json_serializable`. See ADR-0004.
- When a field is added, update every one of those members and the model's test.

## Database

- Every schema change is a new timestamped file in `supabase/migrations/`. Never edit a migration that has been committed.
- `supabase db reset` must always apply all migrations and `supabase/seed.sql` cleanly.
- Every table holding Household data has RLS enabled, and a pgTAP test in `supabase/tests/` showing that a person outside the Household cannot read or write it.
- Use `uuid` primary keys and `timestamptz` for every point in time, stored in UTC.
- Each Household has a `time_zone` (IANA name such as `Europe/Istanbul`). Anything tied to a time of day, such as due dates, the morning Task push (08:00) or Meal Reminders, is computed in the Household's time zone. The app shows times in the phone's local time.

## Navigation

- Use go_router. Routes are defined in `lib/app/`.
- Redirect to sign-in when signed out, and to the Default Household when signed in.
- Invites are joined by code only; there are no invite links in v1. See ADR-0005.

## Translations

- Use Flutter's `gen-l10n` with `lib/l10n/app_en.arb` (the template, with a description for every key) and `lib/l10n/app_tr.arb`.
- No hard-coded user-facing strings. Every key exists in both files.
- Keys are English camelCase (`shoppingListTitle`). Module names in Turkish use the glossary forms (Alışveriş Listesi, Evde / Dışarıda, Duyurular, Etkinlik, Ev İşleri, Ev Bilgileri, Yemek).
- The person's chosen language is saved in their profile (`language` column), because the server sends push notifications in it. The default is the phone's language, falling back to Turkish.
- What Members type (Items, Tasks, Announcements) is never translated.

## Errors and connectivity

- The app is online-only. While offline, show a "No connection" banner.
- A failed action shows a short translated message and keeps what the person typed. Never fail silently and never show a raw exception.
- Log errors with `debugPrint` / `log` only. Crash reporting comes in the pre-launch ticket.

## Theme

- Material 3 with `ColorScheme.fromSeed(seedColor: Color(0xFFC8653D))` (terracotta), light and dark themes following the phone's setting.
- Font: Nunito, bundled as an asset (not downloaded at runtime).
- Take colours and text styles from the theme. Do not hard-code colours or font sizes in widgets.

## Environments

- Supabase URL and publishable key (`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`; the successor to the anon key) come from `--dart-define-from-file`: `env/local.json` (committed, local Docker Supabase) and `env/prod.json` (git-ignored; `env/prod.example.json` shows its shape).
- Google sign-in uses the Web OAuth client ID (`GOOGLE_WEB_CLIENT_ID`, not secret) from the same files, and the same ID in the Supabase Google provider (`supabase/config.toml` locally). The Android OAuth clients in Google Cloud only register the package name and signing SHA-1; each machine's debug keystore and the release key need their own.
- Run locally with `flutter run --dart-define-from-file=env/local.json`. For a USB-connected Android phone, run `adb reverse tcp:54321 tcp:54321` so `localhost` reaches the laptop. Local sign-in emails land in the local inbox at `http://localhost:54324`.

## Testing

- Database rules: pgTAP tests in `supabase/tests/`, run with `supabase test db`.
- Screens and app logic: widget and unit tests with fake repositories, overridden through Riverpod. This is where most `/tdd` work happens.
- Supabase repository implementations: a few integration tests against the local Supabase.
- No on-device end-to-end tests in v1.
- Before a ticket is done, `flutter analyze`, `flutter test` and `supabase test db` all pass.

## Lints

- `flutter_lints` plus bug-catching rules in `analysis_options.yaml` (such as `unawaited_futures`, `cancel_subscriptions`, `close_sinks`). Do not add a strict style package like `very_good_analysis`.
- Code is formatted with `dart format`.

## Workflow

- One branch per ticket (`ticket-<n>-<short-name>`) and one pull request whose description says `Closes #<n>`. The repo owner reviews and merges.
- GitHub Actions runs `flutter analyze`, `flutter test` and `supabase test db` on every pull request. Do not merge on red.
