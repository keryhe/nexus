namespace Keryhe.Nexus.Models;

public class ConfigModel
{
    public int Id { get; set; }
    public int SectionId { get; set; }
    public string Name { get; set; } = "";
    public string DisplayName { get; set; } = "";
    public int SortOrder { get; set; }
    public string DataType { get; set; } = "";
    public string? Value { get; set; }
    public bool IsEncrypted { get; set; }
    public int? DropdownListId { get; set; }
    public string? DropdownListName { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
