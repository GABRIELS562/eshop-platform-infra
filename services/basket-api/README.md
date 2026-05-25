# eShop Basket API

Shopping cart management microservice for the eShopOnContainers platform.

## Overview

The Basket API manages shopping basket operations using Redis for high-performance caching.

## Dependencies

| Dependency | Description |
|------------|-------------|
| **Redis** | Session and basket data caching |
| **RabbitMQ** | Event bus for integration events |
| **Identity API** | User authentication |

### RabbitMQ Topics

| Event | Direction | Description |
|-------|-----------|-------------|
| `OrderStartedIntegrationEvent` | Publish | Sent when checkout initiated |
| `ProductPriceChangedIntegrationEvent` | Subscribe | Updates basket when prices change |
| `UserCheckoutAcceptedIntegrationEvent` | Publish | Checkout completion event |

## Configuration

Environment variables (managed via Vault):

```
REDIS_CONNECTION=redis.eshop.svc.cluster.local:6379
IDENTITY_URL=http://identity-api.eshop.svc.cluster.local
RABBITMQ_HOST=rabbitmq.eshop.svc.cluster.local
RABBITMQ_USER=eshop
RABBITMQ_PASS=[from-vault]
```

## Local Development

### Prerequisites

- .NET 8 SDK
- Docker
- Redis (local or container)

### Build

```bash
docker build -t basket-api .
```

### Run

```bash
docker run -p 5103:80 \
  -e ConnectionString="redis:6379" \
  -e IdentityUrl="http://localhost:5105" \
  basket-api
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/basket/{id}` | Get basket by customer ID |
| POST | `/api/v1/basket` | Update basket |
| DELETE | `/api/v1/basket/{id}` | Delete basket |
| POST | `/api/v1/basket/checkout` | Checkout basket |

### Health Endpoints

- `GET /health/live` - Liveness probe
- `GET /health/ready` - Readiness probe

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
