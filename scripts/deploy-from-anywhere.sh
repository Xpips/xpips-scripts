#!/bin/bash

# Deploy XPIPS services from any repository
# This script finds the workspace root and runs deployments

set -e

# Find the XPIPS workspace root
find_workspace_root() {
    local current_dir=$(pwd)
    local max_depth=5
    local depth=0
    
    while [ $depth -lt $max_depth ]; do
        if [ -d "xpips-backend" ] && [ -d "xpips-web" ] && [ -d "xpips-dashboard" ]; then
            echo "$current_dir"
            return 0
        fi
        
        if [ "$(pwd)" = "/" ]; then
            break
        fi
        
        cd ..
        current_dir=$(pwd)
        depth=$((depth + 1))
    done
    
    return 1
}

WORKSPACE_ROOT=$(find_workspace_root)

if [ -z "$WORKSPACE_ROOT" ]; then
    echo "❌ Could not find XPIPS workspace root"
    echo "Make sure you're in a directory within the XPIPS workspace"
    exit 1
fi

echo "🎯 Found XPIPS workspace: $WORKSPACE_ROOT"

# Check if we have the deployment script
DEPLOY_SCRIPT="$WORKSPACE_ROOT/xpips-scripts/scripts/deploy-all.sh"

if [ ! -f "$DEPLOY_SCRIPT" ]; then
    echo "❌ Deployment script not found at: $DEPLOY_SCRIPT"
    echo "Make sure xpips-scripts is properly set up"
    exit 1
fi

# Run the deployment
cd "$WORKSPACE_ROOT"
exec "$DEPLOY_SCRIPT" "$@"
