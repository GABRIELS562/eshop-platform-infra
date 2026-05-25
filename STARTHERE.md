# eShop Platform Infrastructure

> A production-grade microservices platform based on Microsoft's eShopOnContainers reference architecture, deployed on K3s with GitOps practices.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Infrastructure Components](#infrastructure-components)
4. [Repository Structure](#repository-structure)
5. [Services Overview](#services-overview)
6. [Deployment Pipeline](#deployment-pipeline)
7. [Networking & Security](#networking--security)
8. [Monitoring & Observability](#monitoring--observability)
9. [Secret Management](#secret-management)
10. [Getting Started](#getting-started)
11. [Operations Guide](#operations-guide)
12. [Troubleshooting](#troubleshooting)

---

## Project Overview

### What is eShop Platform?

This project implements a cloud-native e-commerce platform using microservices architecture. It's inspired by Microsoft's [eShopOnContainers](https://github.com/dotnet-architecture/eShopOnContainers) reference application, adapted for deployment on a lightweight Kubernetes distribution (K3s).

### Key Features

- **Microservices Architecture**: 10 independent services with clear bounded contexts
- **GitOps Deployment**: ArgoCD for declarative, version-controlled deployments
- **Infrastructure as Code**: Terraform/Terragrunt for reproducible infrastructure
- **Observability Stack**: Prometheus, Grafana, Loki, and Seq for comprehensive monitoring
- **Secret Management**: HashiCorp Vault with External Secrets Operator
- **CI/CD Pipeline**: GitHub Actions with automated builds and deployments

### Technology Stack

| Category | Technology |
|----------|------------|
| Container Orchestration | K3s (Lightweight Kubernetes) |
| GitOps | ArgoCD |
| CI/CD | GitHub Actions |
| Container Registry | GitHub Container Registry (GHCR) |
| Secret Management | HashiCorp Vault |
| Service Mesh | Traefik Ingress |
| Monitoring | Prometheus + Grafana |
| Logging | Loki + Seq |
| Message Broker | RabbitMQ |
| Cache | Redis |
| Database | PostgreSQL |

---

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              INTERNET                                        │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         TRAEFIK INGRESS                                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │eshop.jagdev │  │api.eshop.  │  │identity.    │  │logs.eshop.  │        │
│  │ops.co.za   │  │jagdevops.  │  │eshop.jagdev │  │jagdevops.   │        │
│  │  (Web SPA)  │  │co.za (API) │  │ops.co.za    │  │co.za (Seq)  │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  │
┌─────────────────────────────────▼───────────────────────────────────────────┐
│                            SERVER 1 (K3s)                                    │
│                         100.89.26.128                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                      NAMESPACE: eshop                                  │  │
│  │                                                                        │  │
│  │  ┌─────────────────────── FRONTEND ───────────────────────────────┐   │  │
│  │  │                                                                 │   │  │
│  │  │  ┌───────────┐     ┌───────────┐     ┌───────────┐            │   │  │
│  │  │  │  Web SPA  │     │Mobile BFF │     │API Gateway│            │   │  │
│  │  │  │ (Angular) │     │           │     │ (Envoy)   │            │   │  │
│  │  │  └─────┬─────┘     └─────┬─────┘     └─────┬─────┘            │   │  │
│  │  │        │                 │                 │                   │   │  │
│  │  └────────┼─────────────────┼─────────────────┼───────────────────┘   │  │
│  │           │                 │                 │                        │  │
│  │  ┌────────▼─────────────────▼─────────────────▼───────────────────┐   │  │
│  │  │                     MICROSERVICES                               │   │  │
│  │  │                                                                 │   │  │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │   │  │
│  │  │  │ Catalog  │  │  Basket  │  │ Ordering │  │ Identity │       │   │  │
│  │  │  │   API    │  │   API    │  │   API    │  │   API    │       │   │  │
│  │  │  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘       │   │  │
│  │  │       │             │             │             │              │   │  │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐                     │   │  │
│  │  │  │ Payment  │  │ Webhook  │  │ Ordering │                     │   │  │
│  │  │  │   API    │  │   API    │  │ SignalR  │                     │   │  │
│  │  │  └────┬─────┘  └────┬─────┘  └────┬─────┘                     │   │  │
│  │  │       │             │             │                            │   │  │
│  │  └───────┼─────────────┼─────────────┼────────────────────────────┘   │  │
│  │          │             │             │                                 │  │
│  │  ┌───────▼─────────────▼─────────────▼────────────────────────────┐   │  │
│  │  │                    INFRASTRUCTURE                               │   │  │
│  │  │                                                                 │   │  │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │   │  │
│  │  │  │PostgreSQL│  │ RabbitMQ │  │  Redis   │  │   Seq    │       │   │  │
│  │  │  │  :5432   │  │  :5672   │  │  :6379   │  │   :80    │       │   │  │
│  │  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │   │  │
│  │  │                                                                 │   │  │
│  │  └─────────────────────────────────────────────────────────────────┘   │  │
│  │                                                                        │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │                      NAMESPACE: argocd                                  │  │
│  │  ┌──────────────────────────────────────────────────────────────────┐  │  │
│  │  │  ArgoCD Server  │  Application Controller  │  Repo Server        │  │  │
│  │  └──────────────────────────────────────────────────────────────────┘  │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                            SERVER 2 (Monitoring)                              │
│                              100.103.13.92                                    │
│                                                                              │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐                 │
│  │   Prometheus   │  │    Grafana     │  │     Vault      │                 │
│  │    :9090       │  │    :3000       │  │    :8200       │                 │
│  └────────────────┘  └────────────────┘  └────────────────┘                 │
│                                                                              │
│  ┌────────────────┐                                                          │
│  │      Loki      │                                                          │
│  │    :3100       │                                                          │
│  └────────────────┘                                                          │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Service Communication Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        REQUEST FLOW                                      │
└─────────────────────────────────────────────────────────────────────────┘

  User Request
       │
       ▼
  ┌─────────┐     ┌─────────────┐     ┌──────────────┐
  │ Traefik │────▶│  Web SPA    │────▶│ API Gateway  │
  │ Ingress │     │  (Frontend) │     │              │
  └─────────┘     └─────────────┘     └──────┬───────┘
                                             │
                    ┌────────────────────────┼────────────────────────┐
                    │                        │                        │
                    ▼                        ▼                        ▼
             ┌──────────┐            ┌──────────┐            ┌──────────┐
             │ Catalog  │            │  Basket  │            │ Ordering │
             │   API    │            │   API    │            │   API    │
             └────┬─────┘            └────┬─────┘            └────┬─────┘
                  │                       │                       │
                  │                       │                       │
     ┌────────────┼───────────────────────┼───────────────────────┤
     │            │                       │                       │
     ▼            ▼                       ▼                       ▼
┌─────────┐  ┌─────────┐            ┌─────────┐            ┌─────────┐
│PostgreSQL│  │RabbitMQ │◀──────────│  Redis  │            │PostgreSQL│
└─────────┘  └────┬────┘            └─────────┘            └─────────┘
                  │
                  │ Events
                  ▼
           ┌──────────────┐
           │   Payment    │
           │     API      │
           └──────────────┘


┌─────────────────────────────────────────────────────────────────────────┐
│                     EVENT-DRIVEN COMMUNICATION                           │
└─────────────────────────────────────────────────────────────────────────┘

  ┌──────────┐         ┌──────────────────────────────────┐
  │ Catalog  │────────▶│                                  │
  │   API    │ publish │                                  │
  └──────────┘         │                                  │
                       │         RabbitMQ                 │
  ┌──────────┐         │                                  │
  │ Ordering │────────▶│   Exchange: eshop.events        │
  │   API    │ publish │   Type: topic                    │
  └──────────┘         │                                  │
                       │   Queues:                        │
  ┌──────────┐         │   - catalog.events              │
  │  Basket  │────────▶│   - ordering.events             │
  │   API    │ publish │   - basket.events               │
  └──────────┘         │   - identity.events             │
                       │                                  │
                       └──────────────┬───────────────────┘
                                      │
           ┌──────────────────────────┼──────────────────────────┐
           │                          │                          │
           ▼                          ▼                          ▼
    ┌──────────┐              ┌──────────┐              ┌──────────┐
    │ Payment  │              │ Webhook  │              │ SignalR  │
    │   API    │              │   API    │              │  Hub     │
    └──────────┘              └──────────┘              └──────────┘
      subscribe                 subscribe                subscribe
```

### GitOps Deployment Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         CI/CD PIPELINE                                   │
└─────────────────────────────────────────────────────────────────────────┘

  Developer
      │
      │ git push
      ▼
  ┌─────────────────────────────────────────────────────────────────────┐
  │                        GitHub Repository                             │
  │                                                                      │
  │  feature/* ──────▶ develop ──────▶ main                             │
  │      │                │              │                               │
  │      │                │              │                               │
  │      ▼                ▼              ▼                               │
  │  PR Validation    Dev CI        Services CI/CD                       │
  │                                      │                               │
  └──────────────────────────────────────┼───────────────────────────────┘
                                         │
                                         ▼
  ┌─────────────────────────────────────────────────────────────────────┐
  │                      GitHub Actions                                  │
  │                                                                      │
  │  1. Detect Changed Services                                          │
  │  2. Build Docker Images (parallel)                                   │
  │  3. Push to GHCR                                                     │
  │  4. Update Helm values (image tags)                                  │
  │  5. Commit changes back to repo                                      │
  │                                                                      │
  └──────────────────────────────────────┬───────────────────────────────┘
                                         │
                                         │ Webhook / Poll
                                         ▼
  ┌─────────────────────────────────────────────────────────────────────┐
  │                         ArgoCD                                       │
  │                                                                      │
  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐             │
  │  │   Detect    │───▶│    Sync     │───▶│   Deploy    │             │
  │  │   Changes   │    │  Resources  │    │  to K3s     │             │
  │  └─────────────┘    └─────────────┘    └─────────────┘             │
  │                                                                      │
  │  Features:                                                           │
  │  - Auto-sync enabled                                                 │
  │  - Self-heal enabled                                                 │
  │  - Prune enabled                                                     │
  │                                                                      │
  └──────────────────────────────────────┬───────────────────────────────┘
                                         │
                                         ▼
  ┌─────────────────────────────────────────────────────────────────────┐
  │                      K3s Cluster                                     │
  │                                                                      │
  │  Namespace: eshop                                                    │
  │  ┌─────────────────────────────────────────────────────────────┐    │
  │  │  Deployments / StatefulSets / Services / Ingress / Secrets  │    │
  │  └─────────────────────────────────────────────────────────────┘    │
  │                                                                      │
  └─────────────────────────────────────────────────────────────────────┘
```

---

## Infrastructure Components

### Server Configuration

| Server | IP Address | Role | Components |
|--------|------------|------|------------|
| Server 1 | 100.89.26.128 | K3s Master | All workloads, ArgoCD, Traefik |
| Server 2 | 100.103.13.92 | Monitoring | Prometheus, Grafana, Loki, Vault |

### Kubernetes Resources

#### Namespaces

| Namespace | Purpose |
|-----------|---------|
| `eshop` | All eShop microservices and infrastructure |
| `argocd` | ArgoCD GitOps controller |
| `monitoring` | Prometheus stack, Promtail |
| `external-secrets` | External Secrets Operator |

#### Storage

| PVC | Size | Used By |
|-----|------|---------|
| postgresql-data | 10Gi | PostgreSQL |
| rabbitmq-data | 5Gi | RabbitMQ |
| redis-data | 2Gi | Redis |
| seq-data | 5Gi | Seq |

---

## Repository Structure

```
eshop-platform-infra/
│
├── .github/
│   └── workflows/
│       ├── services-ci.yml          # Main CI/CD - builds changed services
│       ├── develop-ci.yml           # Develop branch validation
│       ├── production-deploy.yml    # Production deployment workflow
│       └── pr-validation.yml        # Pull request checks
│
├── services/                         # Service Dockerfiles
│   ├── api-gateway/
│   │   └── Dockerfile
│   ├── basket-api/
│   │   └── Dockerfile
│   ├── catalog-api/
│   │   └── Dockerfile
│   ├── identity-api/
│   │   └── Dockerfile
│   ├── mobile-bff/
│   │   └── Dockerfile
│   ├── ordering-api/
│   │   └── Dockerfile
│   ├── ordering-signalr/
│   │   └── Dockerfile
│   ├── payment-api/
│   │   └── Dockerfile
│   ├── web-spa/
│   │   ├── Dockerfile
│   │   └── nginx.conf
│   └── webhook-api/
│       └── Dockerfile
│
├── helm-charts/                      # Helm charts for each service
│   ├── api-gateway/
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   │       ├── deployment.yaml
│   │       ├── service.yaml
│   │       ├── ingress.yaml
│   │       ├── hpa.yaml
│   │       ├── pdb.yaml
│   │       └── _helpers.tpl
│   ├── basket-api/
│   ├── catalog-api/
│   ├── identity-api/
│   ├── mobile-bff/
│   ├── ordering-api/
│   ├── ordering-signalr/
│   ├── payment-api/
│   ├── web-spa/
│   └── webhook-api/
│
├── k8s/                              # Raw Kubernetes manifests
│   ├── namespace.yaml
│   ├── rbac/
│   │   ├── service-accounts.yaml
│   │   └── roles.yaml
│   ├── network-policies/
│   │   ├── default-deny.yaml
│   │   ├── allow-dns.yaml
│   │   ├── allow-api-gateway-ingress.yaml
│   │   └── ... (12 policies)
│   ├── external-secrets/
│   │   ├── basket-api-secrets.yaml
│   │   ├── catalog-api-secrets.yaml
│   │   └── ... (6 secret definitions)
│   ├── ingress/
│   │   └── eshop-ingress.yaml
│   └── infrastructure/
│       ├── postgresql/
│       ├── rabbitmq/
│       ├── redis/
│       └── seq/
│
├── argocd/
│   ├── projects/
│   │   └── eshop-project.yaml
│   └── applications/
│       ├── api-gateway.yaml
│       ├── basket-api.yaml
│       ├── catalog-api.yaml
│       ├── identity-api.yaml
│       ├── mobile-bff.yaml
│       ├── ordering-api.yaml
│       ├── ordering-signalr.yaml
│       ├── payment-api.yaml
│       ├── postgresql.yaml
│       ├── rabbitmq.yaml
│       ├── redis.yaml
│       ├── seq.yaml
│       ├── web-spa.yaml
│       └── webhook-api.yaml
│
├── terraform/
│   ├── modules/
│   │   ├── k3s-namespace/
│   │   ├── argocd-application/
│   │   ├── vault-secrets/
│   │   └── network-policies/
│   └── environments/
│       ├── dev/
│       ├── staging/
│       └── prod/
│
├── terragrunt/
│   ├── terragrunt.hcl
│   └── environments/
│       ├── dev/
│       ├── staging/
│       └── prod/
│
├── monitoring/
│   ├── prometheus/
│   │   └── servicemonitor.yaml
│   ├── alerts/
│   │   ├── eshop-alerts.yml
│   │   └── prometheus-rule.yaml
│   ├── dashboards/
│   │   └── eshop-overview.json
│   └── loki/
│       └── queries.yaml
│
├── ansible/
│   ├── inventory/
│   ├── playbooks/
│   └── roles/
│
├── STARTHERE.md                      # This file
├── CONTRIBUTING.md                   # Contribution guidelines
└── README.md                         # Quick start
```

---

## Services Overview

### Business Services

| Service | Port | Description | Dependencies |
|---------|------|-------------|--------------|
| **Catalog API** | 80 | Product catalog management | PostgreSQL, RabbitMQ |
| **Basket API** | 80 | Shopping cart operations | Redis, RabbitMQ, Identity |
| **Ordering API** | 80 | Order processing and management | PostgreSQL, RabbitMQ, Identity |
| **Identity API** | 80 | Authentication and authorization | PostgreSQL |
| **Payment API** | 80 | Payment processing | RabbitMQ |
| **Webhook API** | 80 | External integrations | RabbitMQ |

### Frontend & Gateway Services

| Service | Port | Description |
|---------|------|-------------|
| **Web SPA** | 80 | Angular single-page application |
| **Mobile BFF** | 80 | Backend for Frontend (mobile apps) |
| **API Gateway** | 80 | API aggregation and routing |
| **Ordering SignalR** | 80 | Real-time order updates |

### Infrastructure Services

| Service | Port | Description |
|---------|------|-------------|
| **PostgreSQL** | 5432 | Relational database |
| **RabbitMQ** | 5672, 15672 | Message broker |
| **Redis** | 6379 | Caching layer |
| **Seq** | 80, 5341 | Structured logging |

### Service Dependencies Matrix

```
                    ┌─────────┬─────────┬─────────┬─────────┬─────────┐
                    │ Postgres│ RabbitMQ│  Redis  │ Identity│   Seq   │
┌───────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Catalog API       │    ●    │    ●    │         │         │    ●    │
│ Basket API        │         │    ●    │    ●    │    ●    │    ●    │
│ Ordering API      │    ●    │    ●    │         │    ●    │    ●    │
│ Identity API      │    ●    │         │         │         │    ●    │
│ Payment API       │         │    ●    │         │         │    ●    │
│ Webhook API       │         │    ●    │         │         │    ●    │
│ Web SPA           │         │         │         │         │         │
│ Mobile BFF        │         │         │         │    ●    │    ●    │
│ API Gateway       │         │         │         │         │    ●    │
│ Ordering SignalR  │         │    ●    │         │    ●    │    ●    │
└───────────────────┴─────────┴─────────┴─────────┴─────────┴─────────┘

● = Required dependency
```

---

## Deployment Pipeline

### Branch Strategy

```
feature/xyz ────┐
                │
feature/abc ────┼────▶ develop ────▶ main
                │         │           │
feature/123 ────┘         │           │
                          │           │
                    Continuous    Production
                    Integration   Deployment
```

| Branch | Purpose | Protection |
|--------|---------|------------|
| `main` | Production-ready code | PR required, 1 approval, status checks |
| `develop` | Integration branch | Direct push allowed |
| `feature/*` | Feature development | PR to develop |

### CI/CD Workflow

1. **On Push to `develop`**:
   - Run linting and validation
   - No image builds

2. **On PR to `main`**:
   - Validate PR
   - Run status checks

3. **On Push to `main`**:
   - Detect changed services
   - Build Docker images in parallel
   - Push to GHCR
   - Update Helm values with new image tags
   - ArgoCD auto-syncs deployments

### Image Tagging Strategy

| Tag | Description |
|-----|-------------|
| `latest` | Latest main branch build |
| `<short-sha>` | Git commit SHA (7 chars) |
| `<branch>` | Branch name |
| `pr-<number>` | Pull request builds |

---

## Networking & Security

### Network Policies

The cluster implements a **zero-trust network model** with default-deny policies:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        NETWORK POLICIES                                  │
└─────────────────────────────────────────────────────────────────────────┘

  DEFAULT: All ingress and egress DENIED

  Allowed Traffic:
  ┌─────────────────────────────────────────────────────────────────────┐
  │                                                                      │
  │  Internet ──▶ Traefik ──▶ Web SPA ──▶ API Gateway                   │
  │                    │                       │                         │
  │                    └──▶ Identity API ◀─────┤                         │
  │                                            │                         │
  │  API Gateway ──▶ [All Backend Services]    │                         │
  │                                            │                         │
  │  Backend Services ──▶ PostgreSQL           │                         │
  │                  ──▶ RabbitMQ              │                         │
  │                  ──▶ Redis                 │                         │
  │                  ──▶ Seq                   │                         │
  │                                            │                         │
  │  All Pods ──▶ DNS (kube-dns)               │                         │
  │                                            │                         │
  └─────────────────────────────────────────────────────────────────────┘
```

### Ingress Configuration

| Host | Service | Path |
|------|---------|------|
| `eshop.jagdevops.co.za` | web-spa | / |
| `api.eshop.jagdevops.co.za` | api-gateway | / |
| `identity.eshop.jagdevops.co.za` | identity-api | / |
| `logs.eshop.jagdevops.co.za` | seq | / |

### RBAC Configuration

| Role | Permissions |
|------|-------------|
| `eshop-developer` | Get, List, Watch pods, services, deployments |
| `eshop-deployer` | Create, Update, Delete deployments, services |
| `eshop-readonly` | Get, List, Watch all resources |

---

## Monitoring & Observability

### Metrics Stack

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        METRICS PIPELINE                                  │
└─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
  │   Service   │────▶│ Prometheus  │────▶│   Grafana   │
  │  /metrics   │     │  (scrape)   │     │ (visualize) │
  └─────────────┘     └─────────────┘     └─────────────┘
        │
        │ ServiceMonitor
        ▼
  ┌─────────────────────────────────────────────────────────────────────┐
  │ Monitored Services:                                                  │
  │ - eshop-services (all microservices)                                 │
  │ - eshop-infrastructure (PostgreSQL, RabbitMQ, Redis)                │
  │ - eshop-seq                                                          │
  └─────────────────────────────────────────────────────────────────────┘
```

### Logging Stack

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        LOGGING PIPELINE                                  │
└─────────────────────────────────────────────────────────────────────────┘

  Application Logs                    Structured Logs
        │                                   │
        ▼                                   ▼
  ┌─────────────┐                    ┌─────────────┐
  │  Promtail   │                    │     Seq     │
  │  (collect)  │                    │  (ingest)   │
  └──────┬──────┘                    └──────┬──────┘
         │                                  │
         ▼                                  ▼
  ┌─────────────┐                    ┌─────────────┐
  │    Loki     │                    │  Seq UI     │
  │   (store)   │                    │  (search)   │
  └──────┬──────┘                    └─────────────┘
         │
         ▼
  ┌─────────────┐
  │   Grafana   │
  │  (explore)  │
  └─────────────┘
```

### Alerts

| Alert | Severity | Description |
|-------|----------|-------------|
| `EshopServiceDown` | Critical | Service unreachable for 2+ minutes |
| `EshopHighErrorRate` | Critical | HTTP 5xx errors > 5% |
| `EshopPodRestartLoop` | Warning | Pod restarted 3+ times in 5 minutes |
| `EshopHPAMaxReplicas` | Warning | HPA at maximum for 15+ minutes |
| `RabbitMQHighQueueDepth` | Warning | Queue depth > 1000 messages |
| `RedisHighMemoryUsage` | Warning | Memory usage > 80% |
| `PostgreSQLHighConnections` | Warning | Connection usage > 80% |
| `EshopHighLatencyP99` | Warning | P99 latency > 1 second |

### Dashboards

Access Grafana at: `http://100.103.13.92:3000`

| Dashboard | Description |
|-----------|-------------|
| **eShop Platform Overview** | Service health, request rates, error rates |
| **Infrastructure** | PostgreSQL, RabbitMQ, Redis metrics |
| **Kubernetes** | Node resources, pod status |

---

## Secret Management

### Vault Integration

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        SECRET FLOW                                       │
└─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────┐                    ┌─────────────┐
  │   Vault     │◀───────────────────│  External   │
  │  (Server2)  │    Authenticate    │  Secrets    │
  │             │                    │  Operator   │
  └──────┬──────┘                    └──────┬──────┘
         │                                  │
         │ secret/eshop/*                   │ Sync
         │                                  │
         ▼                                  ▼
  ┌─────────────┐                    ┌─────────────┐
  │  Secrets    │                    │ K8s Secrets │
  │  in Vault   │ ──────────────────▶│  in eshop   │
  └─────────────┘    ExternalSecret  └─────────────┘
```

### Secret Paths

| Vault Path | K8s Secret | Used By |
|------------|------------|---------|
| `secret/eshop/global` | `global-secrets` | All services |
| `secret/eshop/basket-api` | `basket-api-secrets` | Basket API |
| `secret/eshop/catalog-api` | `catalog-api-secrets` | Catalog API |
| `secret/eshop/ordering-api` | `ordering-api-secrets` | Ordering API |
| `secret/eshop/identity-api` | `identity-api-secrets` | Identity API |
| `secret/eshop/payment-api` | `payment-api-secrets` | Payment API |

---

## Getting Started

### Prerequisites

- SSH access to Server 1 and Server 2
- GitHub account with repository access
- `kubectl` configured for the K3s cluster
- `gh` CLI authenticated

### Quick Verification

```bash
# Check cluster status
ssh server1 "sudo kubectl get nodes"

# Check eShop namespace
ssh server1 "sudo kubectl get pods -n eshop"

# Check ArgoCD applications
ssh server1 "sudo kubectl get applications -n argocd"

# Check ingress
ssh server1 "sudo kubectl get ingress -n eshop"
```

### Access URLs

| Service | URL |
|---------|-----|
| Web Application | https://eshop.jagdevops.co.za |
| API Gateway | https://api.eshop.jagdevops.co.za |
| Identity Service | https://identity.eshop.jagdevops.co.za |
| Seq Logs | https://logs.eshop.jagdevops.co.za |
| Grafana | http://100.103.13.92:3000 |
| Vault | http://100.103.13.92:8200 |
| ArgoCD | (via kubectl port-forward) |

### Deploy a New Service Version

1. Make changes to service code
2. Create feature branch: `git checkout -b feature/my-change`
3. Commit and push: `git push origin feature/my-change`
4. Create PR to `develop`
5. Merge to `develop` for testing
6. Create PR from `develop` to `main`
7. Merge to `main` triggers:
   - Docker build
   - Image push to GHCR
   - ArgoCD auto-sync

---

## Operations Guide

### Scaling Services

```bash
# Manual scale (temporary)
ssh server1 "sudo kubectl scale deployment catalog-api -n eshop --replicas=3"

# Update HPA (persistent)
# Edit helm-charts/<service>/values.yaml
# Change autoscaling.minReplicas / maxReplicas
# Commit and push to trigger ArgoCD sync
```

### Rolling Back

```bash
# Via ArgoCD UI or CLI
ssh server1 "sudo kubectl -n argocd patch application catalog-api \
  -p '{\"operation\":{\"sync\":{\"revision\":\"<previous-commit-sha>\"}}}' \
  --type merge"

# Via kubectl
ssh server1 "sudo kubectl rollout undo deployment/catalog-api -n eshop"
```

### Viewing Logs

```bash
# Pod logs
ssh server1 "sudo kubectl logs -n eshop -l app=catalog-api --tail=100"

# Seq UI
# Navigate to https://logs.eshop.jagdevops.co.za

# Grafana/Loki
# Navigate to Grafana > Explore > Select Loki datasource
```

### Database Access

```bash
# PostgreSQL
ssh server1 "sudo kubectl exec -it postgresql-0 -n eshop -- \
  psql -U eshop -d eshop"

# Redis
ssh server1 "sudo kubectl exec -it redis-0 -n eshop -- redis-cli"

# RabbitMQ Management
ssh server1 "sudo kubectl port-forward svc/rabbitmq 15672:15672 -n eshop"
# Access: http://localhost:15672
```

---

## Troubleshooting

### Common Issues

#### Pod in CrashLoopBackOff

```bash
# Check logs
ssh server1 "sudo kubectl logs <pod-name> -n eshop --previous"

# Check events
ssh server1 "sudo kubectl describe pod <pod-name> -n eshop"

# Common causes:
# - Missing secrets (check ExternalSecrets)
# - Database connection issues
# - Insufficient resources
```

#### ArgoCD App OutOfSync

```bash
# Force refresh
ssh server1 "sudo kubectl -n argocd patch application <app-name> \
  -p '{\"metadata\":{\"annotations\":{\"argocd.argoproj.io/refresh\":\"hard\"}}}' \
  --type merge"

# Check sync status
ssh server1 "sudo kubectl get application <app-name> -n argocd -o yaml"
```

#### Image Pull Errors

```bash
# Check secret exists
ssh server1 "sudo kubectl get secret ghcr-pull-secret -n eshop"

# Verify secret data
ssh server1 "sudo kubectl get secret ghcr-pull-secret -n eshop -o yaml"

# Re-create if needed
GH_TOKEN=$(gh auth token)
ssh server1 "sudo kubectl create secret docker-registry ghcr-pull-secret \
  --namespace=eshop \
  --docker-server=ghcr.io \
  --docker-username=GABRIELS562 \
  --docker-password='${GH_TOKEN}'"
```

#### Service Not Responding

```bash
# Check service endpoints
ssh server1 "sudo kubectl get endpoints <service-name> -n eshop"

# Check network policies
ssh server1 "sudo kubectl get networkpolicies -n eshop"

# Test connectivity
ssh server1 "sudo kubectl run test --rm -it --image=busybox -- \
  wget -qO- http://<service-name>.eshop.svc.cluster.local/health"
```

### Health Check Commands

```bash
# Overall cluster health
ssh server1 "sudo kubectl get nodes && sudo kubectl top nodes"

# eShop namespace health
ssh server1 "sudo kubectl get pods -n eshop -o wide"

# ArgoCD sync status
ssh server1 "sudo kubectl get applications -n argocd"

# Infrastructure services
ssh server1 "sudo kubectl exec -n eshop postgresql-0 -- pg_isready"
ssh server1 "sudo kubectl exec -n eshop redis-0 -- redis-cli ping"
ssh server1 "sudo kubectl exec -n eshop rabbitmq-0 -- rabbitmq-diagnostics ping"
```

---

## Support

- **Repository**: https://github.com/GABRIELS562/eshop-platform-infra
- **ArgoCD**: Access via `kubectl port-forward`
- **Monitoring**: Grafana at http://100.103.13.92:3000
- **Logs**: Seq at https://logs.eshop.jagdevops.co.za

---

*Last Updated: May 2026*
