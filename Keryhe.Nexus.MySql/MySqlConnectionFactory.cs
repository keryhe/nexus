using System.Data;
using MySqlConnector;
using Keryhe.Nexus.Providers;

namespace Keryhe.Nexus.MySql;

public class MySqlConnectionFactory(string connectionString) : IDbConnectionFactory
{
    public IDbConnection CreateConnection() => new MySqlConnection(connectionString);
}
