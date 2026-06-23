using Microsoft.Extensions.DependencyInjection;
using Keryhe.Nexus.Options;
using Keryhe.Nexus.Npgsql;
using Keryhe.Nexus.Providers;
using Keryhe.Nexus.Services;

namespace Keryhe.Nexus.Npgsql.Extensions;

public static class ServiceCollectionExtensions
{
    public static NexusOptions UseNpgsql(this NexusOptions options, string connectionString)
    {
        options.Services.AddSingleton<IDbConnectionFactory>(_ => new NpgsqlConnectionFactory(connectionString));
        options.Services.AddSingleton<ISqlDialect, NpgsqlDialect>();
        return options;
    }
}
