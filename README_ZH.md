# OpenClaw 备份工具

OpenClaw 工作区 GitHub 备份工具，支持 AGE 加密敏感数据。

## 功能特性

- 定期备份 `.openclaw` 工作区到 GitHub
- credentials 等敏感数据使用 AGE 加密
- 一键备份/恢复，简单高效
- 支持 Cron 定时自动备份

## 快速开始

### 1. 克隆仓库

```bash
cd /root/.openclaw
git clone git@github.com:eriic828/openclaw-yii.git
```

### 2. 执行备份

```bash
cd /root/.openclaw/openclaw-yii
./scripts/backup.sh
```

### 3. 恢复数据

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
| `cron/` | 定时任务配置 |
| `credentials.tar.gz.age` | credentials 加密备份 |

## 不备份的目录

这些目录被排除，不会上传到 GitHub：

| 目录 | 原因 |
|------|------|
| `extensions/` | 插件，可重新安装（239MB） |
| `completions/` | AI 回复缓存，增长频繁 |
| `logs/` | 运行日志，无需备份 |
| `credentials/` | 敏感目录，已加密上传 |
| `identity/` | 设备身份，敏感信息 |
| `devices/` | 设备配置，敏感信息 |
| `memory/lancedb-pro/` | 向量数据库，文件过大 |

## 加密方式

使用 [AGE](https://age-encryption.github.io/) 加密敏感文件。

**公钥（用于加密）：**
```
age1zgxmzt2edpl74l0haxtdcsga9ug4n6zhj2elqcy3pe8n9ljauq6s3sfamk
```

**私钥（用于解密）：**
- 保存在本地，请勿上传到 GitHub
- 建议存储到本地密码管理器（如 1Password、Bitwarden）

## 定时备份

设置每天自动备份：

```bash
# 编辑 crontab
crontab -e

# 添加定时任务（每天 23:00 执行）
0 23 * * * /root/.openclaw/openclaw-yii/scripts/backup.sh
```

## 文件结构

```
.
├── SKILL.md           # 详细技能文档（AI 使用）
├── README.md          # 使用说明
├── README_ZH.md      # 中文说明
└── scripts/
    ├── backup.sh      # 备份脚本
    └── restore.sh     # 恢复脚本
```

## 相关链接

- [openclaw-yii](https://github.com/eriic828/openclaw-yii) - 伊伊的工作区备份
- [openclaw](https://github.com/openclaw/openclaw) - OpenClaw 主项目
- [AGE 加密工具](https://age-encryption.github.io/) - 加密官网

---

有问题或建议欢迎联系！
