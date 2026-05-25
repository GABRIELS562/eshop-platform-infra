# eShop Web SPA - Stub Frontend
FROM nginx:alpine

LABEL org.opencontainers.image.source="https://github.com/GABRIELS562/eshop-platform-infra"
LABEL org.opencontainers.image.description="eShop Web SPA - Angular Single Page Application"

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create stub HTML page
RUN mkdir -p /usr/share/nginx/html && \
    echo '<!DOCTYPE html>\
<html lang="en">\
<head>\
    <meta charset="UTF-8">\
    <meta name="viewport" content="width=device-width, initial-scale=1.0">\
    <title>eShop Platform</title>\
    <style>\
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; \
               margin: 0; padding: 40px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); \
               min-height: 100vh; color: white; }\
        .container { max-width: 800px; margin: 0 auto; }\
        h1 { font-size: 3rem; margin-bottom: 1rem; }\
        .card { background: rgba(255,255,255,0.1); padding: 20px; border-radius: 10px; margin: 20px 0; }\
        .services { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 15px; }\
        .service { background: rgba(255,255,255,0.15); padding: 15px; border-radius: 8px; text-align: center; }\
        .status { display: inline-block; width: 10px; height: 10px; border-radius: 50%; background: #4caf50; margin-right: 8px; }\
    </style>\
</head>\
<body>\
    <div class="container">\
        <h1>eShop Platform</h1>\
        <p>Microsoft eShopOnContainers - Microservices Reference Implementation</p>\
        <div class="card">\
            <h2>Platform Status</h2>\
            <div class="services">\
                <div class="service"><span class="status"></span>Catalog API</div>\
                <div class="service"><span class="status"></span>Basket API</div>\
                <div class="service"><span class="status"></span>Ordering API</div>\
                <div class="service"><span class="status"></span>Identity API</div>\
                <div class="service"><span class="status"></span>Payment API</div>\
                <div class="service"><span class="status"></span>API Gateway</div>\
            </div>\
        </div>\
        <div class="card">\
            <h2>Quick Links</h2>\
            <p><a href="/api" style="color: #fff;">API Documentation</a></p>\
            <p><a href="https://logs.eshop.jagdevops.co.za" style="color: #fff;">Seq Log Viewer</a></p>\
        </div>\
    </div>\
</body>\
</html>' > /usr/share/nginx/html/index.html

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget -q --spider http://localhost/health || exit 1

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
