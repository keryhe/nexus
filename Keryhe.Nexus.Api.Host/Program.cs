using Keryhe.Nexus.Api.Extensions;
using Keryhe.Nexus.MySql.Extensions;
using Scalar.AspNetCore;

var builder = WebApplication.CreateBuilder(args);

// Registers INexusService (MySQL provider), OpenAPI, and the Nexus CORS policy.
// Swap UseMySql for UseSqlite / UseNpgsql / UseSqlServer to target another database.
builder.Services.AddNexusApi(
    options => options.UseMySql(builder.Configuration.GetConnectionString("Nexus")!),
    api => api.AllowedOrigins =
        builder.Configuration.GetSection("Nexus:Cors").Get<string[]>()
        ?? ["http://localhost:4200"]);

var app = builder.Build();

app.UseCors();
app.MapOpenApi();               // OpenAPI document at /openapi/v1.json
app.MapScalarApiReference();    // interactive API explorer at /scalar/v1
app.MapNexusApi();              // Nexus endpoints under /api/nexus

app.Run();
