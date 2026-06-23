using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Keryhe.Nexus.Api.Contracts;
using Keryhe.Nexus.Api.Options;
using Keryhe.Nexus.Services;

namespace Keryhe.Nexus.Api.Extensions;

public static class EndpointRouteBuilderExtensions
{
    /// <summary>
    /// Maps the Nexus REST endpoints under <paramref name="prefix"/> (default <c>/api/nexus</c>).
    /// Endpoints are thin pass-throughs to <see cref="INexusService"/>. Requires the services
    /// registered by <c>AddNexusApi</c>.
    /// </summary>
    public static RouteGroupBuilder MapNexusApi(
        this IEndpointRouteBuilder endpoints,
        string prefix = "/api/nexus")
    {
        var group = endpoints.MapGroup(prefix)
            .RequireCors(NexusApiOptions.CorsPolicyName)
            .WithTags("Nexus");

        group.MapGet("/categories", async (INexusService service) =>
                Results.Ok(await service.GetAllCategoriesAsync()))
            .WithName("GetCategories");

        group.MapGet("/categories/{id:int}", async (int id, INexusService service) =>
            {
                var category = await service.GetCategoryByIdAsync(id);
                return category is null ? Results.NotFound() : Results.Ok(category);
            })
            .WithName("GetCategoryById");

        group.MapGet("/categories/{categoryId:int}/sections", async (int categoryId, INexusService service) =>
                Results.Ok(await service.GetSectionsByCategoryAsync(categoryId)))
            .WithName("GetSectionsByCategory");

        group.MapGet("/configs", async (int[] sectionId, INexusService service) =>
                Results.Ok(await service.GetConfigsBySectionIdsAsync(sectionId)))
            .WithName("GetConfigsBySectionIds");

        group.MapGet("/configs/max-updated-at", async (INexusService service) =>
                Results.Ok(new { maxUpdatedAt = await service.GetMaxUpdatedAtAsync() }))
            .WithName("GetConfigsMaxUpdatedAt");

        group.MapPut("/configs/{id:int}/value", async (int id, UpdateConfigValueRequest request, INexusService service) =>
            {
                await service.UpdateConfigValueAsync(id, request.Value, request.IsEncrypted);
                return Results.NoContent();
            })
            .WithName("UpdateConfigValue");

        group.MapGet("/dropdown-lists/{id:int}/items", async (int id, INexusService service) =>
                Results.Ok(await service.GetDropdownListItemsAsync(id)))
            .WithName("GetDropdownListItems");

        return group;
    }
}
