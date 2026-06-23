using Dapper;
using Keryhe.Nexus.Models;
using Keryhe.Nexus.Providers;

namespace Keryhe.Nexus.Services;

public class NexusService : INexusService
{
    private readonly IDbConnectionFactory _connectionFactory;
    private readonly ISqlDialect _dialect;
    private readonly IEncryptionService _encryption;

    public NexusService(
        IDbConnectionFactory connectionFactory,
        ISqlDialect dialect,
        IEncryptionService encryption)
    {
        _connectionFactory = connectionFactory;
        _dialect = dialect;
        _encryption = encryption;
    }

    public async Task<IEnumerable<CategoryModel>> GetAllCategoriesAsync()
    {
        using var connection = _connectionFactory.CreateConnection();
        var results = await connection.QueryAsync<CategoryModel>(
            """
            SELECT Id, ParentId, Name, DisplayName, SortOrder, SectionType
            FROM Category
            ORDER BY SortOrder, DisplayName
            """);
        return results;
    }

    public async Task<CategoryModel?> GetCategoryByIdAsync(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await connection.QuerySingleOrDefaultAsync<CategoryModel>(
            """
            SELECT Id, ParentId, Name, DisplayName, SortOrder, SectionType
            FROM Category
            WHERE Id = @Id
            """,
            new { Id = id });
    }

    public async Task<IEnumerable<SectionModel>> GetSectionsByCategoryAsync(int categoryId)
    {
        var sql = $"""
            WITH {_dialect.RecursiveCteKeyword}SectionTree AS (
                SELECT Id, ParentId, CategoryId, Name, DisplayName, SortOrder, SectionType
                FROM Section
                WHERE CategoryId = @CategoryId
                  AND ParentId IS NULL
                UNION ALL
                SELECT s.Id, s.ParentId, s.CategoryId, s.Name, s.DisplayName, s.SortOrder, s.SectionType
                FROM Section s
                INNER JOIN SectionTree st ON s.ParentId = st.Id
            )
            SELECT * FROM SectionTree
            ORDER BY SortOrder, DisplayName
            """;

        using var connection = _connectionFactory.CreateConnection();
        return await connection.QueryAsync<SectionModel>(sql, new { CategoryId = categoryId });
    }

    public async Task<IEnumerable<ConfigModel>> GetConfigsBySectionIdsAsync(IEnumerable<int> sectionIds)
    {
        using var connection = _connectionFactory.CreateConnection();
        var results = await connection.QueryAsync<ConfigModel>(
            """
            SELECT c.Id, c.SectionId, c.Name, c.DisplayName, c.SortOrder,
                   c.DataType, c.Value, c.IsEncrypted,
                   c.DropdownListId, dl.Name AS DropdownListName,
                   c.CreatedAt, c.UpdatedAt
            FROM Config c
            LEFT JOIN DropdownList dl ON dl.Id = c.DropdownListId
            WHERE c.SectionId IN @SectionIds
            ORDER BY c.SortOrder, c.DisplayName
            """,
            new { SectionIds = sectionIds });

        foreach (var config in results)
        {
            config.CreatedAt = DateTime.SpecifyKind(config.CreatedAt, DateTimeKind.Utc);
            config.UpdatedAt = DateTime.SpecifyKind(config.UpdatedAt, DateTimeKind.Utc);

            if (config.IsEncrypted && config.Value is not null)
                config.Value = _encryption.Decrypt(config.Value);
        }

        return results;
    }

    public async Task<IEnumerable<DropdownListItemModel>> GetDropdownListItemsAsync(int dropdownListId)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await connection.QueryAsync<DropdownListItemModel>(
            """
            SELECT Id, Name, Value, SortOrder
            FROM DropdownListItem
            WHERE DropdownListId = @DropdownListId
            ORDER BY SortOrder, Name
            """,
            new { DropdownListId = dropdownListId });
    }

    public async Task UpdateConfigValueAsync(int id, string? value, bool isEncrypted = false)
    {
        var storedValue = isEncrypted && value is not null
            ? _encryption.Encrypt(value)
            : value;

        using var connection = _connectionFactory.CreateConnection();
        await connection.ExecuteAsync(
            $"UPDATE Config SET Value = @Value, IsEncrypted = @IsEncrypted, UpdatedAt = {_dialect.UtcNow} WHERE Id = @Id",
            new { Id = id, Value = storedValue, IsEncrypted = isEncrypted });
    }

    public async Task<DateTime?> GetMaxUpdatedAtAsync()
    {
        using var connection = _connectionFactory.CreateConnection();
        var result = await connection.QuerySingleOrDefaultAsync<DateTime?>(
            "SELECT MAX(UpdatedAt) FROM Config");
        return result.HasValue
            ? DateTime.SpecifyKind(result.Value, DateTimeKind.Utc)
            : null;
    }
}
