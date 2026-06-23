namespace Keryhe.Nexus.Services;

public sealed class NullEncryptionService : IEncryptionService
{
    public string Encrypt(string plaintext) => plaintext;
    public string Decrypt(string ciphertext) => ciphertext;
}
