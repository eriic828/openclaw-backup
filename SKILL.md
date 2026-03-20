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

## ⚠️ 重要：Gitlink 问题

**问题描述：**
如果直接 `cp -r` 复制一个包含 `.git` 目录的仓库，会创建 **git submodule/gitlink**，导致文件内容为空。

**错误示例：**
```bash
# ❌ 错误！会创建 gitlink（submodule）
cp -r /root/.openclaw/workspace openclaw-yii/

# git ls-tree 会显示类似：
# 160000 commit xxx  workspace   # 这是 gitlink，内容为空！
```

**正确做法：**
```bash
# ✅ 正确：先删除 .git，再复制
cd /root/.openclaw/openclaw-yii
rm -rf workspace
mkdir workspace
cp -r /root/.openclaw/workspace/* workspace/

# 或者用 rsync 排除 .git
rsync -a --exclude='.git' /root/.openclaw/workspace/ workspace/
```

## .gitignore Content

```gitignore
# ============================================
# OpenClaw 备份排除规则
# ============================================

# --- 大型/动态增长目录 ---
extensions/
completions/
logs/
delivery-queue/
canvas/

# --- 敏感目录（必须排除！）---
credentials/      # 密钥（加密后上传 .age 即可）
identity/        # 设备身份
devices/         # 设备配置

# --- Git 相关（禁止上传！）---
.git
.ssh
.openclaw

# --- 备份文件 ---
*.bak
*.bak.*

# --- 加密文件 ---
age.key          # 私钥，绝对不能上传！
*.age            # 加密文件可以上传

# --- 临时文件 ---
tmp/
*.tmp

# --- 大型数据库 ---
memory/lancedb-pro/

# --- 其他 ---
subagents/
```

## Backup Workflow

### 1. 同步工作区文件（避免 gitlink）

```bash
cd /root/.openclaw/openclaw-yii

# 同步 workspace（排除 .git 等敏感文件）
rsync -a --exclude='.git' --exclude='.ssh' --exclude='.openclaw' \
      --exclude='.clawhub' --exclude='.learnings' \
      /root/.openclaw/workspace/ workspace/

# 同步 agents/
rsync -a --exclude='.git' /root/.openclaw/agents/ agents/

# 同步 cron/
rsync -a /root/.openclaw/cron/ cron/

# 同步 memory/（排除 lancedb-pro）
rsync -a --exclude='lancedb-pro' /root/.openclaw/memory/ memory/
```

### 2. 加密 credentials

```bash
cd /root/.openclaw/openclaw-yii

# 加密 credentials
tar -czvf credentials.tar.gz -C /root/.openclaw credentials/
age -r <PUBLIC_KEY> -o credentials.tar.gz.age credentials.tar.gz
rm credentials.tar.gz
```

### 3. 提交并推送

```bash
git add -A
git status  # 先检查是否有敏感文件
git commit -m "backup: $(date '+%Y-%m-%d %H:%M')"
git push
```

### 4. 验证备份

```bash
# 检查 gitlink
git ls-tree -r HEAD --name-only | grep "^160000" && echo "有 gitlink 问题！" || echo "正常"

# 检查文件数量
git ls-tree -r HEAD --name-only | wc -l
```

## Restore Workflow

### 1. Clone Repo

```bash
cd /root/.openclaw
GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git clone git@github.com:eriic828/openclaw-yii.git
```

### 2. 验证无 gitlink

```bash
cd openclaw-yii
git ls-tree -r HEAD --name-only | grep "^160000" && echo "有问题！" || echo "正常"
```

### 3. Decrypt credentials

```bash
cd /root/.openclaw/openclaw-yii

# Decrypt credentials
age -d -i age.key -o credentials.tar.gz credentials.tar.gz.age
tar -xzvf credentials.tar.gz
rm credentials.tar.gz

# Move back to .openclaw
mv credentials/ /root/.openclaw/
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
set -e

REPO_DIR="/root/.openclaw/openclaw-yii"
PUBLIC_KEY="age1zgxmzt2edpl74l0haxtdcsga9ug4n6zhj2elqcy3pe8n9ljauq6s3sfamk"
OPENCLAW_DIR="/root/.openclaw"

cd "$REPO_DIR"

# Sync files (rsync to avoid gitlink)
rsync -a --exclude='.git' --exclude='.ssh' --exclude='.openclaw' \
      --exclude='.clawhub' --exclude='.learnings' \
      "$OPENCLAW_DIR/workspace/" workspace/

rsync -a --exclude='.git' "$OPENCLAW_DIR/agents/" agents/
rsync -a --exclude='lancedb-pro' "$OPENCLAW_DIR/memory/" memory/
rsync -a "$OPENCLAW_DIR/cron/" cron/

# Encrypt credentials
if [ -d "$OPENCLAW_DIR/credentials" ]; then
    tar -czvf credentials.tar.gz -C "$OPENCLAW_DIR" credentials/
    age -r "$PUBLIC_KEY" -o credentials.tar.gz.age credentials.tar.gz
    rm credentials.tar.gz
fi

# Commit and push
git add -A
git commit -m "backup: $(date '+%Y-%m-%d %H:%M')"
git push

echo "Backup completed at $(date)"
EOF

chmod +x /root/.openclaw/openclaw-yii/backup.sh

# Add to crontab (daily at 23:00)
echo "0 23 * * * /root/.openclaw/openclaw-yii/backup.sh >> /tmp/backup.log 2>&1" | crontab -
```

## Important Notes

1. **Private key `age.key` must be saved separately** - Store in local password manager, NEVER upload to GitHub

2. **Use rsync instead of cp -r** - To avoid creating gitlinks/submodules

3. **Always verify before push** - Check `git status` and `git ls-tree` for issues

4. **Exclude sensitive directories:**
   - `.git` - Git 仓库目录
   - `.ssh` - SSH 密钥
   - `.openclaw` - OpenClaw 配置
   - `credentials/` - 密钥（加密后上传 .age）
   - `identity/` - 设备身份
   - `devices/` - 设备配置

5. **Test decryption after backup** - Verify restore works

6. **Keep local repo** - Don't delete after push, use for future syncs

## Current Config

- **Repo:** git@github.com:eriic828/openclaw-yii
- **Public Key:** age1zgxmzt2edpl74l0haxtdcsga9ug4n6zhj2elqcy3pe8n9ljauq6s3sfamk
- **Local Path:** /root/.openclaw/openclaw-yii
