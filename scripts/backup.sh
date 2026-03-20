#!/bin/bash
# OpenClaw Backup Script
# Backs up workspace to GitHub with encrypted credentials

set -e

REPO_DIR="/root/.openclaw/openclaw-yii"
PUBLIC_KEY="age1zgxmzt2edpl74l0haxtdcsga9ug4n6zhj2elqcy3pe8n9ljauq6s3sfamk"
CREDENTIALS_ORIGIN="/root/.openclaw/credentials"

cd "$REPO_DIR"

# 1. Encrypt credentials
if [ -d "$CREDENTIALS_ORIGIN" ]; then
    tar -czvf credentials.tar.gz -C /root/.openclaw credentials/
    age -r "$PUBLIC_KEY" -o credentials.tar.gz.age credentials.tar.gz
    rm credentials.tar.gz
fi

# 2. Commit and push
git add -A
git commit -m "backup: $(date '+%Y-%m-%d %H:%M')"
git push

echo "Backup completed at $(date)"
