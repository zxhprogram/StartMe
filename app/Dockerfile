# Build stage
FROM ghcr.io/cirruslabs/flutter:3.41.6 AS builder

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build web application
RUN flutter build web --release

# Final stage - Use nginx to serve the web app
FROM nginx:alpine

# Copy the built web app from builder
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
