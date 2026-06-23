using System.Data;
using Microsoft.Data.SqlClient;
using Keryhe.Nexus.Providers;

namespace Keryhe.Nexus.SqlServer;

public class SqlServerConnectionFactory(string connectionString) : IDbConnectionFactory
{
    public IDbConnection CreateConnection() => new SqlConnection(connectionString);
}
