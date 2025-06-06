# XPIPS Unified Deployment System

## Overview

This document describes the unified deployment system for all XPIPS services (Backend, Web Frontend, Dashboard).

## 🚨 Critical Issues Identified & Fixed

### 1. **Inconsistent Environment Strategy**

**Problem:** Your original deployment scripts had conflicting environment mappings:

- Web: `main` → staging, `xpips-web-external-main` → production
- Backend: `main` → production directly
- Dashboard: All branches deploy

**Solution:** Standardized to:

- `main` branch → **Production** deployment (auto-deployed via GitHub Actions)
- Manual deployments available for any environment

### 2. **Missing Environment Separation**

**Problem:** Backend only had one AWS environment but frontend had multiple.

**Solution:** Clear environment architecture:

```
TEST:        Frontend test environments → Staging backend
STAGING:     Frontend staging → Production backend
PRODUCTION:  All production environments → Production backend
```

## 🛠 Deployment Methods

### Method 1: Local Script (Immediate)

```bash
# Deploy all services to staging
./deploy-all.sh staging

# Deploy all services to production
./deploy-all.sh production

# Deploy only web frontend to production
./deploy-all.sh production web

# Deploy only backend
./deploy-all.sh production backend
```

### Method 2: GitHub Actions (Automated)

- **Automatic:** Push to `main` → Production deployment
- **Manual:** Use GitHub Actions UI for any environment/service combination

## 🌍 Environment Architecture

| Environment    | Web Domain         | Dashboard Domain            | Backend                 |
| -------------- | ------------------ | --------------------------- | ----------------------- |
| **Test**       | test.xpips.com     | dashboard-staging.xpips.com | AWS Production (shared) |
| **Staging**    | staging.xpips.com  | dashboard-staging.xpips.com | AWS Production          |
| **Production** | web-prod.xpips.com | dashboard-prod.xpips.com    | AWS Production          |

## 📋 Available Commands

### Local Deployment Script

```bash
./deploy-all.sh [environment] [service]

# Environments: test, staging, production
# Services: all, backend, web, dashboard
```

### Examples

```bash
# Quick frontend-only deployments
./deploy-all.sh staging web
./deploy-all.sh production dashboard

# Full deployments
./deploy-all.sh production all
./deploy-all.sh test all
```

## 🔧 GitHub Actions Workflow

### Automatic Deployments

- **Trigger:** Push to `main` branch
- **Target:** Production environment
- **Services:** All services

### Manual Deployments

1. Go to GitHub Actions tab
2. Select "XPIPS Unified Deployment"
3. Click "Run workflow"
4. Choose:
   - Environment (test/staging/production)
   - Services (all/backend/web/dashboard)
   - Skip backend option (for faster frontend-only deploys)

## 🚨 Important Notes

### Backend Deployment Limitation

- **Issue:** Backend currently only has one AWS environment
- **Implication:** All environments share the same backend database
- **Recommendation:** Consider creating separate AWS environments for true isolation

### Production Safety

- Local script warns when deploying to production from non-main branches
- GitHub Actions only auto-deploys production on main branch pushes
- Manual override available if needed

### Deployment Order

Services deploy in this order for dependency management:

1. Backend (AWS Elastic Beanstalk)
2. Web Frontend (Cloudflare Workers)
3. Dashboard (Cloudflare Workers)

## 🔍 What This Fixes

1. **Branch Strategy Confusion:** Clear main → production mapping
2. **Manual Coordination:** Single command deploys all services
3. **Environment Inconsistency:** Standardized environment names and targets
4. **Deployment Safety:** Production warnings and confirmations
5. **CI/CD Integration:** Automated production deployments on main

## 📝 Required Secrets (GitHub Actions)

Ensure these secrets are configured in your GitHub repository:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
CLOUDFLARE_API_TOKEN
CLOUDFLARE_ACCOUNT_ID
NEXT_PUBLIC_XPIPS_API_URL
NEXT_PUBLIC_LANDING_PAGE_URL
```

## 🎯 Recommended Workflow

1. **Development:** Work on feature branches
2. **Testing:** `./deploy-all.sh test` for quick validation
3. **Staging:** `./deploy-all.sh staging` for final testing
4. **Production:** Merge to main (auto-deploys) or `./deploy-all.sh production`

## 🤔 Critical Questions for You

1. **Backend Environments:** Do you want separate AWS environments for staging vs production?
2. **Database Separation:** Should test/staging use different databases?
3. **Domain Strategy:** When will you migrate from web-prod.xpips.com to xpips.com?
4. **Branch Strategy:** Do you want to keep the `xpips-web-external-main` special branch?

## 🔧 Next Steps

1. Test the unified deployment script locally
2. Configure GitHub secrets for automated deployments
3. Consider backend environment separation
4. Update your team's deployment procedures
