# database

> HyreAgent.ai Postgres schema, migrations, and RLS policies.

## Purpose

Single source of truth for the database schema. This repo is **not a runtime** — it is **schema-as-code** consumed by:

- `platform` services (which run queries against the live DB)
- `infrastructure` (which configures Supabase project + connection pooler)
- `qa` (which uses the schema to write integration test fixtures)

## Layout

```
database/
├── ddl/                      # one file per CREATE TABLE / TYPE / FUNCTION
│   ├── 01_users.sql
│   ├── 02_jobs.sql
│   ├── 03_applications.sql
│   ├── 04_contacts.sql
│   ├── ...
├── dml/                      # data seeds (lookup tables, not user data)
│   ├── seed_countries.sql
│   ├── seed_request_types.sql
├── rls/                      # one file per table's RLS policies
│   ├── applications.sql
│   ├── contacts.sql
│   ├── ...
├── migrations/               # Supabase migration history (forward-only)
│   ├── 20260301000000_init.sql
│   ├── ...
├── script-library/           # one-off operational SQL (audits, backfills)
│   ├── audit_rls_coverage.sql
│   ├── backfill_user_quotas.sql
└── docs/
    └── ER-diagram.md         # links to the Drive diagram + a textual model
```

## Standards

- **Identifiers:** `snake_case` everywhere; no quoting.
- **Keywords:** lowercase (`select`, `from`).
- **Primary keys:** `id uuid primary key default gen_random_uuid()` unless there's a reason otherwise.
- **Foreign keys:** always indexed (audit script `script-library/find-missing-fk-indexes.sql`).
- **Timestamps:** `created_at timestamptz not null default now()` + `updated_at` with a trigger.
- **RLS:** enabled on every table in `public.`. Per-tenant tables policy `auth.uid() = user_id`. Shared catalogs documented in [docs/wiki/RLS-Coverage](https://github.com/HyreAgent-ai/docs/wiki/RLS-Coverage).
- **No service-role bypass from app code.** Service-role is restricted to scripts in this repo and the `platform/services/scraping/` daily cron.

## Migration workflow

```bash
# 1. Create the migration locally
supabase migration new <description>

# 2. Edit the new file in supabase/migrations/

# 3. Apply locally
supabase db reset       # rebuilds local Supabase + applies all migrations

# 4. Open a PR → CI applies migration to a Supabase branch + runs RLS tests

# 5. After merge to main, run against production
supabase db push
```

## Prerequisites

- [Supabase CLI](https://supabase.com/docs/guides/cli) ≥ 1.150
- Docker (for local Supabase stack)
- Access to the `HyreAgent-ai` Supabase project (request via `proj` repo issue)

## Branching

- `main` → migrations applied to production
- `dev` → migrations applied to staging Supabase project
- Feature branches: `<username>_<issue#>_<short>`

**Migrations are forward-only.** A bad migration is reverted by writing a counter-migration, not by deleting the file.

## RLS coverage

Live RLS state for every table is queried in `script-library/audit_rls_coverage.sql` and pasted into [docs/wiki/Multi-Tenant-Security](https://github.com/HyreAgent-ai/docs/wiki/Multi-Tenant-Security) as Appendix H.

## Backups + DR

- **Daily snapshots:** Supabase Pro tier (post-1k users); pre-1k users we rely on weekly `pg_dump` to S3.
- **Restore drill:** quarterly — see [docs/wiki/Disaster-Recovery](https://github.com/HyreAgent-ai/docs/wiki/Disaster-Recovery).

## Contributing

See [CONTRIBUTING.md](https://github.com/HyreAgent-ai/.github/blob/main/CONTRIBUTING.md). Migration PRs require an explicit "rollback plan" section in the description.

## License

[Apache-2.0](./LICENSE)

## Contact

- Maintainer: [@Siddardth7](https://github.com/Siddardth7)
- Schema questions: file an issue with `service/database` + `type/docs`
