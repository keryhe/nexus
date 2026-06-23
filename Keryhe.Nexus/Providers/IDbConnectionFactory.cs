using System;
using System.Data;

namespace Keryhe.Nexus.Providers;

public interface IDbConnectionFactory
{
    IDbConnection CreateConnection();
}
