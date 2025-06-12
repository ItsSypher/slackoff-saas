#!/bin/bash

# SlackOff Deployment Script - Deploy the World's Worst SaaS
# Usage: ./deploy.sh [production|staging|local]

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-local}
APP_NAME="slackoff"
DOCKER_IMAGE="slackoff:latest"
CONTAINER_NAME="slackoff-app"

echo -e "${YELLOW}🚀 Deploying SlackOff - The World's Worst SaaS 🚀${NC}"
echo -e "${YELLOW}Environment: ${ENVIRONMENT}${NC}"
echo ""

# Function to print status
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

print_status "Docker and Docker Compose are installed"

# Create logs directory
mkdir -p logs
print_status "Created logs directory"

# Build the Docker image
echo -e "${YELLOW}Building Docker image...${NC}"
if docker build -t $DOCKER_IMAGE .; then
    print_status "Docker image built successfully"
else
    print_error "Failed to build Docker image"
    exit 1
fi

# Stop existing containers
echo -e "${YELLOW}Stopping existing containers...${NC}"
docker-compose down || true
print_status "Stopped existing containers"

# Deploy based on environment
case $ENVIRONMENT in
    "production")
        echo -e "${YELLOW}Deploying to PRODUCTION...${NC}"
        print_warning "This will deploy SlackOff to production. Are you sure you want to inflict this upon the world?"
        read -p "Type 'YES' to continue: " confirm
        if [ "$confirm" != "YES" ]; then
            print_error "Deployment cancelled"
            exit 1
        fi
        docker-compose up -d
        ;;
    "staging")
        echo -e "${YELLOW}Deploying to STAGING...${NC}"
        docker-compose up -d
        ;;
    "local")
        echo -e "${YELLOW}Deploying LOCALLY...${NC}"
        docker-compose up -d
        ;;
    *)
        print_error "Unknown environment: $ENVIRONMENT"
        echo "Usage: $0 [production|staging|local]"
        exit 1
        ;;
esac

# Wait for container to be healthy
echo -e "${YELLOW}Waiting for SlackOff to become healthy...${NC}"
sleep 10

# Check if container is running
if docker ps | grep -q $CONTAINER_NAME; then
    print_status "SlackOff container is running"
else
    print_error "SlackOff container failed to start"
    echo "Container logs:"
    docker logs $CONTAINER_NAME
    exit 1
fi

# Health check
echo -e "${YELLOW}Performing health check...${NC}"
if curl -f http://localhost/ > /dev/null 2>&1; then
    print_status "SlackOff is responding to requests"
else
    print_warning "SlackOff might not be fully ready yet. Check manually at http://localhost"
fi

echo ""
echo -e "${GREEN}🎉 SlackOff deployment completed! 🎉${NC}"
echo -e "${YELLOW}Access SlackOff at: http://localhost${NC}"
echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo "  View logs: docker-compose logs -f"
echo "  Stop app:  docker-compose down"
echo "  Restart:   docker-compose restart"
echo "  Status:    docker-compose ps"
echo ""
echo -e "${RED}⚠️  WARNING: SlackOff is intentionally terrible. Use at your own risk! ⚠️${NC}"
