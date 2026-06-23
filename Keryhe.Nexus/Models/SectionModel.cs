namespace Keryhe.Nexus.Models;

public class SectionModel
{
    public int Id { get; set; }
    public int? ParentId { get; set; }
    public int CategoryId { get; set; }
    public string Name { get; set; } = "";
    public string DisplayName { get; set; } = "";
    public int SortOrder { get; set; }
    public string SectionType { get; set; } = "Card";
}
