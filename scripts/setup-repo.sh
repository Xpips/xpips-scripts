#!/bin/bash

# Setup script to install xpips-scripts in individual repositories
# Usage: ./setup-repo.sh [repo-name]

REPO_NAME=${1:-$(basename $(pwd))}
SCRIPTS_REPO="https://github.com/XPIPS/xpips-scripts.git"

echo "🔧 Setting up deployment scripts for $REPO_NAME"

# Add scripts repo as a git subtree
if [ ! -d "scripts" ]; then
    echo "📥 Adding xpips-scripts as subtree..."
    git subtree add --prefix=scripts $SCRIPTS_REPO main --squash
else
    echo "🔄 Updating existing scripts subtree..."
    git subtree pull --prefix=scripts $SCRIPTS_REPO main --squash
fi

# Create convenient symlinks in repo root
echo "🔗 Creating convenience symlinks..."
ln -sf scripts/scripts/deploy-all.sh deploy.sh
ln -sf scripts/scripts/Makefile Makefile.deploy

# Create repo-specific deployment wrapper
cat > deploy-this.sh << 'DEPLOY_EOF'
#!/bin/bash
# Repository-specific deployment wrapper

REPO_NAME=$(basename $(pwd))
SCRIPT_DIR="scripts/scripts"

if [ ! -f "$SCRIPT_DIR/deploy-all.sh" ]; then
    echo "❌ xpips-scripts not found. Run: ./scripts/setup-repo.sh"
    exit 1
fi

case $REPO_NAME in
    "xpips-backend")
        $SCRIPT_DIR/deploy-all.sh $1 backend
        ;;
    "xpips-web")
        $SCRIPT_DIR/deploy-all.sh $1 web
        ;;
    "xpips-dashboard")
        $SCRIPT_DIR/deploy-all.sh $1 dashboard
        ;;
    *)
        echo "🤔 Unknown repo: $REPO_NAME"
        echo "Available commands:"
        echo "  ./deploy-this.sh staging   # Deploy this service to staging"
        echo "  ./deploy-this.sh production # Deploy this service to production"
        ;;
esac
DEPLOY_EOF

chmod +x deploy-this.sh

echo "✅ Setup complete for $REPO_NAME!"
echo ""
echo "📋 Available commands:"
echo "  ./deploy-this.sh staging     # Deploy this service to staging"
echo "  ./deploy-this.sh production  # Deploy this service to production"
echo "  ./deploy.sh staging all      # Deploy all services to staging"
echo ""
