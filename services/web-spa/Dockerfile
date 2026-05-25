# eShop Web SPA Dockerfile
# Angular Single Page Application frontend

# Build stage
FROM node:20-alpine AS build
WORKDIR /app

# Labels for container registry
LABEL org.opencontainers.image.source="https://github.com/GABRIELS562/eshop-web-spa"
LABEL org.opencontainers.image.description="eShop Web SPA - Angular Single Page Application"
LABEL org.opencontainers.image.licenses="MIT"

# Install dependencies
# COPY package*.json ./
# RUN npm ci

# Copy source and build
# COPY . .
# RUN npm run build -- --configuration production

# Production stage with nginx
FROM nginx:alpine AS final
WORKDIR /usr/share/nginx/html

# Install curl for health checks
RUN apk add --no-cache curl

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built application
# COPY --from=build /app/dist/WebSPA .

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:80/health || exit 1

# Non-root user for security
RUN adduser -D -H -s /sbin/nologin nginx-user && \
    chown -R nginx-user:nginx-user /usr/share/nginx/html && \
    chown -R nginx-user:nginx-user /var/cache/nginx && \
    chown -R nginx-user:nginx-user /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown nginx-user:nginx-user /var/run/nginx.pid

USER nginx-user

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
