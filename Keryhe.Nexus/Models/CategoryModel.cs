namespace Keryhe.Nexus.Models;

public class CategoryModel
{
    public int Id { get; set; }
    public int? ParentId { get; set; }
    public string Name { get; set; } = "";
    public string DisplayName { get; set; } = "";
    public int SortOrder { get; set; }
    public string SectionType { get; set; } = "Card";
}
