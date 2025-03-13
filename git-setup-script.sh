#!/bin/bash

# Git Repository Setup for Crypto Arbitrage Bot
# This script sets up a local git repository and pushes it to GitHub

# Colors for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print colored status messages
print_status() {
    echo -e "${BLUE}[STATUS]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if git is installed
if ! command -v git &> /dev/null; then
    print_error "Git is not installed. Installing git..."
    sudo apt update
    sudo apt install git -y
    
    if [ $? -ne 0 ]; then
        print_error "Failed to install git. Please install it manually and run this script again."
        exit 1
    fi
    print_success "Git has been installed successfully."
fi

# Project directory path (current directory or specified path)
PROJECT_DIR=${1:-$(pwd)}

# Navigate to project directory
cd "$PROJECT_DIR" || { print_error "Failed to navigate to project directory: $PROJECT_DIR"; exit 1; }
print_status "Working in directory: $(pwd)"

# Initialize Git repository if not already initialized
if [ ! -d .git ]; then
    print_status "Initializing Git repository..."
    git init
    print_success "Git repository initialized."
else
    print_status "Git repository already exists."
fi

# Create .gitignore file if it doesn't exist
if [ ! -f .gitignore ]; then
    print_status "Creating .gitignore file..."
    cat > .gitignore << EOL
# Node.js dependencies
node_modules/
npm-debug.log
yarn-debug.log
yarn-error.log

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Hardhat files
cache/
artifacts/

# Coverage directory
coverage/

# Build directories
dist/
build/

# IDE files
.idea/
.vscode/
*.sublime-project
*.sublime-workspace

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Logs
logs
*.log

# Private keys and secrets
keys/
secrets/
EOL
    print_success ".gitignore file created."
else
    print_status ".gitignore file already exists."
fi

# Create README.md file if it doesn't exist
if [ ! -f README.md ]; then
    print_status "Creating README.md file..."
    cat > README.md << EOL
# Crypto Arbitrage Trading Bot

An automated trading bot that leverages multiple blockchains (Ethereum, Polygon, BSC, Arbitrum, and Solana) to identify and execute profitable arbitrage opportunities.

## Features

- Cross-chain monitoring and execution
- Flash loan integration for leveraged trades
- Gas optimization for cost-effective trading
- Profit-checking mechanism accounting for gas costs
- Telegram alerts for trade notifications
- Web dashboard for monitoring performance
- Security measures to protect funds
- Automated deployment for continuous operation

## Setup Instructions

See the step-by-step guide in the documentation folder for detailed setup and deployment instructions.

## Requirements

- Node.js v16+
- Hardhat
- MetaMask wallet
- Basic understanding of blockchain and cryptocurrency trading

## Security Notice

This code is provided for educational purposes only. Always perform thorough testing and security audits before deploying with real funds.
EOL
    print_success "README.md file created."
else
    print_status "README.md file already exists."
fi

# Create LICENSE file if it doesn't exist
if [ ! -f LICENSE ]; then
    print_status "Creating MIT LICENSE file..."
    YEAR=$(date +%Y)
    cat > LICENSE << EOL
MIT License

Copyright (c) $YEAR

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOL
    print_success "LICENSE file created."
else
    print_status "LICENSE file already exists."
fi

# Stage all files
print_status "Staging all files for commit..."
git add .

# Initial commit
print_status "Creating initial commit..."
git commit -m "Initial commit: Crypto Arbitrage Trading Bot"

if [ $? -ne 0 ]; then
    # Configure git if commit fails
    print_status "Configuring git user information..."
    read -p "Enter your GitHub username: " github_username
    read -p "Enter your email associated with GitHub: " github_email
    
    git config user.name "$github_username"
    git config user.email "$github_email"
    
    # Try commit again
    git commit -m "Initial commit: Crypto Arbitrage Trading Bot"
fi

print_success "Local repository created successfully."

# Ask for GitHub credentials and repository name
read -p "Enter your GitHub username: " github_username
read -p "Enter your GitHub repository name (will be created if it doesn't exist): " repo_name

# Create GitHub repository using GitHub API
print_status "Creating GitHub repository: $repo_name..."

# Check if GitHub CLI is installed, otherwise use curl
if command -v gh &> /dev/null; then
    print_status "Using GitHub CLI to create repository..."
    gh auth login
    gh repo create "$repo_name" --public --confirm
    
    if [ $? -ne 0 ]; then
        print_error "Failed to create GitHub repository using GitHub CLI."
        exit 1
    fi
else
    print_status "GitHub CLI not found. Using curl to create repository..."
    read -s -p "Enter your GitHub personal access token: " github_token
    echo ""
    
    curl -H "Authorization: token $github_token" \
        -d "{\"name\":\"$repo_name\",\"description\":\"Crypto Arbitrage Trading Bot for automated cross-chain trading\",\"private\":false}" \
        https://api.github.com/user/repos
    
    if [ $? -ne 0 ]; then
        print_error "Failed to create GitHub repository using API."
        exit 1
    fi
fi

print_success "GitHub repository created successfully."

# Add remote origin
print_status "Adding remote origin..."
git remote add origin "https://github.com/$github_username/$repo_name.git"

# Push to GitHub
print_status "Pushing to GitHub..."
git push -u origin master

if [ $? -ne 0 ]; then
    print_status "Failed to push using HTTPS. Trying to push using SSH..."
    git remote set-url origin "git@github.com:$github_username/$repo_name.git"
    git push -u origin master
    
    if [ $? -ne 0 ]; then
        print_error "Failed to push to GitHub. Please check your credentials and try manually."
        print_status "Run: git push -u origin master"
        exit 1
    fi
fi

print_success "Successfully pushed to GitHub repository: https://github.com/$github_username/$repo_name"
print_status "Repository URL: https://github.com/$github_username/$repo_name"
