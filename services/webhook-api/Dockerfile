# eShop Webhook API Dockerfile
# Webhook subscription and delivery service

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Labels for container registry
LABEL org.opencontainers.image.source="https://github.com/GABRIELS562/eshop-webhook-api"
LABEL org.opencontainers.image.description="eShop Webhook API - Webhook subscription and delivery service"
LABEL org.opencontainers.image.licenses="MIT"

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy application files if building from source
# COPY ["src/Services/Webhooks/Webhooks.API/Webhooks.API.csproj", "src/Services/Webhooks/Webhooks.API/"]
# RUN dotnet restore "src/Services/Webhooks/Webhooks.API/Webhooks.API.csproj"
# COPY . .
# WORKDIR "/src/src/Services/Webhooks/Webhooks.API"
# RUN dotnet build "Webhooks.API.csproj" -c Release -o /app/build

# FROM build AS publish
# RUN dotnet publish "Webhooks.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Final stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Install curl for health checks
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:80/health/live || exit 1

# Non-root user for security
RUN adduser --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

# Copy app from build stage (when building from source)
# COPY --from=publish /app/publish .
# ENTRYPOINT ["dotnet", "Webhooks.API.dll"]

# Placeholder - actual application would be copied here
CMD ["echo", "Webhook API container - configure with actual application"]
