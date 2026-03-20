# OpenClaw Backup

OpenClaw 工作区 GitHub 备份工具，支持 AGE 加密敏感数据。

## 功能

- 定期备份 `.openclaw` 工作区到 GitHub
- credentials 等敏感数据使用 AGE 加密
- 完整备份/恢复工作流
- Cron 定时任务支持

## 快速开始

### 1. 克隆仓库

```bash
cd /root/.openclaw
git clone git@github.com:eriic828/openclaw-yii.git
```

### 2. 备份

```bash
cd /root/.openclaw/openclaw-yii
./scripts/backup.sh
```

### 3. 恢复

```bash
cd /root/.openclaw/openclaw-yii
./scripts/restore.sh
```

## 备份内容

| 目录/文件 | 说明 |
|-----------|------|
| `workspace/` | 工作区文件 |
| `memory/` | 记忆文档（不含 lancedb-pro） |
| `agents/` | Agent 配置 |
| `cron/` | 定时任务 |
| `credentials.tar.gz.age` | credentials 加密备份 |

## 排除目录

- `extensions/` - 插件（可重新安装）
- `completions/` - AI 回复缓存
- `logs/` - 日志文件
- `credentials/` - 敏感目录（加密后上传）
- `identity/` - 设备身份（敏感）
- `devices/` - 设备配置（敏感）
- `memory/lancedb-pro/` - 向量数据库（过大）

## 加密

使用 [AGE](https://age Encryption.github.io/) 加密敏感文件。

- 公钥：`age1zgxmzt2edpl74l0haxtdcsga9ug4n6zhj2elqcy3pe8n9ljauq6s3sfamk`
- 私钥：保存在本地（密码管理器）

## 定时备份

```bash
# 编辑 crontab
crontab -e

# 添加定时任务（每天 23:00 执行）
0 23 * * * /root/.openclaw/openclaw-yii/scripts/backup.sh
```

## 文件结构

```
openclaw-backup/
├── SKILL.md           # 详细技能文档
├── scripts/
│   ├── backup.sh      # 备份脚本
│   └── restore.sh     # 恢复脚本
└── README.md          # 本文件
```

## 相关仓库

- [openclaw-yii](https://github.com/eriic828/openclaw-yii) - 伊伊的工作区备份
- [openclaw](https://github.com/openclaw/openclaw) - OpenClaw 主项目
