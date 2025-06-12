#!/bin/bash

# SlackOff Deployment Script for saas.kavy.live
# Deploy SlackOff to Apache subdomain on existing kavy.live server

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
DOMAIN="saas.kavy.live"
WEB_ROOT="/var/www/saas.kavy.live"
VHOST_FILE="/etc/apache2/sites-available/saas.kavy.live.conf"
SERVER_USER="www-data"

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

echo -e "${YELLOW}"
echo "🚀 SlackOff Deployment to saas.kavy.live"
echo "========================================"
echo -e "${NC}"

# Check if running on server
if [[ ! -f "/etc/apache2/apache2.conf" ]]; then
    print_error "This script must be run on your Apache server"
    print_info "Please run this script on your kavy.live server"
    exit 1
fi

# Check if running as appropriate user
if [[ $EUID -eq 0 ]]; then
    print_warning "Running as root. Some commands will use sudo anyway for clarity."
fi

print_info "Target domain: $DOMAIN"
print_info "Web root: $WEB_ROOT"

# Step 1: Create web directory
print_info "Creating web directory..."
if [[ ! -d "$WEB_ROOT" ]]; then
    sudo mkdir -p $WEB_ROOT
    print_status "Created directory: $WEB_ROOT"
else
    print_status "Directory already exists: $WEB_ROOT"
fi

# Step 2: Set up the application files
print_info "Setting up SlackOff application..."

# If dist directory exists locally, copy it
if [[ -d "./dist" ]]; then
    print_info "Copying built application files..."
    sudo cp -r ./dist/* $WEB_ROOT/
    print_status "Application files copied"
else
    print_warning "No dist directory found. Building application..."
    
    # Check if we have source files
    if [[ -f "./package.json" ]]; then
        npm install
        npm run build
        sudo cp -r ./dist/* $WEB_ROOT/
        print_status "Application built and deployed"
    else
        print_error "No application files found. Please run this script from SlackOff project directory."
        exit 1
    fi
fi

# Step 3: Set proper permissions
print_info "Setting file permissions..."
sudo chown -R $SERVER_USER:$SERVER_USER $WEB_ROOT
sudo chmod -R 755 $WEB_ROOT
print_status "Permissions set correctly"

# Step 4: Create Apache virtual host
print_info "Creating Apache virtual host configuration..."

sudo tee $VHOST_FILE > /dev/null << 'EOF'
<VirtualHost *:80>
    ServerName saas.kavy.live
    ServerAlias www.saas.kavy.live
    DocumentRoot /var/www/saas.kavy.live
    
    ServerAdmin admin@kavy.live
    
    ErrorLog ${APACHE_LOG_DIR}/saas.kavy.live_error.log
    CustomLog ${APACHE_LOG_DIR}/saas.kavy.live_access.log combined
    
    <Directory /var/www/saas.kavy.live>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
        
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^(.*)$ /index.html [QSA,L]
    </Directory>
    
    <IfModule mod_headers.c>
        Header always set X-Content-Type-Options nosniff
        Header always set X-Frame-Options DENY
        Header always set X-XSS-Protection "1; mode=block"
        Header always set Referrer-Policy "strict-origin-when-cross-origin"
        Header always set Content-Security-Policy "default-src 'self' 'unsafe-inline' 'unsafe-eval' data: blob:; img-src 'self' data: blob:; media-src 'self' data: blob:;"
        
        <FilesMatch "\.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$">
            Header set Cache-Control "public, max-age=31536000"
        </FilesMatch>
        
        <FilesMatch "\.html$">
            Header set Cache-Control "no-cache, no-store, must-revalidate"
            Header set Pragma "no-cache"
            Header set Expires 0
        </FilesMatch>
    </IfModule>
    
    <IfModule mod_deflate.c>
        AddOutputFilterByType DEFLATE text/plain text/html text/xml text/css application/xml application/xhtml+xml application/rss+xml application/javascript application/x-javascript application/json
    </IfModule>
    
    <IfModule mod_expires.c>
        ExpiresActive On
        ExpiresByType text/css "access plus 1 year"
        ExpiresByType application/javascript "access plus 1 year"
        ExpiresByType image/png "access plus 1 year"
        ExpiresByType image/jpg "access plus 1 year"
        ExpiresByType image/jpeg "access plus 1 year"
        ExpiresByType image/gif "access plus 1 year"
        ExpiresByType image/ico "access plus 1 year"
        ExpiresByType image/svg+xml "access plus 1 year"
        ExpiresByType font/woff "access plus 1 year"
        ExpiresByType font/woff2 "access plus 1 year"
    </IfModule>
    
    ErrorDocument 404 /index.html
    ErrorDocument 403 /index.html
    ErrorDocument 500 /index.html
</VirtualHost>
EOF

print_status "Virtual host configuration created"

# Step 5: Enable required Apache modules
print_info "Enabling required Apache modules..."
sudo a2enmod rewrite headers deflate expires 2>/dev/null || print_warning "Some modules may already be enabled"
print_status "Apache modules enabled"

# Step 6: Enable the site
print_info "Enabling the site..."
sudo a2ensite saas.kavy.live.conf
print_status "Site enabled"

# Step 7: Test Apache configuration
print_info "Testing Apache configuration..."
if sudo apache2ctl configtest; then
    print_status "Apache configuration is valid"
else
    print_error "Apache configuration test failed"
    exit 1
fi

# Step 8: Restart Apache
print_info "Restarting Apache..."
sudo systemctl restart apache2
print_status "Apache restarted"

# Step 9: Create update script
print_info "Creating update script..."
sudo tee $WEB_ROOT/update-slackoff.sh > /dev/null << 'EOF'
#!/bin/bash
# SlackOff Update Script for saas.kavy.live

echo "🔄 Updating SlackOff..."

# Navigate to project source (adjust path as needed)
cd /home/$(whoami)/slackoff || cd /var/www/saas.kavy.live-source || {
    echo "❌ Source directory not found"
    exit 1
}

# Pull latest changes if git repo
git pull origin main 2>/dev/null || echo "⚠️  Not a git repository or no updates"

# Build application
npm install
npm run build

# Copy to web directory
sudo cp -r ./dist/* /var/www/saas.kavy.live/
sudo chown -R www-data:www-data /var/www/saas.kavy.live
sudo chmod -R 755 /var/www/saas.kavy.live

# Reload Apache
sudo systemctl reload apache2

echo "✅ SlackOff updated successfully!"
echo "🌐 Visit: https://saas.kavy.live"
EOF

sudo chmod +x $WEB_ROOT/update-slackoff.sh
print_status "Update script created"

# Step 10: Test deployment
print_info "Testing deployment..."
sleep 2

if curl -s -I http://localhost -H "Host: $DOMAIN" | grep -q "200 OK"; then
    print_status "HTTP test passed"
else
    print_warning "HTTP test inconclusive (site might still be working)"
fi

echo ""
echo -e "${GREEN}🎉 SlackOff Deployment Complete! 🎉${NC}"
echo ""
print_info "Next steps:"
echo "1. Configure DNS: Add A record for 'saas' pointing to your server IP"
echo "2. Set up SSL: sudo certbot --apache -d saas.kavy.live"
echo "3. Test the site: http://saas.kavy.live"
echo "4. Update script: $WEB_ROOT/update-slackoff.sh"
echo ""
print_info "Useful commands:"
echo "  View logs: sudo tail -f /var/log/apache2/saas.kavy.live_access.log"
echo "  Check status: sudo systemctl status apache2"
echo "  Test config: sudo apache2ctl configtest"
echo ""
echo -e "${RED}⚠️  Don't forget to set up DNS and SSL! ⚠️${NC}"
echo -e "${YELLOW}🎭 SlackOff is now ready to frustrate users worldwide! 😈${NC}"
