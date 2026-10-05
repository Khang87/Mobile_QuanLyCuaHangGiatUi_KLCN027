# Laundry App

Flutter client for the single-store laundry application.

## Local development

The app uses the linked hosted Supabase project by default. The local run command
below overrides that configuration with the local Supabase URL and key.

Start the local Supabase stack from this directory:

```powershell
npx supabase start
npx supabase db reset
```

Apply the migrations to the linked hosted Supabase project before testing real
Google customers and the laundry catalog:

```powershell
npx supabase link --project-ref osnblefzulmsuthhuswl
npx supabase db push
```

The latest migration provisions Google-authenticated customers and seeds the
initial active services, item types, units, and prices. The Flutter app now
reads this catalog from Supabase instead of using demo prices.

This applies the checked-in schema baseline, security/order migrations, and a development-only catalog seed. The seed contains no customer records.

Run the app against local Supabase on the desktop:

```powershell
flutter run `
	--dart-define=SUPABASE_URL=http://127.0.0.1:54321 `
	--dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_LOCAL_PUBLISHABLE_KEY
```

Get the local publishable key from `npx supabase status`. For an Android emulator, use `http://10.0.2.2:54321` as the URL. Do not use a service-role or secret key in the Flutter app.

Customer sign-in and registration use Supabase phone OTP. Configure an SMS provider in the hosted project's Auth settings before expecting production SMS delivery. New customer profiles are created or linked only after Supabase confirms the phone number. Staff and manager identities must be provisioned and linked by a trusted administrator; self-service signup cannot grant staff roles.

## Checks

```powershell
flutter test
flutter analyze
npx supabase test db --local
npx supabase db advisors --local --type security
```

The production database schema is represented by the baseline migration. Apply later migrations to production only after review and a deployment window; the checked-in RLS migration intentionally restricts the existing broad client grants.
