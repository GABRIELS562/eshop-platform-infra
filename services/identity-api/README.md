# eShop Identity API

Authentication and Authorization microservice for the eShopOnContainers platform using ASP.NET Core Identity and OpenID Connect.

## Overview

The Identity API provides centralized authentication and authorization services using OpenID Connect and OAuth 2.0 protocols. It manages user registration, login, and token issuance for all eShop services.

## Dependencies

| Dependency | Description |
|------------|-------------|
| **SQL Server** | User identity database |
| **Redis** | Session caching (optional) |

### Clients Configuration

| Client | Grant Type | Description |
|--------|------------|-------------|
| `spa` | Authorization Code + PKCE | Web SPA application |
| `mobile` | Authorization Code + PKCE | Mobile applications |
| `basket-api` | Client Credentials | Service-to-service |
| `ordering-api` | Client Credentials | Service-to-service |
| `webhooks-api` | Client Credentials | Service-to-service |

## Configuration

Environment variables (managed via Vault):

```
SQLSERVER_CONNECTION=Server=sqlserver;Database=IdentityDb;User Id=sa;Password=[from-vault]
ISSUER_URL=http://identity-api.eshop.svc.cluster.local
SPA_CLIENT_URL=http://web-spa.eshop.svc.cluster.local
MOBILE_SHOPPING_AGG=http://mobile-bff.eshop.svc.cluster.local
BASKET_API_URL=http://basket-api.eshop.svc.cluster.local
ORDERING_API_URL=http://ordering-api.eshop.svc.cluster.local
WEBHOOKS_API_URL=http://webhook-api.eshop.svc.cluster.local
SIGNING_KEY=[from-vault]
```

## Local Development

### Prerequisites

- .NET 8 SDK
- Docker
- SQL Server (local or container)

### Build

```bash
docker build -t identity-api .
```

### Run

```bash
docker run -p 5105:80 \
  -e ConnectionString="Server=localhost;Database=IdentityDb;User Id=sa;Password=Pass@word" \
  -e IssuerUrl="http://localhost:5105" \
  -e SpaClient="http://localhost:5104" \
  identity-api
```

### Database Migration

```bash
dotnet ef database update --project src/Services/Identity/Identity.API
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/.well-known/openid-configuration` | OpenID Connect discovery |
| GET | `/connect/authorize` | Authorization endpoint |
| POST | `/connect/token` | Token endpoint |
| GET | `/connect/userinfo` | User info endpoint |
| POST | `/connect/revocation` | Token revocation |
| GET | `/connect/endsession` | End session |
| POST | `/api/v1/account/register` | User registration |
| POST | `/api/v1/account/login` | User login |
| GET | `/api/v1/account/user` | Get current user |

### Health Endpoints

- `GET /health/live` - Liveness probe
- `GET /health/ready` - Readiness probe (includes database check)

## Pipeline

```mermaid
graph LR
    A[Push to feature/*] --> B[PR to develop]
    B --> C[Lint & Security Scan]
    C --> D[Merge to develop]
    D --> E[Build & Push Image]
    E --> F[Update Helm values]
    F --> G[PR to main]
    G --> H[Merge to main]
    H --> I[ArgoCD Sync]
    I --> J[Production Deploy]
```

Workflow file: `.github/workflows/pipeline.yml`

## Related Resources

- [Platform Infrastructure](https://github.com/GABRIELS562/eshop-platform-infra)
- [eShopOnContainers](https://github.com/dotnet-architecture/eShopOnContainers)

## License

MIT License
