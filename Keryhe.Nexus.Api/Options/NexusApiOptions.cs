namespace Keryhe.Nexus.Api.Options;

/// <summary>
/// Options for the Nexus REST API, configured via <c>AddNexusApi</c>.
/// </summary>
public class NexusApiOptions
{
    /// <summary>Name of the CORS policy registered for the Nexus API endpoints.</summary>
    public const string CorsPolicyName = "NexusCors";

    /// <summary>
    /// Origins allowed to call the API from a browser. Defaults to the Angular dev server
    /// (<c>http://localhost:4200</c>). Set this to the origin(s) the Angular app is served from.
    /// </summary>
    public string[] AllowedOrigins { get; set; } = ["http://localhost:4200"];
}
