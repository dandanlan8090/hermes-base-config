# Hermes Base Config

Hermes Agent 通用配置模板仓库。包含核心配置文件、技能集和 vdb 技能检索工具链。

repo 目录结构直接镜像 `~/.hermes/`，clone 后 `bash install.sh` 即可部署。

---

## 重要说明（必读）

**已有 Hermes 用户的三个核心文件不要直接覆盖：**

| 文件 | 说明 |
|------|------|
| `SOUL.md` | Agent 执行铁律，你可能已有自定义修改 |
| `AGENTS.md` | 工作方法论，你可能已有个性化触发规则 |
| `memories/USER.md` | 你的画像和环境配置，仓库只提供模板 |

`install.sh` 检测到 `~/.hermes/` 已存在时会**跳过这三个文件**，并告诉你如何手动 diff 合并。
**新装机用户（无 `~/.hermes/`）会全量复制。**

其余目录（`vdb/` `skills/` `scripts/` `.env.example`）可安全覆盖/补充。

**profile 用户特别注意**：如果你使用 Hermes 多 profile（`~/.hermes/profiles/<name>/`），
安装路径有所不同：
- `SOUL.md` / `AGENTS.md` → 每个 profile 独立，分别复制到 `~/.hermes/profiles/<name>/`
- `skills/` → 每个 profile 可能有自己的技能集，需按需同步
- `vdb/` 工具链 → 全局共享 `~/.hermes/vdb/`，但索引默认只扫 `~/.hermes/skills/`。
  如果技能在 `~/.hermes/profiles/<name>/skills/` 下，**二选一**：
  ```bash
  # 方案 A：设置环境变量（推荐，不改源码）
  export HERMES_SKILL_DIR=~/.hermes/profiles/<name>/skills

  # 方案 B：建符号链接（需每次会话/永久生效）
  ln -sf ~/.hermes/profiles/<name>/skills ~/.hermes/skills
  ```
- `.env` → 全局共享 `~/.hermes/.env`，不受 profile 影响

---

## 目录结构

```
hermes-base-config/
├── install.sh              # 一键部署（新装全量 / 存量仅补技能和工具链）
├── README.md
├── LICENSE
│
├── SOUL.md                 # → ~/.hermes/SOUL.md（存量不覆盖）
├── AGENTS.md               # → ~/.hermes/AGENTS.md（存量不覆盖）
├── .env.example            # → ~/.hermes/.env（如果不存在）
│
├── memories/
│   └── USER.md             # → ~/.hermes/memories/USER.md（存量不覆盖）
│
├── vdb/                    # 技能检索系统工具链
│   ├── sparse.py           # 中文/英文 token 分词 + lexical weights
│   ├── embed.py            # SiliconFlow BGE-M3 API 包装
│   ├── indexer.py          # Chroma 索引构建器
│   ├── matcher.py          # 0.6 dense + 0.4 sparse 混合检索
│   └── __init__.py         # 包入口
│
├── scripts/
│   ├── init-vdb.sh         # 虚拟环境 + 依赖 + API Key + 索引构建
│   └── vdb-autoload.py     # 启动预热 + 索引过期检测 + 自动重建
│
└── skills/                 # 核心技能集（与 ~/.hermes/skills/ 同结构）
    ├── new-skill-template/
    ├── plan/
    ├── vdb-retrieval-pipeline.md
    ├── source-driven-development/
    ├── hermes-oracle-mode/
    ├── hermes-shipping-verification/
    ├── hermes-base-config-sync/
    ├── hermes-agent/
    ├── codebase-memory-first/
    ├── doubt-driven-development/
    └── ai-conv-style-discipline/
```

---

## 安装

### 全新安装

```bash
git clone https://github.com/dandanlan8090/hermes-base-config.git
cd hermes-base-config
bash install.sh
```

脚本自动完成：
1. 复制 SOUL.md / AGENTS.md / USER.md 到 ~/.hermes/
2. 创建 .env（从 .env.example 复制）
3. 补充 skills/ 到 ~/.hermes/skills/
4. 复制 vdb/ 工具链
5. 创建 Python 虚拟环境 + pip 安装依赖
6. 重建 Chroma 向量索引
7. **vdb 预热 + 索引过期检测**（自动重建，无需手动执行）

完成后：
```bash
# 编辑 API Key
nano ~/.hermes/.env

# 重启 Hermes 会话
hermes chat
```

### 已有用户（推荐）

```bash
git clone https://github.com/dandanlan8090/hermes-base-config.git
cd hermes-base-config
bash install.sh
```

脚本检测到 `~/.hermes/` 已存在，会：
- **跳过** SOUL.md / AGENTS.md / USER.md（提示你手动 diff 合并）
- **补充** skills/ 中不存在的技能
- **覆盖** vdb/ 工具链（安全，因为只在 ~/.hermes/vdb/ 内）
- 跳过 .venv 重建（如需重建：`bash ~/.hermes/scripts/init-vdb.sh`）

手动合并核心文件的差异：

```bash
diff -u ~/.hermes/SOUL.md  SOUL.md
diff -u ~/.hermes/AGENTS.md AGENTS.md
diff -u ~/.hermes/memories/USER.md memories/USER.md
```

### 强制覆盖（谨慎）

```bash
bash install.sh --force
```

全量覆盖，包括 SOUL.md / AGENTS.md / USER.md。只有确定是新装机时才用。

---

## 技能说明

| 技能 | 类型 | 说明 |
|------|------|------|
| `new-skill-template` | methodology | 技能开发规范 + frontmatter 模板 |
| `plan` | workflow | Plan Mode：行动方案写作规范 |
| `source-driven-development` | methodology | 源码驱动：必须引用官方文档 |
| `hermes-oracle-mode` | workflow | 主脑模式：多 Agent 统筹调度 |
| `hermes-shipping-verification` | workflow | 发布验证：质量门控 + 回滚计划 |
| `hermes-base-config-sync` | workflow | 本仓库同步、脱敏、结构校验 |
| `hermes-agent` | integration | Hermes 配置与排障 |
| `codebase-memory-first` | workflow | 代码任务前必查知识图谱 |
| `doubt-driven-development` | methodology | 怀疑驱动：对抗性审查非平凡决策 |
| `ai-conv-style-discipline` | methodology | CLI 对话风格规范 |
| `vdb-retrieval-pipeline` | infrastructure | vdb 技能语义检索管道 |

---

## 技能检索系统（vdb）

详见 [`skills/vdb-retrieval-pipeline.md`](skills/vdb-retrieval-pipeline.md)。

### 健康检查

```bash
# 索引过期检测（新增/修改/删除技能后状态不一致会提示）
cd ~/.hermes/vdb && source .venv/bin/activate
PYTHONPATH=$PWD python3 -c "from indexer import check_index_stale; s,r=check_index_stale(); print('过期' if s else '最新', r)"

# 完整启动检测（预热 + 检测 + 可选重建）
python3 ~/.hermes/scripts/vdb-autoload.py          # 检测 + 提示
python3 ~/.hermes/scripts/vdb-autoload.py --check   # 只检测
python3 ~/.hermes/scripts/vdb-autoload.py --force   # 检测 + 过期自动重建
```

所有安装流程末尾自动执行 `vdb-autoload.py --force`，无需手动干预。

### 架构

```text
query
  │
  ├──▶ 云端 (SiliconFlow BAAI/bge-m3, 1024d)
  │     Chroma hnsw cosine 召回 top-16
  │
  └──▶ 本地 (sparse.py, 纯 Python)
       仅 trigger_tags → lexical matching
       final = 0.6 × dense + 0.4 × sparse
       → disable 过滤 → top-5
```

### 模型替换

默认使用硅基流动 BGE-M3（免费 2000 RPM）。只改 `vdb/embed.py` 两个常量即可切换：

```python
API_URL = "https://api.siliconflow.cn/v1/embeddings"  # → 换 URL
MODEL = "BAAI/bge-m3"                                   # → 换模型名
```

改完 `build_index(force=True)` 重建。

---

## License

MIT
