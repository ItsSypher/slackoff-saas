# 🍎 SlackOff macOS Deployment Guide

Quick guide for deploying SlackOff on macOS (both locally and to remote servers).

## 🚀 Quick Start on macOS

### Option 1: Install Docker Desktop (Recommended)

1. **Download Docker Desktop**:
   ```bash
   # Visit https://www.docker.com/products/docker-desktop/
   # Or install via Homebrew:
   brew install --cask docker
   ```

2. **Start Docker Desktop** and wait for it to be running

3. **Deploy SlackOff locally**:
   ```bash
   ./deploy.sh local
   ```

4. **Access SlackOff**: Open `http://localhost` in your browser

### Option 2: Using Homebrew (Alternative)

```bash
# Install Docker via Homebrew
brew install docker docker-compose colima

# Start Colima (Docker runtime for macOS)
colima start

# Deploy SlackOff
./deploy.sh local
```

## 🌐 Deploy to Remote Server

### Prerequisites on Remote Server
- Ubuntu/CentOS server with root access
- Domain name pointing to server IP (optional)

### Step 1: Prepare Your Server

```bash
# SSH into your server
ssh root@your-server-ip

# Clone SlackOff
git clone https://github.com/yourusername/slackoff.git
cd slackoff

# Run server setup
chmod +x setup-server.sh
./setup-server.sh
```

### Step 2: Deploy to Production

```bash
# Deploy SlackOff
chmod +x deploy.sh
./deploy.sh production
```

### Step 3: Configure Domain (Optional)

```bash
# Update your DNS records:
# Type: A
# Name: @ (or subdomain like 'slackoff')
# Value: YOUR_SERVER_IP
# TTL: 3600

# Test after DNS propagation
curl http://yourdomain.com
```

## 🔧 Local Development on macOS

### Using the Development Server
```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Access at http://localhost:5173
```

### Using Docker for Local Testing
```bash
# Build and test Docker image locally
docker build -t slackoff:test .
docker run -p 8080:80 slackoff:test

# Access at http://localhost:8080
```

## 🛠️ Useful macOS Commands

```bash
# Check if Docker is running
docker info

# Stop all containers
docker stop $(docker ps -q)

# Remove all containers
docker rm $(docker ps -aq)

# View SlackOff logs
docker-compose logs -f

# Update and redeploy
git pull
./deploy.sh local
```

## 🚨 Troubleshooting on macOS

### Docker Desktop Issues
```bash
# Restart Docker Desktop
# Or from terminal:
killall Docker\ Desktop
open /Applications/Docker.app

# Reset Docker if needed
docker system prune -a
```

### Port Conflicts
```bash
# Check what's using port 80
sudo lsof -i :80

# Kill process if needed
sudo kill -9 <PID>
```

### Permission Issues
```bash
# Fix permissions
sudo chown -R $(whoami) .
chmod +x *.sh
```

## 📱 Testing on Different Devices

```bash
# Find your local IP
ifconfig | grep "inet " | grep -v 127.0.0.1

# Access from other devices on same network
# http://YOUR_LOCAL_IP (if Docker Desktop is running)
```

## 🎯 Quick Commands Summary

```bash
# One-time setup (install Docker Desktop first)
./setup-server.sh           # Setup environment
./deploy.sh local           # Deploy locally
./deploy.sh production      # Deploy to server

# Development
npm run dev                 # Start dev server
npm run build              # Build production

# Docker management
docker-compose up -d       # Start containers
docker-compose down        # Stop containers
docker-compose logs -f     # View logs
```

## 🔐 Security Notes for macOS

```bash
# Enable macOS firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# For local testing, Docker Desktop handles networking
# For production deployment, configure server firewall properly
```

---

**💡 Tip**: Docker Desktop on macOS automatically handles networking, so `localhost` will work directly. For production deployment, follow the server setup instructions in the main deployment guide!
