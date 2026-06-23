using Keryhe.Nexus.Services;
using Microsoft.Extensions.Configuration;

namespace Keryhe.Nexus.Extensions.Configuration;

public class NexusConfigurationSource : IConfigurationSource
{
    private readonly INexusService _nexusService;

    public TimeSpan PollingInterval { get; init; } = TimeSpan.FromSeconds(60);

    public NexusConfigurationSource(INexusService nexusService)
    {
        _nexusService = nexusService;
    }

    public IConfigurationProvider Build(IConfigurationBuilder builder)
        => new NexusConfigurationProvider(_nexusService, PollingInterval);
}
