# 🌐 Deploy SlackOff to saas.kavy.live - Apache Server Guide

Complete guide to deploy SlackOff on your Apache server with subdomain `saas.kavy.live`.

## 📋 Prerequisites

- Existing `kavy.live` domain with Apache server
- Root/sudo access to your server
- DNS control for `kavy.live` domain
- Basic Apache virtual host knowledge

## 🚀 Step-by-Step Deployment

### Step 1: DNS Configuration

First, add a subdomain DNS record for `saas.kavy.live`:

```bash
# Add these DNS records to your domain provider:
Type: A
Name: saas
Value: [YOUR_SERVER_IP]
TTL: 3600

# Or if using CNAME:
Type: CNAME
Name: saas
Value: kavy.live
TTL: 3600
```

**Verify DNS propagation:**
```bash
nslookup saas.kavy.live
# Should return your server IP
```

### Step 2: Server Preparation

SSH into your server and prepare the environment:

```bash
# SSH to your server
ssh user@kavy.live

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y git curl wget unzip

# Install Node.js (for building the app)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installations
node --version
npm --version
apache2 -v
```

### Step 3: Clone and Build SlackOff

```bash
# Navigate to web directory
cd /var/www/

# Clone SlackOff repository
sudo git clone [YOUR_SLACKOFF_REPO_URL] saas.kavy.live
# Or if deploying from local:
# sudo mkdir saas.kavy.live

# Set proper ownership
sudo chown -R $USER:www-data saas.kavy.live
cd saas.kavy.live

# Install dependencies and build
npm install
npm run build

# Set proper permissions
sudo chown -R www-data:www-data dist/
sudo chmod -R 755 dist/
```

### Step 4: Apache Virtual Host Configuration

Create Apache virtual host for `saas.kavy.live`:

```bash
# Create virtual host configuration
sudo nano /etc/apache2/sites-available/saas.kavy.live.conf
```

**Add this configuration:**

```apache
<VirtualHost *:80>
    ServerName saas.kavy.live
    ServerAlias www.saas.kavy.live
    DocumentRoot /var/www/saas.kavy.live/dist
    
    # Admin email
    ServerAdmin admin@kavy.live
    
    # Logging
    ErrorLog ${APACHE_LOG_DIR}/saas.kavy.live_error.log
    CustomLog ${APACHE_LOG_DIR}/saas.kavy.live_access.log combined
    
    # Directory configuration
    <Directory /var/www/saas.kavy.live/dist>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
        
        # Enable rewrite engine for SPA routing
        RewriteEngine On
        
        # Handle client-side routing - redirect all to index.html
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^(.*)$ /index.html [QSA,L]
    </Directory>
    
    # Security headers (making terrible app more secure)
    <IfModule mod_headers.c>
        Header always set X-Content-Type-Options nosniff
        Header always set X-Frame-Options DENY
        Header always set X-XSS-Protection "1; mode=block"
        Header always set Referrer-Policy "strict-origin-when-cross-origin"
        Header always set Content-Security-Policy "default-src 'self' 'unsafe-inline' 'unsafe-eval' data: blob:; img-src 'self' data: blob:; media-src 'self' data: blob:;"
        
        # Cache control for static assets
        <FilesMatch "\.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$">
            Header set Cache-Control "public, max-age=31536000"
        </FilesMatch>
        
        # No cache for HTML files (for SPA updates)
        <FilesMatch "\.html$">
            Header set Cache-Control "no-cache, no-store, must-revalidate"
            Header set Pragma "no-cache"
            Header set Expires 0
        </FilesMatch>
    </IfModule>
    
    # Compression for better performance
    <IfModule mod_deflate.c>
        AddOutputFilterByType DEFLATE text/plain
        AddOutputFilterByType DEFLATE text/html
        AddOutputFilterByType DEFLATE text/xml
        AddOutputFilterByType DEFLATE text/css
        AddOutputFilterByType DEFLATE application/xml
        AddOutputFilterByType DEFLATE application/xhtml+xml
        AddOutputFilterByType DEFLATE application/rss+xml
        AddOutputFilterByType DEFLATE application/javascript
        AddOutputFilterByType DEFLATE application/x-javascript
        AddOutputFilterByType DEFLATE application/json
    </IfModule>
    
    # Expires headers for caching
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
    
    # Error pages (keep them terrible)
    ErrorDocument 404 /index.html
    ErrorDocument 403 /index.html
    ErrorDocument 500 /index.html
</VirtualHost>
```

### Step 5: Enable Required Apache Modules

```bash
# Enable required Apache modules
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod deflate
sudo a2enmod expires

# Enable the site
sudo a2ensite saas.kavy.live.conf

# Test Apache configuration
sudo apache2ctl configtest

# If test is OK, restart Apache
sudo systemctl restart apache2
```

### Step 6: SSL Certificate with Let's Encrypt (Recommended)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-apache

# Get SSL certificate
sudo certbot --apache -d saas.kavy.live -d www.saas.kavy.live

# Follow the prompts and choose to redirect HTTP to HTTPS

# Test auto-renewal
sudo certbot renew --dry-run
```

### Step 7: Firewall Configuration

```bash
# Allow HTTP and HTTPS traffic
sudo ufw allow 'Apache Full'

# Check firewall status
sudo ufw status
```

## 🔄 Deployment Script for Easy Updates

Create an update script on your server:

```bash
# Create deployment script
sudo nano /var/www/saas.kavy.live/deploy-update.sh
```

**Add this content:**

```bash
#!/bin/bash

# SlackOff Update Deployment Script for saas.kavy.live
set -e

echo "🚀 Updating SlackOff on saas.kavy.live..."

# Navigate to project directory
cd /var/www/saas.kavy.live

# Pull latest changes
git pull origin main

# Install dependencies (if needed)
npm install

# Build the application
npm run build

# Set proper permissions
sudo chown -R www-data:www-data dist/
sudo chmod -R 755 dist/

# Restart Apache (optional)
sudo systemctl reload apache2

echo "✅ SlackOff updated successfully!"
echo "🌐 Visit: https://saas.kavy.live"
```

```bash
# Make script executable
sudo chmod +x /var/www/saas.kavy.live/deploy-update.sh
```

## 🧪 Testing and Verification

### Test the Deployment

```bash
# Check Apache status
sudo systemctl status apache2

# Check if site is reachable
curl -I http://saas.kavy.live
curl -I https://saas.kavy.live

# Check Apache logs
sudo tail -f /var/log/apache2/saas.kavy.live_access.log
sudo tail -f /var/log/apache2/saas.kavy.live_error.log
```

### Verify DNS and SSL

```bash
# Check DNS resolution
nslookup saas.kavy.live

# Check SSL certificate
echo | openssl s_client -servername saas.kavy.live -connect saas.kavy.live:443 2>/dev/null | openssl x509 -noout -dates
```

## 🔧 Maintenance and Monitoring

### Regular Maintenance Commands

```bash
# Update SlackOff
cd /var/www/saas.kavy.live && ./deploy-update.sh

# Check Apache configuration
sudo apache2ctl configtest

# Restart Apache services
sudo systemctl restart apache2

# Renew SSL certificate
sudo certbot renew

# Check disk space
df -h

# Monitor logs
sudo tail -f /var/log/apache2/saas.kavy.live_access.log
```

### Backup Script

```bash
# Create backup script
sudo nano /var/www/backup-slackoff.sh
```

**Add backup content:**

```bash
#!/bin/bash
# Backup SlackOff
BACKUP_DIR="/var/backups/slackoff"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR
tar -czf $BACKUP_DIR/slackoff_$DATE.tar.gz /var/www/saas.kavy.live

# Keep only last 7 backups
find $BACKUP_DIR -name "slackoff_*.tar.gz" -mtime +7 -delete

echo "Backup completed: slackoff_$DATE.tar.gz"
```

## 🚨 Troubleshooting

### Common Issues and Solutions

**1. Apache won't start:**
```bash
sudo apache2ctl configtest
sudo systemctl status apache2
sudo journalctl -u apache2
```

**2. Site not accessible:**
```bash
# Check if Apache is listening
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443

# Check firewall
sudo ufw status
```

**3. SSL issues:**
```bash
# Renew certificate manually
sudo certbot renew --force-renewal -d saas.kavy.live
```

**4. Permission issues:**
```bash
sudo chown -R www-data:www-data /var/www/saas.kavy.live/dist/
sudo chmod -R 755 /var/www/saas.kavy.live/dist/
```

## 📊 Performance Optimization

### Apache Optimization

Add to your virtual host or main Apache config:

```apache
# Performance tuning
<IfModule mod_deflate.c>
    SetOutputFilter DEFLATE
    SetEnvIfNoCase Request_URI \
        \.(?:gif|jpe?g|png)$ no-gzip dont-vary
    SetEnvIfNoCase Request_URI \
        \.(?:exe|t?gz|zip|bz2|sit|rar)$ no-gzip dont-vary
</IfModule>

# Browser caching
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresDefault "access plus 1 month"
    ExpiresByType text/html "access plus 1 hour"
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year"
</IfModule>
```

## 🎯 Final Checklist

- [ ] DNS record created for `saas.kavy.live`
- [ ] Apache virtual host configured
- [ ] SSL certificate installed
- [ ] Required Apache modules enabled
- [ ] SlackOff built and deployed
- [ ] Proper file permissions set
- [ ] Firewall configured
- [ ] Site accessible at https://saas.kavy.live
- [ ] Error pages working
- [ ] Logs monitoring set up
- [ ] Backup script created
- [ ] Update script ready

## 🎉 Success!

Once completed, your terrible SlackOff app will be live at:

**🌐 https://saas.kavy.live**

Your team communication nightmare is now accessible to the world! 😈

---

**⚠️ Remember**: SlackOff is intentionally terrible. Use responsibly (or irresponsibly, it's up to you)! 💩
