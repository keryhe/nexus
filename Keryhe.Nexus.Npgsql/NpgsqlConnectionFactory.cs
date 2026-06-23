using System.Data;
using Npgsql;
using Keryhe.Nexus.Providers;

namespace Keryhe.Nexus.Npgsql;

public class NpgsqlConnectionFactory(string connectionString) : IDbConnectionFactory
{
    public IDbConnection CreateConnection() => new NpgsqlConnection(connectionString);
}
