# eShop Basket API Dockerfile
# Uses official eShopOnContainers image as base

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Labels for container registry
LABEL org.opencontainers.image.source="https://github.com/GABRIELS562/eshop-basket-api"
LABEL org.opencontainers.image.description="eShop Basket API - Shopping cart management service"
LABEL org.opencontainers.image.licenses="MIT"

# Use official eShopOnContainers basket-api as source
# This is a wrapper that can be customized if needed
FROM mcr.microsoft.com/dotnet-buildtools/prereqs:ubuntu-22.04 AS build
WORKDIR /src

# Copy application files if building from source
# COPY ["src/Services/Basket/Basket.API/Basket.API.csproj", "src/Services/Basket/Basket.API/"]
# RUN dotnet restore "src/Services/Basket/Basket.API/Basket.API.csproj"
# COPY . .
# WORKDIR "/src/src/Services/Basket/Basket.API"
# RUN dotnet build "Basket.API.csproj" -c Release -o /app/build

# For now, use the pre-built image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:80/health/live || exit 1

# Non-root user for security
RUN adduser --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

# Copy app from build stage (when building from source)
# COPY --from=build /app/publish .
# ENTRYPOINT ["dotnet", "Basket.API.dll"]

# Placeholder - actual application would be copied here
CMD ["echo", "Basket API container - configure with actual application"]
