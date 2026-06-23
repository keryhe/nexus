using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Keryhe.Nexus.Services;

namespace Keryhe.Nexus.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddNexus(this IServiceCollection services)
    {
        services.TryAddScoped<INexusService, NexusService>();
        services.TryAddSingleton<IEncryptionService, NullEncryptionService>();
        return services;
    }
}
