using Keryhe.Nexus.Services;

namespace Keryhe.Nexus.Npgsql;

public class NpgsqlDialect : ISqlDialect
{
    public string RecursiveCteKeyword => "RECURSIVE ";
    // TIMESTAMPTZ columns always store UTC; NOW() AT TIME ZONE 'UTC' makes intent explicit
    public string UtcNow => "NOW() AT TIME ZONE 'UTC'";
}
