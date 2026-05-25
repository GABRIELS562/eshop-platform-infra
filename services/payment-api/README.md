# eShop Payment API

Payment processing microservice for the eShopOnContainers platform.

## Overview

The Payment API handles payment processing for orders, integrating with payment gateways and publishing payment status events. It operates as an event-driven service, responding to order payment requests and notifying the ordering service of payment results.

## Dependencies

| Dependency | Description |
|------------|-------------|
| **RabbitMQ** | Event bus for integration events |
| **Payment Gateway** | External payment processor (Stripe, PayPal, etc.) |

### RabbitMQ Topics

| Event | Direction | Description |
|-------|-----------|-------------|
| `OrderStatusChangedToStockConfirmedIntegrationEvent` | Subscribe | Triggers payment processing |
| `OrderPaymentSucceededIntegrationEvent` | Publish | Payment completed successfully |
| `OrderPaymentFailedIntegrationEvent` | Publish | Payment failed |

## Configuration

Environment variables (managed via Vault):

```
RABBITMQ_HOST=rabbitmq.eshop.svc.cluster.local
RABBITMQ_USER=eshop
RABBITMQ_PASS=[from-vault]
PAYMENT_GATEWAY_API_KEY=[from-vault]
PAYMENT_GATEWAY_SECRET=[from-vault]
PAYMENT_GATEWAY_URL=https://api.stripe.com/v1
```

## Local Development

### Prerequisites

- .NET 8 SDK
- Docker
- RabbitMQ (local or container)

### Build

```bash
docker build -t payment-api .
```

### Run

```bash
docker run -p 5108:80 \
  -e EventBusConnection="localhost" \
  -e PaymentGatewayApiKey="sk_test_..." \
  payment-api
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/payment/process` | Process payment (internal) |
| GET | `/api/v1/payment/status/{paymentId}` | Get payment status |
| POST | `/api/v1/payment/refund` | Process refund |

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
