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

# Fetch dependencies
RUN flutter pub get

# Build for release (removing --web-renderer as it caused issues in some environments, defaulting to auto)
RUN flutter build web --release

# Stage 2: Serve the application using Nginx
FROM nginx:alpine

# Install bash for script support
RUN apk add --no-cache bash

# Copy the build output to the Nginx html directory
COPY --from=build /app/build/web /usr/share/nginx/html

# Create nginx configuration template
RUN echo 'server {' > /etc/nginx/conf.d/default.conf.template && \
    echo '    listen ${PORT};' >> /etc/nginx/conf.d/default.conf.template && \
    echo '    server_name localhost;' >> /etc/nginx/conf.d/default.conf.template && \
    echo '    root /usr/share/nginx/html;' >> /etc/nginx/conf.d/default.conf.template && \
    echo '    index index.html;' >> /etc/nginx/conf.d/default.conf.template && \
    echo '    location / {' >> /etc/nginx/conf.d/default.conf.template && \
    echo '        try_files $uri $uri/ /index.html;' >> /etc/nginx/conf.d/default.conf.template && \
    echo '    }' >> /etc/nginx/conf.d/default.conf.template && \
    echo '}' >> /etc/nginx/conf.d/default.conf.template

# Start command to substitute port and run nginx
CMD ["/bin/sh", "-c", "envsubst '${PORT}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"]
