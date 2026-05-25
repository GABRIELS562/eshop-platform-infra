# eShop mobile-bff - Stub Service
FROM nginx:alpine

LABEL org.opencontainers.image.source="https://github.com/GABRIELS562/eshop-platform-infra"
LABEL org.opencontainers.image.description="eShop mobile-bff"

RUN mkdir -p /usr/share/nginx/html/api /usr/share/nginx/html/health && \
    echo '{"status":"healthy","service":"mobile-bff","version":"1.0.0"}' > /usr/share/nginx/html/health/live && \
    echo '{"status":"ready","service":"mobile-bff","version":"1.0.0"}' > /usr/share/nginx/html/health/ready && \
    echo '{"data":[],"service":"mobile-bff"}' > /usr/share/nginx/html/api/index.html

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
        return 200 "{\"service\":\"mobile-bff\",\"status\":\"running\"}"; \
    } \
}' > /etc/nginx/conf.d/default.conf

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget -q --spider http://localhost/health/live || exit 1

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
