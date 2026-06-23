using Keryhe.Nexus.Models;

namespace Keryhe.Nexus.Services;

public interface INexusService
{
    Task<IEnumerable<CategoryModel>> GetAllCategoriesAsync();
    Task<CategoryModel?> GetCategoryByIdAsync(int id);
    Task<IEnumerable<SectionModel>> GetSectionsByCategoryAsync(int categoryId);
    Task<IEnumerable<ConfigModel>> GetConfigsBySectionIdsAsync(IEnumerable<int> sectionIds);
    Task<IEnumerable<DropdownListItemModel>> GetDropdownListItemsAsync(int dropdownListId);
    Task UpdateConfigValueAsync(int id, string? value, bool isEncrypted = false);
    Task<DateTime?> GetMaxUpdatedAtAsync();
}
