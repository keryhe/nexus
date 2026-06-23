using System.Data;
using Microsoft.Data.Sqlite;
using Keryhe.Nexus.Providers;

namespace Keryhe.Nexus.Sqlite;

public class SqliteConnectionFactory(string connectionString) : IDbConnectionFactory
{
    public IDbConnection CreateConnection() => new SqliteConnection(connectionString);
}
