# 🎯 Quick Deploy SlackOff to saas.kavy.live

Since you already have `kavy.live` set up, here's the quickest path to get SlackOff running on `saas.kavy.live`.

## 🚀 Quick Start (3 Steps)

### Step 1: DNS Setup (5 minutes)
In your domain registrar's DNS panel for `kavy.live`:

```
Type: A
Name: saas
Value: [your server IP - same as kavy.live]
TTL: 3600
```

**Verify:** `nslookup saas.kavy.live` should return your server IP.

### Step 2: Upload and Deploy (10 minutes)

**Option A: Upload your built files**
```bash
# On your local machine (build first)
npm run build

# Upload to your server
scp -r dist/ user@kavy.live:/tmp/slackoff-dist/

# SSH to server and deploy
ssh user@kavy.live
cd /tmp/slackoff-dist
wget https://raw.githubusercontent.com/[your-repo]/deploy-to-kavy-live.sh
chmod +x deploy-to-kavy-live.sh
./deploy-to-kavy-live.sh
```

**Option B: Clone and deploy on server**
```bash
# SSH to your server
ssh user@kavy.live

# Clone SlackOff repository
git clone [your-slackoff-repo] slackoff
cd slackoff

# Run deployment script
./deploy-to-kavy-live.sh
```

### Step 3: SSL Setup (2 minutes)
```bash
# On your server
sudo certbot --apache -d saas.kavy.live
```

## 🎉 That's It!

Visit **https://saas.kavy.live** and witness the chaos! 😈

---

## 🔧 Alternative: Manual Apache Setup

If the automated script doesn't work, here's the manual process:

### 1. Create directory and copy files
```bash
sudo mkdir -p /var/www/saas.kavy.live
sudo cp -r dist/* /var/www/saas.kavy.live/
sudo chown -R www-data:www-data /var/www/saas.kavy.live
```

### 2. Create Apache virtual host
```bash
sudo nano /etc/apache2/sites-available/saas.kavy.live.conf
```

Add this configuration:
```apache
<VirtualHost *:80>
    ServerName saas.kavy.live
    DocumentRoot /var/www/saas.kavy.live
    
    <Directory /var/www/saas.kavy.live>
        AllowOverride All
        Require all granted
        
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^(.*)$ /index.html [QSA,L]
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/saas.kavy.live_error.log
    CustomLog ${APACHE_LOG_DIR}/saas.kavy.live_access.log combined
</VirtualHost>
```

### 3. Enable site and restart Apache
```bash
sudo a2enmod rewrite
sudo a2ensite saas.kavy.live
sudo systemctl restart apache2
```

## 📱 Test Your Deployment

```bash
# Test HTTP
curl -I http://saas.kavy.live

# Test HTTPS (after SSL setup)
curl -I https://saas.kavy.live

# Check logs
sudo tail -f /var/log/apache2/saas.kavy.live_access.log
```

## 🔄 Future Updates

To update SlackOff:
```bash
# Rebuild locally
npm run build

# Upload new files
scp -r dist/* user@kavy.live:/var/www/saas.kavy.live/

# Or use the update script on server
ssh user@kavy.live
/var/www/saas.kavy.live/update-slackoff.sh
```

---

**Ready to deploy the world's most frustrating communication tool? Let's do this! 💩**
