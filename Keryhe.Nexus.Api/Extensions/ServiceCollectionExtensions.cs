using Microsoft.Extensions.DependencyInjection;
using Keryhe.Nexus.Api.Options;
using Keryhe.Nexus.Extensions;
using Keryhe.Nexus.Options;

namespace Keryhe.Nexus.Api.Extensions;

public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Registers Nexus services, OpenAPI document generation, and a CORS policy for the REST API.
    /// Choose the database provider inside <paramref name="configure"/> via a <c>UseXxx</c> call
    /// (e.g. <c>UseSqlite</c>, <c>UseMySql</c>).
    /// Map the endpoints afterwards with <c>MapNexusApi</c>.
    /// </summary>
    public static IServiceCollection AddNexusApi(
        this IServiceCollection services,
        Action<NexusOptions> configure,
        Action<NexusApiOptions>? configureApi = null)
    {
        var options = new NexusOptions(services);
        configure(options);
        services.AddNexus();

        var apiOptions = new NexusApiOptions();
        configureApi?.Invoke(apiOptions);

        services.AddOpenApi();
        services.AddCors(o => o.AddPolicy(NexusApiOptions.CorsPolicyName, policy =>
            policy.WithOrigins(apiOptions.AllowedOrigins)
                  .AllowAnyHeader()
                  .AllowAnyMethod()));

        return services;
    }
}
