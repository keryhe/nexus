using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Keryhe.Nexus.Options;
using Keryhe.Nexus.Services;

namespace Keryhe.Nexus.Extensions.Configuration;

public static class ConfigurationBuilderExtensions
{
    /// <summary>
    /// Use when you have an <see cref="IServiceCollection"/> with <see cref="INexusService"/> already registered
    /// (for example via <c>AddNexusApi</c>) and want to also add Nexus as a configuration source. Builds a
    /// temporary service provider to resolve <see cref="INexusService"/>; no separate options configuration is
    /// needed.
    /// <para>
    /// If <see cref="INexusService"/> is <b>not</b> already registered, prefer
    /// <see cref="ServiceCollectionExtensions.AddNexusConfig(IServiceCollection, IConfigurationBuilder, Action{NexusOptions}, TimeSpan)"/>
    /// which registers Nexus options and the configuration source together.
    /// </para>
    /// </summary>
    public static IConfigurationBuilder AddNexusConfig(
        this IConfigurationBuilder builder,
        IServiceCollection services,
        TimeSpan pollingInterval = default)
    {
        var sp = services.BuildServiceProvider();
        return builder.AddNexusConfig(sp.GetRequiredService<INexusService>(), pollingInterval);
    }

    internal static IConfigurationBuilder AddNexusConfig(
        this IConfigurationBuilder builder,
        INexusService nexusService,
        TimeSpan pollingInterval = default)
        => builder.Add(new NexusConfigurationSource(nexusService)
           {
               PollingInterval = pollingInterval == default ? TimeSpan.FromSeconds(60) : pollingInterval
           });
}
