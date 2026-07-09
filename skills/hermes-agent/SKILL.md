---
name: hermes-agent
description: "Hermes Agent 配置、扩展、排障 — when configuring, setting up, using, extending, or troubleshooting Hermes itself, or its CLI, config, models, providers, tools, skills, or features."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags:
      trigger:
        - "hermes"
        - "配置 hermes"
        - "hermes setup"
        - "hermes config"
        - "hermes 排障"
        - "hermes skills"
        - "hermes 部署"
      disable:
        - "使用 hermes"
        - "普通任务"
        - "非配置类问题"
    skill_type: "integration"
    priority: "highest"
    related_skills: [hermes-oracle-mode, agent-collaboration-workflow]
prerequisites:
  commands: [hermes]
---

# Hermes Agent 配置与使用

## 安装与初始化

```bash
# Linux/macOS
curl -fsSL https://hermes.nousresearch.com/install.sh | bash

# 初始化配置
hermes init

# 检查健康状态
hermes doctor
```

## 核心命令

```bash
hermes config set <key> <value>   # 设置配置项
hermes config get <key>           # 获取配置值
hermes skills list                # 列出所有技能
hermes mcp list                   # 列出 MCP 服务器
hermes doctor                     # 健康检查
```

## 配置文件位置

- Linux: `~/.config/hermes/`
- macOS: `~/.config/hermes/`
- 配置: `config.yaml`

## MCP 服务器配置

```bash
# 添加 MCP 服务器
hermes mcp add <name> --command <path>

# 移除 MCP 服务器
hermes mcp remove <name>

# 列出已配置 MCP 服务器
hermes mcp list
```

## Skill 管理

```bash
# 列出所有技能
hermes skills list

# 查看技能详情
hermes skills view <name>

# 安装技能（从 GitHub）
hermes skills install <repo>

# 更新技能
hermes skills update <name>
```

## ACP 服务器（OpenClaw 连接）

```bash
# 启动 ACP 服务器
hermes acp serve

# 连接 OpenClaw
openclaw acp client --server <hermes-host>
```

## 常见问题

### MCP 服务器未检测到

`hermes mcp list` 显示空是正常的，CLI 直接调用不依赖 MCP 配置。

### Skill 未加载

检查 `config.yaml` 中 `skills.enabled` 配置。

### 子 Agent 阻塞

- 检查 `config.yaml` 中 `delegation.timeout` 配置
- 查看 `hermes doctor` 输出

---

**最后更新**: 2026-07-09