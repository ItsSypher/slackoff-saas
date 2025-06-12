# Multi-stage build for SlackOff - The World's Worst SaaS
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage with Apache2
FROM httpd:2.4-alpine

# Install necessary packages
RUN apk add --no-cache \
    apache2-utils \
    curl

# Copy custom Apache configuration
COPY docker/apache.conf /usr/local/apache2/conf/httpd.conf

# Copy built application to Apache document root
COPY --from=builder /app/dist /usr/local/apache2/htdocs/

# Create directory for Apache logs
RUN mkdir -p /usr/local/apache2/logs

# Set proper permissions
RUN chown -R www-data:www-data /usr/local/apache2/htdocs/ || \
    chown -R daemon:daemon /usr/local/apache2/htdocs/

# Expose port 80
EXPOSE 80

# Health check to ensure Apache is running
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Start Apache in foreground
CMD ["httpd-foreground"]
