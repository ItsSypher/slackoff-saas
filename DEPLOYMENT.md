# 🐳 SlackOff Server Deployment Guide

This guide will help you deploy SlackOff (the world's worst SaaS) on a server with Apache2 using Docker.

## 📋 Prerequisites

### Server Requirements
- Ubuntu 20.04+ or CentOS 8+ (or any Linux distribution)
- At least 1GB RAM (2GB recommended)
- 10GB free disk space
- Internet connection
- Domain name (optional, but recommended)

### Required Software
- Docker
- Docker Compose
- Git (for cloning the repository)

## 🚀 Quick Start Deployment

### Step 1: Server Setup

```bash
# Update your server
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add your user to docker group (optional, to run without sudo)
sudo usermod -aG docker $USER
newgrp docker
```

### Step 2: Clone and Deploy SlackOff

```bash
# Clone the repository
git clone <your-repo-url> slackoff
cd slackoff

# Deploy with our automated script
./deploy.sh production
```

### Step 3: Verify Deployment

```bash
# Check if containers are running
docker-compose ps

# Check application health
curl http://localhost
curl http://your-server-ip

# View logs
docker-compose logs -f
```

## 🔧 Manual Deployment Steps

If you prefer manual deployment:

### 1. Build and Run with Docker Compose

```bash
# Build the image
docker-compose build

# Start the services
docker-compose up -d

# Check status
docker-compose ps
```

### 2. Build and Run with Docker only

```bash
# Build the image
docker build -t slackoff:latest .

# Run the container
docker run -d \
  --name slackoff-app \
  -p 80:80 \
  -v $(pwd)/logs:/usr/local/apache2/logs \
  slackoff:latest
```

## 🌐 Production Deployment with Domain

### 1. Configure Domain

Point your domain's A record to your server's IP address:
```
Type: A
Name: @ (or subdomain)
Value: YOUR_SERVER_IP
TTL: 3600
```

### 2. SSL Certificate with Let's Encrypt (Optional)

```bash
# Install Certbot
sudo apt install certbot

# Stop SlackOff temporarily
docker-compose down

# Get SSL certificate
sudo certbot certonly --standalone -d yourdomain.com

# Update docker-compose.yml to include SSL
# (You'll need to modify the configuration)
```

### 3. Reverse Proxy Setup (Recommended for Production)

Use the included Nginx proxy:

```bash
# Start with proxy
docker-compose --profile proxy up -d
```

## 🔍 Monitoring and Maintenance

### Viewing Logs
```bash
# Application logs
docker-compose logs -f slackoff

# Apache access logs
tail -f logs/access.log

# Apache error logs
tail -f logs/error.log
```

### Container Management
```bash
# Restart the application
docker-compose restart

# Update the application
git pull
docker-compose build
docker-compose up -d

# Stop the application
docker-compose down

# Remove everything (including volumes)
docker-compose down -v
```

### Health Checks
```bash
# Check container health
docker inspect slackoff-app | grep Health -A 10

# Manual health check
curl -f http://localhost/ && echo "✅ SlackOff is running" || echo "❌ SlackOff is down"
```

## 🛠️ Troubleshooting

### Container Won't Start
```bash
# Check logs
docker-compose logs slackoff

# Check if port 80 is available
sudo netstat -tlnp | grep :80

# Restart Docker service
sudo systemctl restart docker
```

### Application Not Accessible
```bash
# Check firewall
sudo ufw status
sudo ufw allow 80
sudo ufw allow 443

# Check if container is listening
docker port slackoff-app
```

### Performance Issues
```bash
# Check resource usage
docker stats

# Check server resources
htop
df -h
```

## 🔒 Security Considerations

### Basic Security Setup
```bash
# Configure firewall
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443

# Keep system updated
sudo apt update && sudo apt upgrade -y

# Configure automatic security updates
sudo apt install unattended-upgrades
sudo dpkg-reconfigure unattended-upgrades
```

### Docker Security
```bash
# Don't run containers as root
# (Already configured in our Dockerfile)

# Regularly update base images
docker pull httpd:2.4-alpine
docker-compose build --no-cache
```

## 📊 Scaling and Load Balancing

### Horizontal Scaling
```bash
# Scale to multiple instances
docker-compose up -d --scale slackoff=3

# Use external load balancer (nginx, haproxy, etc.)
```

### Resource Limits
Add to docker-compose.yml:
```yaml
services:
  slackoff:
    # ... existing config
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
```

## 🚨 Production Checklist

- [ ] Domain configured and DNS propagated
- [ ] SSL certificate installed and configured
- [ ] Firewall configured (ports 80, 443, 22 only)
- [ ] Monitoring set up (logs, health checks)
- [ ] Backup strategy implemented
- [ ] Auto-updates configured
- [ ] Resource limits set
- [ ] Security headers configured (already in Apache config)
- [ ] Error pages customized
- [ ] Performance optimization done

## 📞 Support

If SlackOff isn't being terrible enough:

1. Check the logs: `docker-compose logs -f`
2. Verify the configuration files
3. Test locally first: `./deploy.sh local`
4. Check the GitHub issues (if this was a real project)

Remember: SlackOff is intentionally terrible. If it's working, it's working correctly! 😈

## 🎯 Environment-Specific Deployments

### Local Development
```bash
./deploy.sh local
# Access at http://localhost
```

### Staging Environment
```bash
./deploy.sh staging
# Access at http://staging.yourdomain.com
```

### Production Environment
```bash
./deploy.sh production
# Access at http://yourdomain.com
```

---

**⚠️ Warning**: SlackOff is a parody application designed to be terrible. Do not use for actual team communication unless you want your team to quit immediately!
