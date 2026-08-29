# SF9 Cloud Website — Setup

## What this version provides

- Register with email + password
- Sign in / sign out
- Password reset email
- Persistent Supabase Auth session
- Cloud-saved SF9 learner records
- Per-user database isolation using PostgreSQL Row Level Security
- Card Information stored per account
- Existing SF9 print card retained
- Summary learner list and individual SF9 printing
- Rank by Term 1, Term 2, Term 3, or Overall
- Import old `localStorage` learner records into the signed-in cloud account

## 1. Create a Supabase project

Create a project in Supabase.

## 2. Run the database SQL

Open the Supabase SQL Editor and run:

    supabase.sql

This creates:
- `sf9_profiles`
- `sf9_records`
- RLS policies
- automatic profile creation for new Auth users

## 3. Configure Auth

In Supabase Authentication settings:
- Enable Email/password.
- If email confirmation is enabled, users must confirm their email before signing in.
- Set your production Site URL and redirect URLs when you deploy the website.

## 4. Configure the website

Open:

    config.js

Replace:

    https://YOUR-PROJECT.supabase.co
    YOUR_SUPABASE_PUBLISHABLE_KEY

with your project's URL and browser publishable key.

Do NOT put a service-role/secret key in the website.

## 5. Run the website

For a quick test, serve the folder with a local web server rather than opening the HTML with `file://`.

Example:

    python -m http.server 8000

Then open:

    http://localhost:8000/

## 6. Deploy

Upload:
- `index.html`
- `config.js`

to your static hosting provider.

Keep `supabase.sql` private as your setup/migration file.

## Data model

`sf9_records.record` stores the current learner object as JSONB. This preserves the existing SF9 structure:

- learner information
- grades for Terms 1–3
- attendance
- comments
- transfer fields
- photo/logo data if present in the record

Each record has a `user_id`, and RLS limits access to the signed-in owner.

## Important

The browser contains only the Supabase publishable key. The service-role key must never be placed in HTML or JavaScript.
