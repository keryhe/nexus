using Keryhe.Nexus.Services;

namespace Keryhe.Nexus.SqlServer;

public class SqlServerDialect : ISqlDialect
{
    // SQL Server does not use the RECURSIVE keyword in CTEs
    public string RecursiveCteKeyword => "";
    public string UtcNow => "SYSUTCDATETIME()";
}
