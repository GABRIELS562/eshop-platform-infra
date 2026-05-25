# eShop API Gateway Dockerfile
# API Gateway using YARP (Yet Another Reverse Proxy)

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Labels for container registry
LABEL org.opencontainers.image.source="https://github.com/GABRIELS562/eshop-api-gateway"
LABEL org.opencontainers.image.description="eShop API Gateway - Unified API routing and load balancing"
LABEL org.opencontainers.image.licenses="MIT"

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy application files if building from source
# COPY ["src/ApiGateways/Envoy/Web.Bff.Shopping/Web.Shopping.HttpAggregator/Web.Shopping.HttpAggregator.csproj", "src/ApiGateways/Envoy/Web.Bff.Shopping/Web.Shopping.HttpAggregator/"]
# RUN dotnet restore "src/ApiGateways/Envoy/Web.Bff.Shopping/Web.Shopping.HttpAggregator/Web.Shopping.HttpAggregator.csproj"
# COPY . .
# WORKDIR "/src/src/ApiGateways/Envoy/Web.Bff.Shopping/Web.Shopping.HttpAggregator"
# RUN dotnet build "Web.Shopping.HttpAggregator.csproj" -c Release -o /app/build

# FROM build AS publish
# RUN dotnet publish "Web.Shopping.HttpAggregator.csproj" -c Release -o /app/publish /p:UseAppHost=false

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
# ENTRYPOINT ["dotnet", "Web.Shopping.HttpAggregator.dll"]

# Placeholder - actual application would be copied here
CMD ["echo", "API Gateway container - configure with actual application"]
