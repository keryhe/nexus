using Microsoft.Extensions.DependencyInjection;

namespace Keryhe.Nexus.Options;

public class NexusOptions
{
    public IServiceCollection Services { get; }

    public NexusOptions(IServiceCollection services)
    {
        Services = services;
    }
}
