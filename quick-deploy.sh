#!/bin/bash

# One-command SlackOff deployment to saas.kavy.live
# Usage: curl -sSL https://raw.githubusercontent.com/ItsSypher/slackoff-saas/main/quick-deploy.sh | bash

set -e

echo "🚀 One-Command SlackOff Deployment to saas.kavy.live"
echo "=================================================="

# Check if we're on the right server
if [[ ! -f "/etc/apache2/apache2.conf" ]]; then
    echo "❌ This must be run on your Apache server"
    exit 1
fi

# Clone repository
echo "📦 Cloning SlackOff from GitHub..."
cd /tmp
rm -rf slackoff-saas
git clone https://github.com/ItsSypher/slackoff-saas.git
cd slackoff-saas

# Install Node.js if needed
if ! command -v node &> /dev/null; then
    echo "📥 Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
fi

# Build and deploy
echo "🏗️  Building and deploying SlackOff..."
npm install
npm run build

# Run deployment script
chmod +x deploy-to-kavy-live.sh
./deploy-to-kavy-live.sh

echo ""
echo "🎉 SlackOff deployed successfully!"
echo "🌐 Visit: http://saas.kavy.live"
echo "🔒 Set up SSL: sudo certbot --apache -d saas.kavy.live"
echo ""
echo "😈 The world's worst communication tool is now live!"
