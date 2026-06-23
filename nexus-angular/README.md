# nexus-angular

Angular + Angular Material front-end for Nexus configuration management, with an idiomatic
Material look & feel. It provides category navigation, section layouts, and editable config
values by calling the `Keryhe.Nexus.Api` REST API.

The shell is a `mat-toolbar` + collapsible `mat-sidenav` drawer with a light/dark theme toggle.

## Architecture

- **`services/nexus-api.service.ts`** — typed `HttpClient` wrapper over `/api/nexus/*`.
- **`models/nexus.models.ts`** — interfaces matching the API's JSON.
- **`services/theme.service.ts`** — light/dark toggle (`.theme-dark` on `<body>`, persisted to
  `localStorage`).
- **Components** (`src/app/components/`):
  - `nexus-panel` — Material app shell (`mat-toolbar` + `mat-sidenav`); loads categories, holds
    the selection, hosts the theme toggle.
  - `nexus-sidebar` — Material `mat-tree` of categories (single select, read-only structure).
  - `nexus-content` — loads sections + configs for the selected category.
  - `section-renderer` — **recursive**; renders child sections per the parent's `sectionType`.
  - `config-editor` — renders an editor per `dataType`; edits are deferred (buffered in
    `config-edit-store.ts`) and committed by the category-level Save/Cancel bar. The encryption
    lock is a `matSuffix` inside the field.

Section layouts use stock Angular Material: `card`→`mat-card`, `tab-h`→`mat-tab-group`,
`accordion`→`mat-expansion-panel`, and `tab-v`→a master/detail layout (a `mat-nav-list` on the
left selects which section's controls show on the right). Editors Material doesn't cover
(`color`, `time`, `datetime`) use native HTML inputs. No third-party UI dependencies.

## Running

The app needs the Nexus REST API running. The dev server proxies `/api` to
`http://localhost:5199` (see `proxy.conf.json`).

1. Start the API host (from the repo root):
   ```bash
   dotnet run --project Keryhe.Nexus.Api.Host   # serves http://localhost:5199
   ```
2. Start the Angular dev server:
   ```bash
   npm install
   npm start                                    # ng serve, http://localhost:4200
   ```
3. Open http://localhost:4200.

To point at a different backend, edit `proxy.conf.json` (dev) or `src/environments/environment*.ts`.

## Build / test

```bash
npm run build     # production build to dist/
npm test          # Karma unit tests
```
