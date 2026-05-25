# eShop Mobile BFF

Backend-for-Frontend (BFF) aggregator microservice for mobile applications in the eShopOnContainers platform.

## Overview

The Mobile BFF provides an optimized API layer specifically designed for mobile applications. It aggregates data from multiple backend services, reduces the number of round trips, and provides mobile-friendly response formats optimized for bandwidth and battery consumption.

## Dependencies

| Dependency | Description |
|------------|-------------|
| **Catalog API** | Product information |
| **Basket API** | Shopping cart operations |
| **Ordering API** | Order management |
| **Identity API** | User authentication |

### gRPC Services

| Service | Description |
|---------|-------------|
| `Catalog.Grpc` | High-performance catalog queries |
| `Basket.Grpc` | Shopping cart operations |
| `Ordering.Grpc` | Order queries |

## Configuration

Environment variables (managed via Vault):

```
CATALOG_URL=http://catalog-api.eshop.svc.cluster.local
CATALOG_GRPC_URL=http://catalog-api.eshop.svc.cluster.local:81
BASKET_URL=http://basket-api.eshop.svc.cluster.local
BASKET_GRPC_URL=http://basket-api.eshop.svc.cluster.local:81
ORDERING_URL=http://ordering-api.eshop.svc.cluster.local
ORDERING_GRPC_URL=http://ordering-api.eshop.svc.cluster.local:81
IDENTITY_URL=http://identity-api.eshop.svc.cluster.local
```

## Local Development

### Prerequisites

- .NET 8 SDK
- Docker
- Running backend services (or mock servers)

### Build

```bash
docker build -t mobile-bff .
```

### Run

```bash
docker run -p 5120:80 \
  -e CatalogUrl="http://localhost:5101" \
  -e BasketUrl="http://localhost:5103" \
  -e OrderingUrl="http://localhost:5102" \
  -e IdentityUrl="http://localhost:5105" \
  mobile-bff
```

## API Endpoints

### Catalog Aggregation

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/catalog/items` | Get catalog items with optimized payload |
| GET | `/api/v1/catalog/items/{id}` | Get single item with related data |

### Basket Aggregation

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/basket/{id}` | Get basket with product details |
| POST | `/api/v1/basket` | Update basket with validation |
| POST | `/api/v1/basket/checkout` | Checkout with aggregated validation |

### Order Aggregation

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/orders` | Get orders with product thumbnails |
| GET | `/api/v1/orders/{id}` | Get order with full details |
| POST | `/api/v1/orders/draft` | Create draft order from basket |

### Health Endpoints

- `GET /health/live` - Liveness probe
- `GET /health/ready` - Readiness probe (includes downstream service checks)

## Response Optimization

The Mobile BFF applies several optimizations:

| Optimization | Description |
|--------------|-------------|
| Field Selection | Only returns fields needed by mobile UI |
| Image Sizing | Returns appropriate image URLs for mobile screens |
| Pagination | Mobile-optimized page sizes |
| Caching | Aggressive caching for static data |
| Compression | gzip/brotli response compression |

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
