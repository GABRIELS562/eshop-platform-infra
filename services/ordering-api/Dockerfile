# eShop ordering-api - Stub Service
FROM nginx:alpine

LABEL org.opencontainers.image.source="https://github.com/GABRIELS562/eshop-platform-infra"
LABEL org.opencontainers.image.description="eShop ordering-api"

RUN mkdir -p /usr/share/nginx/html/api /usr/share/nginx/html/health && \
    echo '{"status":"healthy","service":"ordering-api","version":"1.0.0"}' > /usr/share/nginx/html/health/live && \
    echo '{"status":"ready","service":"ordering-api","version":"1.0.0"}' > /usr/share/nginx/html/health/ready && \
    echo '{"data":[],"service":"ordering-api"}' > /usr/share/nginx/html/api/index.html

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
        return 200 "{\"service\":\"ordering-api\",\"status\":\"running\"}"; \
    } \
}' > /etc/nginx/conf.d/default.conf

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget -q --spider http://localhost/health/live || exit 1

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
