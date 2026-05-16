# Schema Snapshots

`snapshot.sql` — point-in-time schema dump of the HyreAgent production Supabase database.

Generated with:
```bash
supabase db dump --schema-only   # uses pg_dump under the hood
```

Excludes Supabase-internal schemas (`auth`, `storage`, `extensions`, `realtime`, etc.).
Includes only the `public` schema tables, views, functions, RLS policies, and indexes.

**Date captured:** 2026-05-16  
**Project ref:** `wefcbqfxzvvgremxhubi` (East US — Ohio)

## Usage

Apply to a fresh Postgres instance:
```bash
psql "$DB_URL" < schema/snapshot.sql
```

## Next steps (M3)

Migrate to Supabase CLI migrations as source of truth:
- `supabase db pull` to generate migration files from this snapshot
- Store migrations in `supabase/migrations/` — this becomes the authoritative schema history
