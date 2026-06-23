# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Nexus is a database-driven configuration management library for .NET 10. Configuration is stored in a `Nexus` database and consumed either through the standard .NET `IConfiguration` pipeline or through a REST API (`Keryhe.Nexus.Api`) fronted by an Angular management UI (`nexus-angular/`). There is no ORM — data access is raw SQL via Dapper, with per-provider SQL fragments abstracted behind `ISqlDialect`.

## Commands

The solution file is `Nexus.slnx` (the newer XML solution format; use the .NET 10 SDK).

```bash
dotnet build Nexus.slnx                            # build everything
dotnet build Keryhe.Nexus/Keryhe.Nexus.csproj      # build one project
dotnet run --project Keryhe.Nexus.Api.Host         # run the REST API host (port 5199, MySQL)
```

There is **no .NET test project** in the solution. To exercise the stack end-to-end, run the API host and the Angular dev server (see the Angular section below).

`Keryhe.Nexus.Api.Host` is the runnable backend: set the `Nexus` connection string (e.g. in `Keryhe.Nexus.Api.Host/appsettings.json`) and create the schema by running the appropriate script from `schema/<provider>/schema.sql` against an empty database. Its `Program.cs` is wired to MySQL — change the `UseXxx` call there to target a different provider.

## Project layout

| Project | Role |
|---|---|
| `Keryhe.Nexus` | Core: models, `INexusService`/`NexusService` (all SQL via Dapper), `ISqlDialect`, `IEncryptionService`, `IDbConnectionFactory`, `NexusOptions`, `AddNexus()` |
| `Keryhe.Nexus.Sqlite` / `.Npgsql` / `.MySql` / `.SqlServer` | Provider packages: each supplies an `IDbConnectionFactory`, an `ISqlDialect`, and a `UseXxx(this NexusOptions, connectionString)` extension |
| `Keryhe.Nexus.Extensions` | `IConfiguration` source + polling reload provider, plus the `AddNexusConfig` registration helpers |
| `Keryhe.Nexus.Api` | Embeddable REST API (Minimal APIs) over `INexusService` + `AddNexusApi()` / `MapNexusApi()`, for front-end clients (e.g. the Angular app) |
| `Keryhe.Nexus.Api.Host` | Thin runnable ASP.NET Core host (port 5199, MySQL) that serves `Keryhe.Nexus.Api`; backend for `nexus-angular` |
| `nexus-angular/` | Angular + Angular Material management UI (not in the .slnx) that talks to the REST API |

## Architecture

### Data model and hierarchy

Five tables (see `schema/`): `Category`, `Section`, `Config`, `DropdownList`, `DropdownListItem`. Both `Category` and `Section` are **self-referencing trees** (`ParentId`), and `Section` also belongs to a `Category`. A `Config` belongs to a `Section`. `Config.DropdownListId` optionally binds a value to a set of `DropdownListItem` rows.

`NexusService.GetSectionsByCategoryAsync` walks the section tree with a **recursive CTE** — this is why `ISqlDialect.RecursiveCteKeyword` exists (`"RECURSIVE "` for SQLite/MySQL/PostgreSQL, `""` for SQL Server). `ISqlDialect.UtcNow` similarly abstracts the "current UTC timestamp" SQL expression used when updating `Config.UpdatedAt`.

### Provider abstraction

`NexusService` depends only on `IDbConnectionFactory` (opens connections) and `ISqlDialect` (SQL fragments). Adding a database provider = implement those two interfaces + a `UseXxx` extension that registers them on `NexusOptions.Services`. No core code changes.

### Registration paths (this is the part most likely to trip you up)

`NexusOptions` is just a wrapper around `IServiceCollection`; `UseXxx` calls register the provider services onto it. There are three entry points, and they must not double-register:

- **`AddNexusApi(configure, configureApi?)`** (`Keryhe.Nexus.Api`) — registers Nexus services + OpenAPI + a CORS policy for a REST front-end. Pair with `app.MapNexusApi()` to map the endpoints. Same `UseXxx()` provider selection as the others.
- **`AddNexusConfig(IServiceCollection, IConfigurationBuilder, configure, pollingInterval)`** (`Keryhe.Nexus.Extensions`) — when `INexusService` is **not** already registered: configures options, registers `INexusService`, **and** adds the config source in one call.
- **`AddNexusConfig(IConfigurationBuilder, IServiceCollection, pollingInterval)`** (`ConfigurationBuilderExtensions`) — when `INexusService` is **already registered** (e.g. you already called `AddNexusApi`): adds only the config source. This is the correct way to combine the API with `IConfiguration` loading in one host.

Both config-source helpers call `services.BuildServiceProvider()` to resolve `INexusService` at startup so the provider can be built. `AddNexus()` uses `TryAdd*`, so registering twice is harmless but the helper split above is intentional to avoid it.

### IConfiguration provider (`Keryhe.Nexus.Extensions/Configuration`)

`NexusConfigurationProvider` flattens the DB hierarchy into colon-delimited keys: `{Category.Name}:{Section.Name}:{...nested sections...}:{Config.Name}` (see `BuildPath`). It polls on a timer (default **60s**; `TimeSpan.Zero` disables polling) and reloads only when `GetMaxUpdatedAtAsync()` (`MAX(Config.UpdatedAt)`) changes — a cheap change-detection probe rather than re-reading everything each tick. Because `ConfigurationProvider.Load` is synchronous, the async service calls are bridged with `.GetAwaiter().GetResult()`.

### Encryption

`IEncryptionService` defaults to `NullEncryptionService` (pass-through). `NexusService` encrypts/decrypts `Config.Value` transparently when `Config.IsEncrypted` is set, both on read (`GetConfigsBySectionIdsAsync`) and write (`UpdateConfigValueAsync`). Supply a real `IEncryptionService` to enable actual encryption.

## Management UI (`nexus-angular/`)

A standalone Angular 20 + Angular Material app — the only UI — with an idiomatic Material look & feel. It talks to the REST API (`/api/nexus/*`) via a typed `HttpClient` wrapper (`services/nexus-api.service.ts`). Shell: `mat-toolbar` + collapsible `mat-sidenav` (`nexus-panel`), with a `ThemeService` light/dark toggle (`.theme-dark` on `<body>`, flips the M3 `color-scheme`). Component tree: `nexus-panel` → `nexus-sidebar` (`mat-tree` category tree) + `nexus-content` → `section-renderer` (recursive) → `config-editor`.

**Layout-by-SectionType is the key idea.** How a group of sibling sections is rendered is decided by the `sectionType` of their **parent** (the `Category` for top-level sections, or the parent `Section` for nested ones). `section-renderer` recurses, passing each section's own `sectionType` down to control how *its* children render. Recognized values (case-insensitive, free-form string — new values can be added without a schema change, and fall through to the default):

- `card` (default) → `mat-card`
- `tab-h` → `mat-tab-group` (horizontal tabs)
- `tab-v` → master/detail (a `mat-nav-list` on the left selects which section's controls show on the right)
- `accordion` → `mat-expansion-panel`

A leaf section (no child sections) renders its `Config` rows directly via `config-editor`.

`config-editor` picks an input control from `Config.dataType` (case-insensitive): `bool`, `int`, `float`, `date`, `time`, `datetime`, `color`, `dropdown` (bound to `DropdownListItem`s, lazy-loaded on open), `json`, `multiline`, `url`, `email`, and string-like `guid`/`string`/default. String-type fields show a lock toggle (`matSuffix`) that flips the encrypted flag; encrypted fields render as password inputs. `color`/`time`/`datetime` use native HTML inputs (no third-party UI deps). Category and section **structure is read-only** — only `Config` values (and their encrypted flag) are editable. `SortOrder` controls ordering within a sibling group for categories, sections, and configs; ties break alphabetically by `displayName`.

**Deferred editing.** Edits are not saved on blur — they are buffered in `ConfigEditStore` (`services/config-edit-store.ts`, provided on `NexusPanelComponent`). Each `config-editor` reports changes via `setEdit` and shows a dirty "Edited" badge (`isDirty`); a category-level Save/Cancel bar in `nexus-content` commits all pending edits (one `PUT` per dirty config via `forkJoin`) or reverts them; `nexus-panel` guards category switches with a confirm dialog when edits are pending. The store's `resetTick` signal drives an `effect` in each editor to re-seed after save/cancel — that re-seed must stay `untracked` so reading the edits signal inside it doesn't make the effect self-trigger.

Dev: run `Keryhe.Nexus.Api.Host` (port 5199) then `npm start` in `nexus-angular` (proxies `/api` → 5199).
