# 🎯 Deploy SlackOff to saas.kavy.live from GitHub

Now that SlackOff is on GitHub, here's how to deploy it to your server.

## 📍 GitHub Repository
**Repository**: https://github.com/ItsSypher/slackoff-saas  
**Clone URL**: `https://github.com/ItsSypher/slackoff-saas.git`

## 🚀 Complete Deployment Steps

### Step 1: DNS Setup (if not done already)
In your domain registrar's DNS panel for `kavy.live`:

```
Type: A
Name: saas
Value: [your server IP]
TTL: 3600
```

Verify: `nslookup saas.kavy.live`

### Step 2: Clone and Deploy on Server

SSH to your server and run:

```bash
# SSH to your server
ssh ubuntu@your-server-ip

# Clone SlackOff from GitHub
git clone https://github.com/ItsSypher/slackoff-saas.git
cd slackoff-saas

# Install Node.js (if not already installed)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Run the deployment script
chmod +x deploy-to-kavy-live.sh
./deploy-to-kavy-live.sh
```

### Step 3: SSL Certificate

```bash
# Install Certbot (if not already installed)
sudo apt install certbot python3-certbot-apache

# Get SSL certificate for saas.kavy.live
sudo certbot --apache -d saas.kavy.live
```

## ✅ Expected Results

After successful deployment:

- **HTTP**: http://saas.kavy.live  
- **HTTPS**: https://saas.kavy.live (after SSL)
- **Apache Virtual Host**: `/etc/apache2/sites-available/saas.kavy.live.conf`
- **Web Files**: `/var/www/saas.kavy.live/`
- **Logs**: `/var/log/apache2/saas.kavy.live_*.log`

## 🔄 Future Updates

To update SlackOff with new changes:

```bash
# On your server
cd slackoff-saas
git pull origin main
./deploy-to-kavy-live.sh
```

Or use the update script:
```bash
/var/www/saas.kavy.live/update-slackoff.sh
```

## 🎭 What You'll Get

A fully functional terrible communication app with:
- ✅ Reverse message chronology  
- ✅ Auto-terrible translations
- ✅ Moving buttons that dodge clicks
- ✅ Rainbow chaos backgrounds
- ✅ Comic Sans typography
- ✅ Annoying sound effects
- ✅ Fake error messages
- ✅ Maximum user frustration

## 🔧 Troubleshooting

**If build fails on server:**
```bash
# Check Node.js version
node --version  # Should be 18+
npm --version

# Manual build
npm install
npm run build
sudo cp -r dist/* /var/www/saas.kavy.live/
```

**If Apache issues:**
```bash
# Check Apache status
sudo systemctl status apache2

# Test configuration
sudo apache2ctl configtest

# Check logs
sudo tail -f /var/log/apache2/saas.kavy.live_error.log
```

**If DNS not working:**
```bash
# Check DNS propagation
nslookup saas.kavy.live
dig saas.kavy.live
```

## 🎉 Success!

Once deployed, visit **https://saas.kavy.live** and experience the most frustrating communication tool ever created!

Share the chaos: Send the link to unsuspecting colleagues and watch them struggle with the world's worst UX! 😈

---

**Repository**: https://github.com/ItsSypher/slackoff-saas  
**Live Demo**: https://saas.kavy.live (after deployment)
