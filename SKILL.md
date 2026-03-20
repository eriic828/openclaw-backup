---
name: openclaw-backup
description: OpenClaw workspace backup to GitHub with AGE encryption. Use when: (1) User asks to backup, sync, or upload OpenClaw workspace to GitHub, (2) User asks to restore OpenClaw from GitHub backup, (3) User asks to encrypt/decrypt sensitive files with AGE, (4) Setting up periodic backup automation with cron. Triggers on: "备份", "backup", "上传 GitHub", "sync to github", "加密 credentials", "restore backup".
---

# OpenClaw Backup Skill

Backup OpenClaw workspace to GitHub with AGE encryption for sensitive data.

## Repository Setup

```bash
# Clone existing backup repo
cd /root/.openclaw
GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git clone git@github.com:eriic828/openclaw-yii.git

# Create new repo (if needed)
# Use GitHub web UI or API to create first, then clone
```

## Directory Structure

```
openclaw-yii/
├── .gitignore          # Excludes sensitive/large dirs
├── age.key            # Private key (NEVER upload to GitHub!)
├── credentials/        # Encrypted backup
├── workspace/          # Workspace files
├── memory/            # Memory docs (excludes lancedb-pro)
├── agents/            # Agent configs
└── cron/              # Cron configs
```

## .gitignore Content

```gitignore
# Large/dynamic directories
extensions/
completions/
logs/
delivery-queue/
canvas/

# Sensitive directories
credentials/
identity/
devices/

# Backup files
*.bak
*.bak.*

# Encrypted data (keep this one commented to allow .age files)
# *.age

# Temporary files
tmp/
*.tmp

# Large databases (local vector DB)
memory/lancedb-pro/
```

## Backup Workflow

### 1. Encrypt and Backup credentials

```bash
cd /root/.openclaw/openclaw-yii

# Re-encrypt credentials (if key changed)
tar -czvf credentials.tar.gz ../credentials/
age -r <PUBLIC_KEY> -o credentials.tar.gz.age credentials.tar.gz
rm credentials.tar.gz

# Commit all changes
git add -A
git commit -m "backup: $(date '+%Y-%m-%d %H:%M')"
git push
```

### 2. Update .gitignore (if needed)

```bash
# Add new sensitive dirs to exclude
echo "memory/lancedb-pro/" >> .gitignore
```

## Restore Workflow

### 1. Clone Repo

```bash
cd /root/.openclaw
GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git clone git@github.com:eriic828/openclaw-yii.git
```

### 2. Decrypt credentials

```bash
cd /root/.openclaw/openclaw-yii

# Decrypt credentials
age -d -i age.key -o credentials.tar.gz credentials.tar.gz.age
tar -xzvf credentials.tar.gz
rm credentials.tar.gz

# Move back to .openclaw
mv credentials/ ../credentials/
```

## AGE Encryption

### Generate New Key Pair

```bash
age-keygen -o age.key
# Output includes:
#   Public key: age1zgxmzt2edpl74l0haxtdcsga9ug4n6zhj2elqcy3pe8n9ljauq6s3sfamk
#   Secret key: AGE-SECRET-KEY-1N...
```

### Encrypt (for backup)

```bash
tar -czvf data.tar.gz path/to/data
age -r <PUBLIC_KEY> -o data.tar.gz.age data.tar.gz
rm data.tar.gz
```

### Decrypt (for restore)

```bash
age -d -i <PRIVATE_KEY_FILE> -o data.tar.gz data.tar.gz.age
tar -xzvf data.tar.gz
rm data.tar.gz
```

## Cron Automation

Set up periodic backup:

```bash
# Create backup script
cat > /root/.openclaw/openclaw-yii/backup.sh << 'EOF'
#!/bin/bash
cd /root/.openclaw/openclaw-yii

# Update credentials backup
tar -czvf credentials.tar.gz ../credentials/
age -r <PUBLIC_KEY> -o credentials.tar.gz.age credentials.tar.gz
rm credentials.tar.gz

# Commit and push
git add -A
git commit -m "backup: $(date '+%Y-%m-%d %H:%M')"
git push
EOF

chmod +x /root/.openclaw/openclaw-yii/backup.sh

# Add to crontab (daily at 23:00)
echo "0 23 * * * /root/.openclaw/openclaw-yii/backup.sh" | crontab -
```

## Important Notes

1. **Private key `age.key` must be saved separately** - Store in local password manager
2. **Always keep local repo** - Don't delete after push, use for future syncs
3. **Exclude large dirs** - extensions/ (239MB), lancedb-pro/ are too big
4. **Test decryption** - After backup, verify restore works

## Current Config

- **Repo:** git@github.com:eriic828/openclaw-yii
- **Public Key:** age1zgxmzt2edpl74l0haxtdcsga9ug4n6zhj2elqcy3pe8n9ljauq6s3sfamk
- **Local Path:** /root/.openclaw/openclaw-yii
