# XPIPS Shared Deployment Scripts

Centralized deployment automation for all XPIPS services.

## 🎯 Purpose

This repository contains shared deployment scripts and workflows that can be used across all XPIPS service repositories:
- `xpips-backend`
- `xpips-web` 
- `xpips-dashboard`
- `xpips-blog-cms`

## 🚀 Quick Setup

### For Individual Repositories
```bash
# From any XPIPS service repository
git subtree add --prefix=scripts https://github.com/XPIPS/xpips-scripts.git main --squash
./scripts/scripts/setup-repo.sh
```

### For Workspace-Level Deployments
```bash
# Clone this repo into your XPIPS workspace
git clone https://github.com/XPIPS/xpips-scripts.git
cd xpips-scripts
./scripts/deploy-all.sh production
```

## 📋 Available Scripts

- `deploy-all.sh` - Unified deployment for all services
- `deploy-from-anywhere.sh` - Deploy from any repo in workspace
- `setup-repo.sh` - Setup scripts in individual repositories

## 🔄 Updating Scripts

To update scripts in individual repositories:
```bash
git subtree pull --prefix=scripts https://github.com/XPIPS/xpips-scripts.git main --squash
```

## 📖 Documentation

See `docs/DEPLOYMENT_GUIDE.md` for complete deployment documentation.
