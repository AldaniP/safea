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

# Install Flutter stable (avoiding master branch potential issues)
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
# Use --no-pub to avoid extra network calls, build for release
RUN flutter build web --release

# Stage 2: Serve the application using Nginx
FROM nginx:alpine

# Copy the build output to the Nginx html directory
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy a custom nginx template to handle the PORT environment variable
RUN printf 'server {\n\
    listen %s;\n\
    location / {\n\
        root   /usr/share/nginx/html;\n\
        index  index.html index.htm;\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
}\n' '$PORT' > /etc/nginx/conf.d/default.conf.template

# Use a custom entrypoint to substitute the PORT variable
CMD ["/bin/sh", "-c", "envsubst < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"]
