# Hermes Base Config

Hermes Agent 通用配置模板仓库。包含核心配置文件和常用技能，可作为新用户初始化或现有用户参考的起点。

## 目录结构

```
hermes-base-config/
├── README.md
├── LICENSE
├── SOUL.md              # Agent 核心身份与工作原则
├── AGENTS.md            # Agent 工作方法论
├── USER.md              # 用户画像模板（通用版）
├── scripts/
│   └── init-vdb.sh      # vdb 环境一键初始化脚本
├── vdb/                  # 技能检索系统（vdb 运行时工具链）
│   ├── sparse.py         # 中文/英文 token 分词 + lexical weight
│   ├── embed.py          # 云端 Embedding API 包装
│   ├── indexer.py        # Chroma 索引构建
│   ├── matcher.py        # 检索入口 search()
│   ├── __init__.py       # 包入口
│   └── .env.example      # API Key 配置模板
└── skills/               # 核心技能集
    ├── new-skill-template/         # 技能开发模板
    ├── plan/                       # Plan Mode
    ├── vdb-retrieval-pipeline      # vdb 技能语义检索管道
    ├── source-driven-development/  # 源码驱动开发
    ├── hermes-oracle-mode/         # 主脑模式
    ├── hermes-shipping-verification/  # 发布验证
    ├── hermes-base-config-sync/   # Hermes Base Config GitHub 同步流程
    ├── hermes-agent/              # Hermes 配置指南
    ├── codebase-memory-first/      # 代码库图谱钩子
    ├── doubt-driven-development/   # 怀疑驱动开发
    └── ai-conv-style-discipline/   # 对话风格规范
```

## 快速开始

### 1. 下载配置

```bash
# 克隆到本地
git clone https://github.com/YOUR_USERNAME/hermes-base-config.git ~/hermes-base-config

# 或使用 rsync 同步到目标机器
rsync -av ~/hermes-base-config/ ~/.hermes/
```

### 2. 应用配置

```bash
# SOUL.md 和 AGENTS.md 直接复制到 ~/.hermes/
cp SOUL.md AGENTS.md ~/.hermes/

# USER.md 是模板，复制后按需修改
cp USER.md ~/.hermes/memories/USER.md
```

### 3. 安装技能

```bash
# 将 skills/ 目录内容复制到 ~/.hermes/skills/
rsync -av skills/ ~/.hermes/skills/

# 4. 安装 vdb 技能检索（可选但推荐）
# 详见下方 §技能检索系统
```

## 文件说明

### SOUL.md
Agent 核心身份定义 + 永久执行铁律。包括：
- 身份定义与核心职责
- 信息真实性红线
- 强制工作流（七步法）
- 代码输出规范
- 沟通约束
- Skill 规范
- 主脑模式触发规则

### AGENTS.md
Agent 工作方法论，等同 SOUL.md 二级约束。包括：
- Skill/知识加载铁律（step 0 强制）
- 工作流决策树（plan + todo）
- Verification Before Completion
- Systematic Debugging（四阶段）
- Receiving Code Review
- Git Worktrees 使用
- TDD 本地化
- 并发 Dispatch 规范
- 完成判定（三选项）

### USER.md
用户画像模板。复制后按实际情况填写：
- 用户基础身份
- 日常工作和硬件环境
- 强制交互偏好
- 知识库约定
- 交互禁忌

## 技能说明

| 技能 | 类型 | 说明 |
|------|------|------|
| `new-skill-template` | methodology | 技能开发规范 + frontmatter 模板 |
| `plan` | workflow | Plan Mode：行动方案写作规范 |
| `source-driven-development` | methodology | 源码驱动：必须引用官方文档 |
| `hermes-oracle-mode` | workflow | 主脑模式：多 Agent 统筹调度 |
| `hermes-shipping-verification` | workflow | 发布验证：质量门控 + 回滚计划 |
| `hermes-base-config-sync` | workflow | Base Config repo 同步、脱敏、结构校验、推送流程 |
| `hermes-agent` | integration | Hermes 配置与排障 |
| `codebase-memory-first` | workflow | 代码任务前必查知识图谱 |
| `doubt-driven-development` | methodology | 怀疑驱动：对抗性审查非平凡决策 |
|| `ai-conv-style-discipline` | methodology | CLI 对话风格规范 |
|| `vdb-retrieval-pipeline` | infrastructure | Chroma + SiliconFlow BGE-M3 混合检索管道 |

## Skill 优先级

```
highest   → hermes-agent, hermes-oracle-mode, new-skill-template
high      → plan, source-driven-development, hermes-shipping-verification,
            doubt-driven-development, ai-conv-style-discipline, codebase-memory-first
normal    → 工具/集成类技能, vdb-retrieval-pipeline
low       → 辅助/可选技能
```

## 技能检索系统（vdb）

Hermes 使用 Chroma + SiliconFlow BAAI/bge-m3 混合检索为技能匹配提供语义支持。
vdb 工具链已包含在本仓库 `vdb/` 目录中。

### 安装（一键脚本）

```bash
# 1. 从 repo 复制 vdb 工具链
cp -r vdb/ ~/.hermes/vdb/

# 2. 运行初始化脚本（创建 .venv + 配置 API Key + 重建索引）
bash scripts/init-vdb.sh
```

### 手动安装

```bash
# 1. 复制工具链
cp -r vdb/ ~/.hermes/vdb/

# 2. 创建虚拟环境
python3 -m venv ~/.hermes/vdb/.venv
source ~/.hermes/vdb/.venv/bin/activate
pip install chromadb openai python-dotenv

# 3. 配置 API Key（免费注册 https://siliconflow.cn）
cp vdb/.env.example ~/.hermes/vdb/.env
# 编辑 ~/.hermes/vdb/.env，填入你的 SILICONFLOW_API_KEY

# 4. 重建索引
cd ~/.hermes/vdb
source .venv/bin/activate
PYTHONPATH="$PWD" python3 -c "from indexer import build_index; build_index(force=True)"
```

### 替换模型（可选）

当前默认使用硅基流动 BGE-M3（1024d，~116ms 延迟）。

**换 OpenAI / NVIDIA / 本地模型**：只改 `vdb/embed.py` 中 `API_URL` + `MODEL` 两个常量，然后 `build_index(force=True)` 重建。

详见 `skills/vdb-retrieval-pipeline.md`。

### 持久化（避免每次会话重新配置）

```bash
# 1. 更新 AGENTS.md 让 agent 优先使用 vdb
# 仓库的 AGENTS.md §0 已包含 vdb 检索指令
cp AGENTS.md ~/.hermes/
```

注意：chroma/（向量存储）和 .venv/（虚拟环境）是本地生成文件，不在仓库中。
首次安装后运行 `build_index(force=True)` 自动创建这两个目录。

## 自定义

### 创建用户专属 USER.md

复制 `USER.md` 并重命名为 `~/.hermes/memories/USER.md`，按实际情况修改：
- 用户名和偏好称呼
- 硬件环境
- 交互偏好
- Agent 协议偏好（MCP vs ACP）

### 添加更多技能

```bash
# 从 GitHub 安装
hermes skills install <owner/repo>

# 或手动创建
mkdir -p ~/.hermes/skills/<category>/<skill-name>
# 编辑 SKILL.md
```

## 参考

- Hermes Agent: https://hermes-agent.nousresearch.com/docs
- Agent Skills: https://github.com/addyosmani/agent-skills

## License

MIT