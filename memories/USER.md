# USER.md — 用户画像 & 个性化约束模板

> 每个用户/机器一份，放在 `~/.hermes/memories/USER.md`。
> 本文件是通用模板，复制后按实际情况填写。

---

## 1. 用户基础身份

| 字段 | 示例 |
|------|------|
| 系统用户名 | your_username |
| 偏好称呼 | 名字/昵称 |
| 时区 | Asia/Shanghai |
| 常用语言 | 简体中文 |

---

## 2. 身份与日常工作

- 职业：硬件/嵌入式/服务器运维工程师、自研AI Agent架构维护者、电子垃圾佬（按实际情况修改）
- 核心工作：Linux主机调优、Armbian盒子配置、NAS存储部署、Ollama本地大模型、ComfyUI绘图、Agent知识库维护（按实际情况修改）
- 基准工作目录：`~/.hermes/workspace`

---

## 3. 自有硬件 & 系统环境

### 服务器/主机系统
- Ubuntu / Debian / Armbian / Windows（按实际填写）

### 硬件设备
- 当前主机：虚拟机 / 物理机（按实际填写）

### 高频工具
SSH、xrdp、Docker、Git、rsync、Conda、Python、Bash（按实际增删）

---

## 4. 强制交互偏好

1. 回复极度精简，剔除所有多余铺垫、安慰、客套语句
2. 代码必须完整整块脚本，禁止分段零散输出
3. 方案统一整合为单份 MD 文档，拒绝分块、分文件交付
4. 结论放在最开头，原理、背景说明简短后置，能省略则省略
5. 无需科普入门知识，默认掌握基础运维、AI部署知识
6. 优先自动化一键脚本，不提供冗长分步手动操作教程
7. 所有脚本优先适配 Debian/Ubuntu/Armbian 异构 Linux 环境

---

## 5. 知识库与 Agent 体系约定

1. 知识库标准格式：Markdown + AAAK 规范，支持 Git 同步、rsync 跨设备迁移
2. Agent 分工：Hermes 主调度统筹，OpenClaw 负责底层执行、脚本落地
3. 记忆存放路径：`MEMORY.md` 统一记录环境参数、踩坑日志、设备配置

---

## 6. 交互禁忌（禁止出现）

1. 大段无意义文字科普、重复提醒基础常识
2. 零散碎片化代码、需要手动拼接的分段命令
3. 多文件拆分方案、大量分级小标题冗余排版
4. 偏向 Windows 图形化操作教程（优先命令行方案）

---

## 7. 框架接入说明（按实际配置填写）

### MCP vs ACP 选择
- ACP server（`hermes acp`）→ 供 OpenClaw 用
- MCP server（`hermes mcp serve`）→ 供 OpenCode/Claude Code 用（stdio 协议，非 TCP）

### OpenClaw 连接方式
| 方式 | 说明 |
|------|------|
| `openclaw agent --local` | 开箱即用，适合单次任务 |
| `openclaw mcp serve` | 暴露 9 个 Channel 工具，需手动配置 |
| `openclaw acp client` | ACP 协议连接，需 token 认证 |

---

## 8. Agent 偏好说明

- 如果偏好 ACP 协议（完整工具集 + 会话持久化），在 MEMORY.md 中注明 `agent_protocol: acp`
- 如果偏好 MCP（stdio 协议），在 MEMORY.md 中注明 `agent_protocol: mcp`
- 主脑模式触发词："使用主脑模式" / "Oracle Mode" / "主脑调度"