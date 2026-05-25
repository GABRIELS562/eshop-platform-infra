# eShop Catalog API - Stub Service
# Placeholder service for platform demonstration

FROM nginx:alpine

LABEL org.opencontainers.image.source="https://github.com/GABRIELS562/eshop-platform-infra"
LABEL org.opencontainers.image.description="eShop Catalog API - Product catalog management service"

# Create health endpoint and stub API
RUN mkdir -p /usr/share/nginx/html/api /usr/share/nginx/html/health && \
    echo '{"status":"healthy","service":"catalog-api","version":"1.0.0"}' > /usr/share/nginx/html/health/live && \
    echo '{"status":"ready","service":"catalog-api","version":"1.0.0"}' > /usr/share/nginx/html/health/ready && \
    echo '{"items":[{"id":1,"name":"Product 1","price":9.99},{"id":2,"name":"Product 2","price":19.99}],"totalCount":2}' > /usr/share/nginx/html/api/catalog && \
    echo '{"id":1,"name":"Product 1","description":"Sample product","price":9.99,"pictureFileName":"sample.jpg"}' > /usr/share/nginx/html/api/items

# Custom nginx config for JSON responses
RUN echo 'server { \
    listen 80; \
    location /health { \
        default_type application/json; \
        alias /usr/share/nginx/html/health/; \
    } \
    location /api { \
        default_type application/json; \
        alias /usr/share/nginx/html/api/; \
    } \
    location / { \
        default_type application/json; \
        return 200 "{\"service\":\"catalog-api\",\"status\":\"running\"}"; \
    } \
}' > /etc/nginx/conf.d/default.conf

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget -q --spider http://localhost/health/live || exit 1

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
