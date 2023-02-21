using BuildingBlocks.Web;
using Duende.IdentityServer.Models;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.DependencyInjection;

namespace BuildingBlocks.Jwt;

using Microsoft.IdentityModel.Protocols.OpenIdConnect;

public static class JwtExtensions
{
    public static IServiceCollection AddJwt(this IServiceCollection services)
    {
        var jwtOptions = services.GetOptions<JwtBearerOptions>("Jwt");

        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(JwtBearerDefaults.AuthenticationScheme, options =>
            {
                options.Authority = jwtOptions.Authority;
                options.TokenValidationParameters.ValidateAudience = false;
                options.RequireHttpsMetadata = jwtOptions.RequireHttpsMetadata;
                options.Configuration = new OpenIdConnectConfiguration();
            });

        if (!string.IsNullOrEmpty(jwtOptions.Audience))
        {
            services.AddAuthorization(options =>
                options.AddPolicy(nameof(ApiScope), policy =>
                {
                    policy.RequireAuthenticatedUser();
                    policy.RequireClaim("scope", jwtOptions.Audience);
                })
            );
        }

        return services;
    }
}
