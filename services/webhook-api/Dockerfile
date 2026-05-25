# eShop webhook-api - Stub Service
FROM nginx:alpine

LABEL org.opencontainers.image.source="https://github.com/GABRIELS562/eshop-platform-infra"
LABEL org.opencontainers.image.description="eShop webhook-api"

RUN mkdir -p /usr/share/nginx/html/api /usr/share/nginx/html/health && \
    echo '{"status":"healthy","service":"webhook-api","version":"1.0.0"}' > /usr/share/nginx/html/health/live && \
    echo '{"status":"ready","service":"webhook-api","version":"1.0.0"}' > /usr/share/nginx/html/health/ready && \
    echo '{"data":[],"service":"webhook-api"}' > /usr/share/nginx/html/api/index.html

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
        return 200 "{\"service\":\"webhook-api\",\"status\":\"running\"}"; \
    } \
}' > /etc/nginx/conf.d/default.conf

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget -q --spider http://localhost/health/live || exit 1

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
