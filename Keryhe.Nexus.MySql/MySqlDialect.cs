using Keryhe.Nexus.Services;

namespace Keryhe.Nexus.MySql;

public class MySqlDialect : ISqlDialect
{
    public string RecursiveCteKeyword => "RECURSIVE ";
    public string UtcNow => "UTC_TIMESTAMP()";
}
