using Microsoft.Extensions.DependencyInjection;
using Keryhe.Nexus.Options;
using Keryhe.Nexus.Providers;
using Keryhe.Nexus.Services;

namespace Keryhe.Nexus.Sqlite.Extensions;

public static class ServiceCollectionExtensions
{
    public static NexusOptions UseSqlite(this NexusOptions options, string connectionString)
    {
        options.Services.AddSingleton<IDbConnectionFactory>(_ => new SqliteConnectionFactory(connectionString));
        options.Services.AddSingleton<ISqlDialect, SqliteDialect>();
        return options;
    }
}
