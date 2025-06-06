#!/bin/bash

# XPIPS Unified Deployment Script
# Usage: ./deploy-all.sh [environment] [services...]
# Environments: staging, production, test
# Services: backend, web, dashboard, all

set -e

ENVIRONMENT=${1:-"help"}
SERVICES=${2:-"all"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BACKEND_DIR="$WORKSPACE_ROOT/xpips-backend"
WEB_DIR="$WORKSPACE_ROOT/xpips-web"
DASHBOARD_DIR="$WORKSPACE_ROOT/xpips-dashboard"

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_header() {
    echo ""
    print_status $BLUE "================================"
    print_status $BLUE "$1"
    print_status $BLUE "================================"
}

# Function to check if directory exists
check_service_exists() {
    local service_dir=$1
    local service_name=$2
    
    if [ ! -d "$service_dir" ]; then
        print_status $RED "❌ $service_name directory not found: $service_dir"
        return 1
    fi
    return 0
}

# Function to deploy backend
deploy_backend() {
    local env=$1
    print_header "🚀 Deploying Backend to $env"
    
    if ! check_service_exists "$BACKEND_DIR" "Backend"; then
        return 1
    fi
    
    cd "$BACKEND_DIR"
    
    case $env in
        "staging"|"test")
            print_status $YELLOW "⚠️  Backend only has production deployment configured"
            print_status $YELLOW "Deploying to production AWS environment..."
            ;;
        "production")
            print_status $GREEN "Deploying to production AWS environment..."
            ;;
    esac
    
    if [ -f "./deploy-to-aws.sh" ]; then
        chmod +x ./deploy-to-aws.sh
        ./deploy-to-aws.sh
        print_status $GREEN "✅ Backend deployment completed"
    else
        print_status $RED "❌ Backend deploy script not found"
        return 1
    fi
    
    cd "$SCRIPT_DIR"
}

# Function to deploy web frontend
deploy_web() {
    local env=$1
    print_header "🌐 Deploying Web Frontend to $env"
    
    if ! check_service_exists "$WEB_DIR" "Web"; then
        return 1
    fi
    
    cd "$WEB_DIR"
    
    if [ -f "./deploy-environments.sh" ]; then
        chmod +x ./deploy-environments.sh
        
        case $env in
            "test")
                ./deploy-environments.sh test
                ;;
            "staging")
                ./deploy-environments.sh staging
                ;;
            "production")
                ./deploy-environments.sh web-prod
                ;;
        esac
        
        print_status $GREEN "✅ Web frontend deployment completed"
    else
        print_status $RED "❌ Web deploy script not found"
        return 1
    fi
    
    cd "$SCRIPT_DIR"
}

# Function to deploy dashboard
deploy_dashboard() {
    local env=$1
    print_header "📊 Deploying Dashboard to $env"
    
    if ! check_service_exists "$DASHBOARD_DIR" "Dashboard"; then
        return 1
    fi
    
    cd "$DASHBOARD_DIR"
    
    if [ -f "./deploy-environments.sh" ]; then
        chmod +x ./deploy-environments.sh
        
        case $env in
            "test"|"staging")
                ./deploy-environments.sh staging
                ;;
            "production")
                ./deploy-environments.sh production
                ;;
        esac
        
        print_status $GREEN "✅ Dashboard deployment completed"
    else
        print_status $RED "❌ Dashboard deploy script not found"
        return 1
    fi
    
    cd "$SCRIPT_DIR"
}

# Function to deploy all services
deploy_all() {
    local env=$1
    print_header "🚀 Deploying ALL XPIPS Services to $env"
    
    local failed_services=()
    
    # Deploy in order: Backend first, then frontends
    print_status $BLUE "📋 Deployment order: Backend → Web → Dashboard"
    echo ""
    
    # Backend
    if ! deploy_backend "$env"; then
        failed_services+=("backend")
    fi
    
    # Web Frontend
    if ! deploy_web "$env"; then
        failed_services+=("web")
    fi
    
    # Dashboard
    if ! deploy_dashboard "$env"; then
        failed_services+=("dashboard")
    fi
    
    # Summary
    print_header "📋 Deployment Summary"
    
    if [ ${#failed_services[@]} -eq 0 ]; then
        print_status $GREEN "🎉 ALL SERVICES DEPLOYED SUCCESSFULLY!"
        print_status $GREEN ""
        print_status $GREEN "🌍 Environment URLs ($env):"
        
        case $env in
            "test")
                print_status $GREEN "• Web: https://test.xpips.com"
                print_status $GREEN "• Dashboard: https://dashboard-staging.xpips.com"
                print_status $GREEN "• Backend: AWS Production (shared)"
                ;;
            "staging")
                print_status $GREEN "• Web: https://staging.xpips.com"
                print_status $GREEN "• Dashboard: https://dashboard-staging.xpips.com"
                print_status $GREEN "• Backend: AWS Production"
                ;;
            "production")
                print_status $GREEN "• Web: https://web-prod.xpips.com"
                print_status $GREEN "• Dashboard: https://dashboard-prod.xpips.com"
                print_status $GREEN "• Backend: AWS Production"
                ;;
        esac
    else
        print_status $RED "❌ Some services failed to deploy:"
        for service in "${failed_services[@]}"; do
            print_status $RED "  • $service"
        done
        return 1
    fi
}

# Function to check git branch and warn about production
check_git_branch() {
    if command -v git &> /dev/null && [ -d ".git" ]; then
        local current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
        
        if [ "$ENVIRONMENT" = "production" ] && [ "$current_branch" != "main" ]; then
            print_status $YELLOW "⚠️  WARNING: You're deploying to PRODUCTION from branch '$current_branch'"
            print_status $YELLOW "   Recommended: Deploy to production only from 'main' branch"
            echo ""
            read -p "Do you want to continue? (y/N): " -r
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_status $YELLOW "Deployment cancelled."
                exit 0
            fi
        fi
        
        print_status $BLUE "🌿 Current branch: $current_branch"
    fi
}

# Main script logic
case $ENVIRONMENT in
    "test"|"staging"|"production")
        print_header "🚀 XPIPS Unified Deployment"
        print_status $BLUE "Environment: $ENVIRONMENT"
        print_status $BLUE "Services: $SERVICES"
        
        # Check git branch for production deployments
        check_git_branch
        
        echo ""
        
        case $SERVICES in
            "backend")
                deploy_backend "$ENVIRONMENT"
                ;;
            "web")
                deploy_web "$ENVIRONMENT"
                ;;
            "dashboard")
                deploy_dashboard "$ENVIRONMENT"
                ;;
            "all"|*)
                deploy_all "$ENVIRONMENT"
                ;;
        esac
        ;;
        
    "help"|*)
        print_header "🚀 XPIPS Unified Deployment Script"
        echo ""
        print_status $BLUE "📋 Usage:"
        echo "  ./deploy-all.sh [environment] [service]"
        echo ""
        print_status $BLUE "🌍 Environments:"
        echo "  test       - Deploy to test environments (test.xpips.com + staging dashboard)"
        echo "  staging    - Deploy to staging environments"
        echo "  production - Deploy to production environments"
        echo ""
        print_status $BLUE "🔧 Services:"
        echo "  backend    - Deploy only backend (AWS Elastic Beanstalk)"
        echo "  web        - Deploy only web frontend (Cloudflare Workers)"
        echo "  dashboard  - Deploy only dashboard (Cloudflare Workers)"
        echo "  all        - Deploy all services (default)"
        echo ""
        print_status $BLUE "📝 Examples:"
        echo "  ./deploy-all.sh test           # Deploy all services to test"
        echo "  ./deploy-all.sh production web # Deploy only web to production"
        echo "  ./deploy-all.sh staging all    # Deploy all services to staging"
        echo ""
        print_status $YELLOW "⚠️  Production deployments are recommended only from 'main' branch"
        echo ""
        print_status $BLUE "🎯 Environment Architecture:"
        echo ""
        echo "TEST:"
        echo "  • Web: test.xpips.com → AWS Staging Backend"
        echo "  • Dashboard: dashboard-staging.xpips.com → AWS Staging Backend"
        echo ""
        echo "STAGING:"
        echo "  • Web: staging.xpips.com → AWS Production Backend"
        echo "  • Dashboard: dashboard-staging.xpips.com → AWS Staging Backend"
        echo ""
        echo "PRODUCTION:"
        echo "  • Web: web-prod.xpips.com → AWS Production Backend"
        echo "  • Dashboard: dashboard-prod.xpips.com → AWS Production Backend"
        ;;
esac 