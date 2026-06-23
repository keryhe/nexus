using Microsoft.Extensions.DependencyInjection;
using Keryhe.Nexus.Options;
using Keryhe.Nexus.MySql;
using Keryhe.Nexus.Providers;
using Keryhe.Nexus.Services;

namespace Keryhe.Nexus.MySql.Extensions;

public static class ServiceCollectionExtensions
{
    public static NexusOptions UseMySql(this NexusOptions options, string connectionString)
    {
        options.Services.AddSingleton<IDbConnectionFactory>(_ => new MySqlConnectionFactory(connectionString));
        options.Services.AddSingleton<ISqlDialect, MySqlDialect>();
        return options;
    }
}
