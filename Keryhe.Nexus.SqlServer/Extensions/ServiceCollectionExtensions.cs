using Microsoft.Extensions.DependencyInjection;
using Keryhe.Nexus.Options;
using Keryhe.Nexus.Providers;
using Keryhe.Nexus.Services;

namespace Keryhe.Nexus.SqlServer.Extensions;

public static class ServiceCollectionExtensions
{
    public static NexusOptions UseSqlServer(this NexusOptions options, string connectionString)
    {
        options.Services.AddSingleton<IDbConnectionFactory>(_ => new SqlServerConnectionFactory(connectionString));
        options.Services.AddSingleton<ISqlDialect, SqlServerDialect>();
        return options;
    }
}
