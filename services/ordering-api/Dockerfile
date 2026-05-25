# eShop Ordering API Dockerfile
# Order processing service with CQRS pattern

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Labels for container registry
LABEL org.opencontainers.image.source="https://github.com/GABRIELS562/eshop-ordering-api"
LABEL org.opencontainers.image.description="eShop Ordering API - Order processing with CQRS pattern"
LABEL org.opencontainers.image.licenses="MIT"

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy application files if building from source
# COPY ["src/Services/Ordering/Ordering.API/Ordering.API.csproj", "src/Services/Ordering/Ordering.API/"]
# COPY ["src/Services/Ordering/Ordering.Domain/Ordering.Domain.csproj", "src/Services/Ordering/Ordering.Domain/"]
# COPY ["src/Services/Ordering/Ordering.Infrastructure/Ordering.Infrastructure.csproj", "src/Services/Ordering/Ordering.Infrastructure/"]
# RUN dotnet restore "src/Services/Ordering/Ordering.API/Ordering.API.csproj"
# COPY . .
# WORKDIR "/src/src/Services/Ordering/Ordering.API"
# RUN dotnet build "Ordering.API.csproj" -c Release -o /app/build

# FROM build AS publish
# RUN dotnet publish "Ordering.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

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
# ENTRYPOINT ["dotnet", "Ordering.API.dll"]

# Placeholder - actual application would be copied here
CMD ["echo", "Ordering API container - configure with actual application"]
