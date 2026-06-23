# Nexus

A database-driven configuration management library for .NET 10 applications. Store configuration values in a `Nexus` database and consume them either through the standard .NET `IConfiguration` pipeline or via a REST API with an Angular management UI.

---

## Packages

| Package | Purpose |
|---|---|
| `Keryhe.Nexus` | Core library — services, models, interfaces |
| `Keryhe.Nexus.Sqlite` | SQLite database provider |
| `Keryhe.Nexus.Npgsql` | PostgreSQL database provider |
| `Keryhe.Nexus.MySql` | MySQL / MariaDB database provider |
| `Keryhe.Nexus.SqlServer` | SQL Server database provider |
| `Keryhe.Nexus.Api` | REST API over `INexusService` for front-end clients (e.g. the Angular app) |
| `Keryhe.Nexus.Api.Host` | Thin runnable ASP.NET Core host that serves `Keryhe.Nexus.Api` (backend for the Angular app) |
| `Keryhe.Nexus.Extensions` | `IConfiguration` source + DI registration with polling reload |

The `nexus-angular/` folder holds an Angular + Angular Material front-end (the management UI) that talks to the REST API (see `nexus-angular/README.md`).

---

## Database Setup

Schema scripts for each provider are in the `schema/` directory:

```
schema/
  sqlite/schema.sql
  npgsql/schema.sql
  mysql/schema.sql
  sqlserver/schema.sql
```

Run the appropriate script against an empty database before using the library.

---

## Management UI (Angular)

The management UI is an Angular + Angular Material app in the `nexus-angular/` folder. It provides category navigation, section layouts, and editable config values (with deferred Save/Cancel and a light/dark theme), talking to the REST API described below.

To run it: start the API host, then the Angular dev server.

```bash
dotnet run --project Keryhe.Nexus.Api.Host   # backend on http://localhost:5199

cd nexus-angular
npm install
npm start                                     # UI on http://localhost:4200
```

See `nexus-angular/README.md` for details. The REST API it depends on is documented below.

---

## REST API

The `Keryhe.Nexus.Api` package exposes `INexusService` as a set of REST/JSON endpoints so a front-end (such as the Angular app) can manage configuration. It ships as an embeddable library — you add it to your own ASP.NET Core host.

### 1. Add the NuGet packages

```xml
<PackageReference Include="Keryhe.Nexus.Api" Version="*" />
<PackageReference Include="Keryhe.Nexus.MySql" Version="*" />  <!-- or your provider -->
```

### 2. Register services and map endpoints

In `Program.cs`, call `AddNexusApi` with your database provider, then `MapNexusApi`:

```csharp
using Keryhe.Nexus.Api.Extensions;
using Keryhe.Nexus.MySql.Extensions;  // or your provider
using Scalar.AspNetCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddNexusApi(
    options => options.UseMySql(builder.Configuration.GetConnectionString("Nexus")!),
    api => api.AllowedOrigins =
        builder.Configuration.GetSection("Nexus:Cors").Get<string[]>()
        ?? ["http://localhost:4200"]);

var app = builder.Build();

app.UseCors();                  // applies the registered Nexus CORS policy
app.MapOpenApi();               // OpenAPI document at /openapi/v1.json
app.MapScalarApiReference();    // interactive API explorer at /scalar/v1
app.MapNexusApi();              // Nexus endpoints under /api/nexus

app.Run();
```

`AddNexusApi` registers `INexusService` (via the chosen provider), OpenAPI document generation, and a CORS policy. The `configureApi` callback is optional; by default CORS allows `http://localhost:4200` (the Angular dev server).

`MapNexusApi` accepts an optional route prefix (default `/api/nexus`).

For a ready-to-run backend, use the `Keryhe.Nexus.Api.Host` project (`dotnet run --project Keryhe.Nexus.Api.Host`, serves `http://localhost:5199`). It wires the API to MySQL and is the backend the `nexus-angular` app proxies to.

### Endpoints

| Method & route | Description |
|---|---|
| `GET /api/nexus/categories` | All categories |
| `GET /api/nexus/categories/{id}` | A single category (`404` if not found) |
| `GET /api/nexus/categories/{categoryId}/sections` | The category's section tree |
| `GET /api/nexus/configs?sectionId=1&sectionId=2` | Configs for the given section ids (repeat `sectionId` per id) |
| `GET /api/nexus/configs/max-updated-at` | `{ "maxUpdatedAt": "..." }` — poll to detect changes |
| `PUT /api/nexus/configs/{id}/value` | Update a config value; body `{ "value": "...", "isEncrypted": false }`; returns `204` |
| `GET /api/nexus/dropdown-lists/{id}/items` | Items for a dropdown list |

Encrypted config values are decrypted server-side before they are returned, so serve the API over HTTPS. Supply a real `IEncryptionService` to enable actual encryption at rest.

---

## IConfiguration Source

The `Keryhe.Nexus.Extensions` package integrates Nexus into the standard .NET `IConfiguration` pipeline. This makes config values available via `IConfiguration`, `IOptions<T>`, and `IOptionsMonitor<T>` throughout your application.

### 1. Add the NuGet packages

```xml
<PackageReference Include="Keryhe.Nexus.Extensions" Version="*" />
<PackageReference Include="Keryhe.Nexus.MySql" Version="*" />  <!-- or your provider -->
```

### 2. Register services and configuration source

Call `AddNexus` on `builder.Services`, passing `builder.Configuration` and your database provider. This registers `INexusService` in DI **and** adds the Nexus configuration source in one call:

```csharp
using Keryhe.Nexus.Extensions;
using Keryhe.Nexus.MySql.Extensions;  // or your provider

// SQLite
builder.Services.AddNexusConfig(builder.Configuration, options =>
    options.UseSqlite(builder.Configuration.GetConnectionString("Nexus")!));

// PostgreSQL
builder.Services.AddNexusConfig(builder.Configuration, options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("Nexus")!));

// MySQL / MariaDB
builder.Services.AddNexusConfig(builder.Configuration, options =>
    options.UseMySql(builder.Configuration.GetConnectionString("Nexus")!));

// SQL Server
builder.Services.AddNexusConfig(builder.Configuration, options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("Nexus")!));
```

Because `AddNexus` also registers `INexusService` in DI, it is available for injection throughout the app without any additional setup.

### Key format

Config values are exposed using colon-delimited keys that mirror the database hierarchy:

```
{Category.Name}:{Section.Name}:{...nested sections...}:{Config.Name}
```

For example, a config named `Host` in section `Smtp` (nested under `Email`) in category `MyApp` is accessed as:

```
MyApp:Email:Smtp:Host
```

### Polling and reload

The provider polls the database on a configurable interval and reloads when data has changed. The default interval is **60 seconds**. To customize:

```csharp
builder.Services.AddNexusConfig(builder.Configuration, options =>
    options.UseMySql(builder.Configuration.GetConnectionString("Nexus")!),
    pollingInterval: TimeSpan.FromSeconds(30));
```

To disable polling (load once at startup only):

```csharp
builder.Services.AddNexusConfig(builder.Configuration, options =>
    options.UseMySql(builder.Configuration.GetConnectionString("Nexus")!),
    pollingInterval: TimeSpan.Zero);
```

---

## Consuming Configuration Values

Once registered as an `IConfiguration` source, Nexus values are available through the standard .NET Options pattern.

### Options pattern (recommended)

Define a strongly-typed options class that maps to a section of the config hierarchy:

```csharp
public class SmtpOptions
{
    public string Host { get; set; } = "";
    public int Port { get; set; }
    public string Username { get; set; } = "";
}
```

Bind it to a section in `Program.cs`:

```csharp
builder.Services.Configure<SmtpOptions>(
    builder.Configuration.GetSection("MyApp:Email:Smtp"));
```

Inject `IOptions<T>` into any class:

```csharp
public class EmailService
{
    private readonly SmtpOptions _smtp;

    public EmailService(IOptions<SmtpOptions> options)
    {
        _smtp = options.Value;
    }
}
```

### Live reload with `IOptionsMonitor<T>`

If polling reload is enabled, inject `IOptionsMonitor<T>` to always read the latest values and optionally react to changes:

```csharp
public class EmailService
{
    private readonly IOptionsMonitor<SmtpOptions> _options;

    public EmailService(IOptionsMonitor<SmtpOptions> options)
    {
        _options = options;

        // Optional: register a callback that fires when config reloads
        _options.OnChange(updated =>
        {
            // updated contains the new values
        });
    }

    public SmtpOptions CurrentSettings => _options.CurrentValue;
}
```

`IOptions<T>` reads the value once at startup and does not reflect subsequent reloads. Use `IOptionsMonitor<T>` or `IOptionsSnapshot<T>` if your service needs to see live updates.

### Direct `IConfiguration` access

For one-off lookups, inject `IConfiguration` and read by key:

```csharp
public class MyService
{
    public MyService(IConfiguration config)
    {
        var host = config["MyApp:Email:Smtp:Host"];
    }
}
```
