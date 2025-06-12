#!/bin/bash

# SlackOff Server Setup Script
# This script installs Docker, Docker Compose, and sets up SlackOff

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
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
echo "🐳 SlackOff Server Setup - The World's Worst SaaS Deployment"
echo "============================================================="
echo -e "${NC}"

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    DISTRO=$(lsb_release -si 2>/dev/null || echo "Unknown")
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    OS="windows"
else
    OS="unknown"
fi

print_info "Detected OS: $OS"

# Function to install Docker on Linux
install_docker_linux() {
    print_info "Installing Docker on Linux..."
    
    # Update package manager
    sudo apt-get update -y
    
    # Install prerequisites
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Set up repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker Engine
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    
    print_status "Docker installed on Linux"
}

# Function to install Docker on macOS
install_docker_macos() {
    print_info "For macOS, please install Docker Desktop manually:"
    echo "1. Visit: https://www.docker.com/products/docker-desktop"
    echo "2. Download Docker Desktop for Mac"
    echo "3. Install and start Docker Desktop"
    echo "4. Come back and run this script again"
    echo ""
    print_warning "Or install via Homebrew:"
    echo "brew install --cask docker"
    echo ""
    exit 1
}

# Function to install Docker Compose
install_docker_compose() {
    print_info "Installing Docker Compose..."
    
    # Docker Compose v2 (comes with Docker Desktop, but let's ensure it's available)
    if command -v docker-compose &> /dev/null; then
        print_status "Docker Compose already installed"
    else
        # Install Docker Compose standalone
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        print_status "Docker Compose installed"
    fi
}

# Check if Docker is already installed
if command -v docker &> /dev/null; then
    print_status "Docker is already installed"
    docker --version
else
    print_warning "Docker is not installed. Installing..."
    
    case $OS in
        "linux")
            install_docker_linux
            ;;
        "macos")
            install_docker_macos
            ;;
        "windows")
            print_error "Windows is not fully supported by this script"
            print_info "Please install Docker Desktop for Windows manually"
            exit 1
            ;;
        *)
            print_error "Unknown operating system"
            exit 1
            ;;
    esac
fi

# Install Docker Compose if needed
install_docker_compose

# Verify installation
print_info "Verifying Docker installation..."
if docker --version && docker-compose --version; then
    print_status "Docker and Docker Compose are installed correctly"
else
    print_error "Docker installation verification failed"
    exit 1
fi

# Create necessary directories
print_info "Creating necessary directories..."
mkdir -p logs
mkdir -p docker
print_status "Directories created"

# Set permissions
if [[ "$OS" == "linux" ]]; then
    print_info "Setting up permissions..."
    sudo chown -R $USER:$USER .
    print_status "Permissions set"
fi

echo ""
echo -e "${GREEN}🎉 SlackOff server setup completed! 🎉${NC}"
echo ""
print_info "Next steps:"
echo "1. Run: ./deploy.sh local    (for local testing)"
echo "2. Run: ./deploy.sh staging  (for staging deployment)"
echo "3. Run: ./deploy.sh production (for production deployment)"
echo ""
print_warning "Note: On Linux, you may need to log out and back in for Docker group permissions to take effect"
echo ""
echo -e "${RED}⚠️  Remember: SlackOff is intentionally terrible! ⚠️${NC}"
