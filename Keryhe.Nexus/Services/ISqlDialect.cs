namespace Keryhe.Nexus.Services;

/// <summary>
/// Provides provider-specific SQL fragments used by NexusService.
/// Each database provider project implements this interface.
/// </summary>
public interface ISqlDialect
{
    /// <summary>
    /// The keyword that follows WITH in a recursive CTE declaration.
    /// Returns "RECURSIVE " (with trailing space) for MySQL, PostgreSQL, and SQLite.
    /// Returns "" for SQL Server, which does not use the RECURSIVE keyword.
    /// </summary>
    string RecursiveCteKeyword { get; }

    /// <summary>
    /// A SQL expression that returns the current UTC date/time,
    /// suitable for use in an UPDATE SET clause.
    /// </summary>
    string UtcNow { get; }
}
