using Keryhe.Nexus.Services;

namespace Keryhe.Nexus.Sqlite;

public class SqliteDialect : ISqlDialect
{
    public string RecursiveCteKeyword => "RECURSIVE ";
    public string UtcNow => "strftime('%Y-%m-%dT%H:%M:%fZ','now')";
}
