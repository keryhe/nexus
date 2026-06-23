using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Keryhe.Nexus.Options;
using Keryhe.Nexus.Services;
using Keryhe.Nexus.Extensions.Configuration;

namespace Keryhe.Nexus.Extensions;

public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Use during host startup when you need to configure Nexus options and register Nexus as an
    /// <see cref="IConfigurationBuilder"/> source in one call — e.g. in a <c>Program.cs</c> bootstrap
    /// before the DI container is finalized.
    /// <para>
    /// If <see cref="INexusService"/> is already registered (for example via <c>AddNexusApi</c>), do not use this
    /// overload; use
    /// <see cref="ConfigurationBuilderExtensions.AddNexusConfig(IConfigurationBuilder, IServiceCollection, TimeSpan)"/>
    /// instead to add the configuration source without double-registering Nexus services.
    /// </para>
    /// </summary>
    public static IServiceCollection AddNexusConfig(
        this IServiceCollection services,
        IConfigurationBuilder configBuilder,
        Action<NexusOptions> configure,
        TimeSpan pollingInterval = default)
    {
        services.AddNexusConfig(configure);

        var sp = services.BuildServiceProvider();
        configBuilder.AddNexusConfig(sp.GetRequiredService<INexusService>(), pollingInterval);
        return services;
    }

    internal static IServiceCollection AddNexusConfig(
        this IServiceCollection services,
        Action<NexusOptions> configure)
    {
        var options = new NexusOptions(services);
        configure(options);
        services.AddNexus();
        return services;
    }
}
