# Stage 1: Build the Flutter Web application
FROM debian:latest AS build

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    libglu1-mesa \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter stable
RUN git clone -b stable https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter doctor
RUN flutter config --enable-web

# Set the working directory
WORKDIR /app

# Copy project files
COPY . .

# Fetch dependencies and build web
RUN flutter pub get
# Build for release with CanvasKit for better performance, or auto
RUN flutter build web --release --web-renderer canvaskit

# Stage 2: Serve the application using Nginx
FROM nginx:alpine

# Install envsubst (included in alpine) and bash for script
RUN apk add --no-cache bash

# Copy the build output to the Nginx html directory
COPY --from=build /app/build/web /usr/share/nginx/html

# Create a robust nginx configuration
RUN printf 'server {\n\
    listen %s;\n\
    server_name localhost;\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
    location / {\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
    # Caching for static assets\n\
    location ~* \.(?:css|js|jpg|jpeg|gif|png|ico|cur|gz|svg|svgz|mp4|ogg|ogv|webm|htc)$ {\n\
        expires 1M;\n\
        access_log off;\n\
        add_header Cache-Control "public";\n\
    }\n\
}\n' '$PORT' > /etc/nginx/conf.d/default.conf.template

# Start command to substitute port and run nginx
CMD ["/bin/sh", "-c", "envsubst '$PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"]
