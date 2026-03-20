#!/bin/bash
# OpenClaw Restore Script
# Restores workspace from GitHub backup

set -e

REPO_DIR="/root/.openclaw/openclaw-yii"
PRIVATE_KEY="$REPO_DIR/age.key"

cd "$REPO_DIR"

# 1. Decrypt credentials
if [ -f "credentials.tar.gz.age" ]; then
    age -d -i "$PRIVATE_KEY" -o credentials.tar.gz credentials.tar.gz.age
    tar -xzvf credentials.tar.gz
    rm credentials.tar.gz
    
    # Move to .openclaw
    mv credentials /root/.openclaw/
fi

# 2. Copy other directories
for dir in workspace memory agents cron; do
    if [ -d "$dir" ]; then
        cp -r "$dir" /root/.openclaw/
    fi
done

echo "Restore completed at $(date)"
