#!/bin/bash

# SlackOff GitHub Repository Setup Script
# Run this to create and push to GitHub

echo "🚀 Setting up SlackOff GitHub Repository"
echo "======================================="

# Check if GitHub CLI is installed
if command -v gh &> /dev/null; then
    echo "✅ GitHub CLI detected"
    
    # Create repository on GitHub
    echo "📦 Creating GitHub repository..."
    gh repo create slackoff-saas --public --description "SlackOff - The World's Worst Team Communication SaaS. A parody app demonstrating every possible terrible UX pattern." --clone=false
    
    # Add remote
    echo "🔗 Adding GitHub remote..."
    git remote add origin https://github.com/$(gh api user --jq .login)/slackoff-saas.git
    
    # Push to GitHub
    echo "⬆️  Pushing to GitHub..."
    git push -u origin main
    
    echo "✅ Repository created and pushed!"
    echo "🌐 Repository URL: https://github.com/$(gh api user --jq .login)/slackoff-saas"
    
else
    echo "⚠️  GitHub CLI not found. Manual setup required:"
    echo ""
    echo "1. Go to https://github.com/new"
    echo "2. Repository name: slackoff-saas"
    echo "3. Description: SlackOff - The World's Worst Team Communication SaaS"
    echo "4. Make it public"
    echo "5. Don't initialize with README (we already have one)"
    echo "6. Create repository"
    echo ""
    echo "Then run these commands:"
    echo "git remote add origin https://github.com/YOUR_USERNAME/slackoff-saas.git"
    echo "git push -u origin main"
    echo ""
    echo "📝 Or install GitHub CLI: brew install gh"
fi

echo ""
echo "🎭 SlackOff is now ready to spread chaos worldwide! 😈"
