#!/bin/bash

# SlackOff Validation Script
# Tests that SlackOff is working correctly after deployment

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo -e "${YELLOW}🧪 SlackOff Validation Tests${NC}"
echo "=============================="

# Test 1: Check if the build files exist
echo "🔍 Checking build files..."
if [ -d "dist" ]; then
    print_status "Build directory exists"
    if [ -f "dist/index.html" ]; then
        print_status "index.html exists in build"
    else
        print_error "index.html missing from build"
        exit 1
    fi
else
    print_warning "Build directory not found. Running build..."
    npm run build
    print_status "Build completed"
fi

# Test 2: Check Docker configuration
echo "🐳 Checking Docker configuration..."
if [ -f "Dockerfile" ]; then
    print_status "Dockerfile exists"
else
    print_error "Dockerfile missing"
    exit 1
fi

if [ -f "docker-compose.yml" ]; then
    print_status "docker-compose.yml exists"
else
    print_error "docker-compose.yml missing"
    exit 1
fi

# Test 3: Validate package.json scripts
echo "📦 Checking package.json scripts..."
if grep -q "\"dev\"" package.json && grep -q "\"build\"" package.json; then
    print_status "Required npm scripts found"
else
    print_error "Missing required npm scripts"
    exit 1
fi

# Test 4: Check if Docker is available (if installed)
echo "🔧 Checking Docker availability..."
if command -v docker &> /dev/null; then
    print_status "Docker is installed"
    
    # Try to build image if Docker is running
    if docker info &> /dev/null; then
        print_status "Docker is running"
        echo "🏗️  Testing Docker build..."
        if docker build -t slackoff:test . &> /dev/null; then
            print_status "Docker image builds successfully"
        else
            print_warning "Docker build failed (check Docker Desktop is running)"
        fi
    else
        print_warning "Docker is installed but not running"
    fi
else
    print_warning "Docker not installed (run ./setup-server.sh to install)"
fi

# Test 5: Check Apache configuration
echo "⚙️  Checking Apache configuration..."
if [ -f "docker/apache.conf" ]; then
    print_status "Apache configuration exists"
else
    print_error "Apache configuration missing"
    exit 1
fi

# Test 6: Validate deployment scripts
echo "🚀 Checking deployment scripts..."
if [ -x "deploy.sh" ]; then
    print_status "deploy.sh is executable"
else
    print_warning "deploy.sh not executable (fixing...)"
    chmod +x deploy.sh
    print_status "deploy.sh made executable"
fi

if [ -x "setup-server.sh" ]; then
    print_status "setup-server.sh is executable"
else
    print_warning "setup-server.sh not executable (fixing...)"
    chmod +x setup-server.sh
    print_status "setup-server.sh made executable"
fi

# Test 7: Check SlackOff application structure
echo "🎯 Checking SlackOff application..."
if [ -f "src/App.tsx" ]; then
    if grep -q "SlackOff" src/App.tsx; then
        print_status "SlackOff app component found"
    else
        print_error "SlackOff app component missing"
        exit 1
    fi
else
    print_error "App.tsx missing"
    exit 1
fi

# Test 8: Check terrible CSS
echo "🎨 Checking terrible CSS..."
if [ -f "src/App.css" ]; then
    if grep -q "rainbow-bg\|wiggle\|Comic Sans" src/App.css; then
        print_status "Terrible CSS animations found"
    else
        print_warning "CSS might not be terrible enough"
    fi
else
    print_error "App.css missing"
    exit 1
fi

# Test 9: Test local development server (if not already running)
echo "🌐 Testing development server..."
if curl -s http://localhost:5173 &> /dev/null; then
    print_status "Development server is already running"
else
    print_warning "Development server not running"
    echo "💡 To test locally, run: npm run dev"
fi

# Test 10: Check documentation
echo "📚 Checking documentation..."
docs_count=0
[ -f "README.md" ] && ((docs_count++))
[ -f "DEPLOYMENT.md" ] && ((docs_count++))
[ -f "DEPLOYMENT-macOS.md" ] && ((docs_count++))

if [ $docs_count -ge 2 ]; then
    print_status "Documentation files present ($docs_count found)"
else
    print_warning "Some documentation files missing"
fi

echo ""
echo -e "${GREEN}🎉 SlackOff Validation Complete! 🎉${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Install Docker Desktop (if not already): brew install --cask docker"
echo "2. Start Docker Desktop"
echo "3. Run: ./deploy.sh local"
echo "4. Open: http://localhost"
echo "5. Experience maximum frustration! 😈"
echo ""
echo -e "${RED}⚠️  Remember: SlackOff is intentionally terrible! ⚠️${NC}"
