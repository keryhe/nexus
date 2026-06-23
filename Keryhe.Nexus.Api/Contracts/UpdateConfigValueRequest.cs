namespace Keryhe.Nexus.Api.Contracts;

/// <summary>
/// Request body for updating a config value. Encryption is handled transparently
/// by <c>NexusService</c> based on <see cref="IsEncrypted"/> — send the plaintext value.
/// </summary>
/// <param name="Value">The new value, or <c>null</c> to clear it.</param>
/// <param name="IsEncrypted">Whether the value should be stored encrypted.</param>
public record UpdateConfigValueRequest(string? Value, bool IsEncrypted = false);
