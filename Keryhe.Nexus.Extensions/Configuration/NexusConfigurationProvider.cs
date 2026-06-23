using Microsoft.Extensions.Configuration;
using Keryhe.Nexus.Models;
using Keryhe.Nexus.Services;

namespace Keryhe.Nexus.Extensions;

public class NexusConfigurationProvider : ConfigurationProvider, IDisposable
{
    private readonly INexusService _nexusService;
    private readonly TimeSpan _pollingInterval;
    private readonly object _reloadLock = new();
    private Timer? _timer;
    private DateTime? _lastMaxUpdatedAt;

    public NexusConfigurationProvider(INexusService nexusService, TimeSpan pollingInterval)
    {
        _nexusService = nexusService;
        _pollingInterval = pollingInterval;
    }

    public override void Load()
    {
        LoadData();

        if (_timer == null && _pollingInterval > TimeSpan.Zero)
            _timer = new Timer(_ => Poll(), null, _pollingInterval, _pollingInterval);
    }

    private void LoadData()
    {
        var data = new Dictionary<string, string?>(StringComparer.OrdinalIgnoreCase);

        var categories = _nexusService.GetAllCategoriesAsync().GetAwaiter().GetResult().ToList();
        foreach (var category in categories)
        {
            var sections = _nexusService.GetSectionsByCategoryAsync(category.Id).GetAwaiter().GetResult().ToList();
            var sectionPaths = BuildSectionPaths(category.Name, sections);
            var configs = _nexusService.GetConfigsBySectionIdsAsync(sections.Select(s => s.Id)).GetAwaiter().GetResult();

            foreach (var config in configs)
                if (sectionPaths.TryGetValue(config.SectionId, out var path))
                    data[$"{path}:{config.Name}"] = config.Value;
        }

        Data = data;
        _lastMaxUpdatedAt = _nexusService.GetMaxUpdatedAtAsync().GetAwaiter().GetResult();
    }

    private void Poll()
    {
        try
        {
            var current = _nexusService.GetMaxUpdatedAtAsync().GetAwaiter().GetResult();
            if (current == _lastMaxUpdatedAt) return;

            lock (_reloadLock)
            {
                current = _nexusService.GetMaxUpdatedAtAsync().GetAwaiter().GetResult();
                if (current == _lastMaxUpdatedAt) return;

                LoadData();
                OnReload();
            }
        }
        catch { }
    }

    private static Dictionary<int, string> BuildSectionPaths(string categoryName, List<SectionModel> sections)
    {
        var lookup = sections.ToDictionary(s => s.Id);
        return sections.ToDictionary(s => s.Id, s => BuildPath(categoryName, s, lookup));
    }

    private static string BuildPath(string categoryName, SectionModel section, Dictionary<int, SectionModel> lookup)
    {
        var parts = new List<string>();
        var current = section;
        while (true)
        {
            parts.Insert(0, current.Name);
            if (current.ParentId.HasValue && lookup.TryGetValue(current.ParentId.Value, out var parent))
                current = parent;
            else
                break;
        }
        parts.Insert(0, categoryName);
        return string.Join(":", parts);
    }

    public void Dispose()
    {
        _timer?.Dispose();
        _timer = null;
    }
}
