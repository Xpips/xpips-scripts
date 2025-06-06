# XPIPS Deployment Shortcuts
# Usage: make [target]

.PHONY: help deploy-test deploy-staging deploy-prod deploy-web deploy-dashboard deploy-backend

# Default target
help:
	@echo "🚀 XPIPS Deployment Shortcuts"
	@echo ""
	@echo "Quick deployments:"
	@echo "  make deploy-test     - Deploy all services to test environment"
	@echo "  make deploy-staging  - Deploy all services to staging environment"
	@echo "  make deploy-prod     - Deploy all services to production environment"
	@echo ""
	@echo "Service-specific deployments:"
	@echo "  make deploy-web      - Deploy web frontend to production"
	@echo "  make deploy-dashboard - Deploy dashboard to production"
	@echo "  make deploy-backend  - Deploy backend to production"
	@echo ""
	@echo "For more options, use: ./deploy-all.sh help"

# Environment deployments
deploy-test:
	@echo "🚀 Deploying all services to TEST environment..."
	./deploy-all.sh test

deploy-staging:
	@echo "🚀 Deploying all services to STAGING environment..."
	./deploy-all.sh staging

deploy-prod:
	@echo "🚀 Deploying all services to PRODUCTION environment..."
	./deploy-all.sh production

# Service-specific deployments (to production)
deploy-web:
	@echo "🌐 Deploying web frontend to PRODUCTION..."
	./deploy-all.sh production web

deploy-dashboard:
	@echo "📊 Deploying dashboard to PRODUCTION..."
	./deploy-all.sh production dashboard

deploy-backend:
	@echo "🚀 Deploying backend to PRODUCTION..."
	./deploy-all.sh production backend

# Quick staging deploys for frontend development
staging-web:
	@echo "🌐 Quick web deployment to staging..."
	./deploy-all.sh staging web

staging-dashboard:
	@echo "📊 Quick dashboard deployment to staging..."
	./deploy-all.sh staging dashboard 