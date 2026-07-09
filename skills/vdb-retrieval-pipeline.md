# vdb — 技能语义检索管道

Chroma + SiliconFlow BAAI/bge-m3 混合检索：云端稠密向量 + 本地 sparse 关键词权重。

## 架构

```
query
  │
  ├──▶ 云端 (SiliconFlow API)
  │     BAAI/bge-m3 ── 稠密向量 (1024d)
  │     Chroma hnsw cosine 召回 top-16
  │
  ├──▶ 本地 (sparse.py, 纯 Python, 无 torch)
  │     仅 trigger_tags ── 词权重 ── compute_lexical_matching_score
  │     (完全隔离英文 description)
  │
  └──▶ final = 0.6 × dense + 0.4 × sparse
       → disable 过滤 → top-5
```

## 安装

### 1. 创建虚拟环境

```bash
python3 -m venv ~/.hermes/vdb/.venv
source ~/.hermes/vdb/.venv/bin/activate
pip install chromadb openai python-dotenv
```

### 2. 配置 API Key

SiliconFlow 提供免费额度（2000 RPM / 500k TPM），注册获取 key：

```bash
echo 'SILICONFLOW_API_KEY=sk-your-key-here' >> ~/.hermes/.env
```

### 3. 拷贝代码

```bash
# 仓库已包含
cp -r skills/vdb-retrieval-pipeline ~/.hermes/skills/infrastructure/
```

### 4. 重建索引

```bash
cd ~/.hermes/vdb
source .venv/bin/activate
PYTHONPATH="$PWD" python3 -c "from indexer import build_index; build_index(force=True)"
```

## 使用

```python
from matcher import search

# 基础检索
results = search("部署 nginx 到 ubuntu", top_k=5)
for r in results:
    print(f"{r['skill_name']:35s} score={r['final_score']:.3f}")

# 返回结构
# [{
#   "skill_name": "system-admin",
#   "skill_path": "...",
#   "description": "...",
#   "trigger_tags": ["系统管理", ...],
#   "disable_tags": ["cli_only", ...],
#   "final_score": 0.481,
#   "dense_score": 0.577,
#   "sparse_score": 0.326
# }, ...]
```

### 自动加载（持久化）

vdb 不会自动替换 Hermes 原生 skill 匹配。需要主动启用：

**推荐：启动脚本**

```bash
# 将脚本复制到 ~/.hermes/scripts/
cp scripts/vdb-autoload.py ~/.hermes/scripts/
chmod +x ~/.hermes/scripts/vdb-autoload.py
# Hermes 启动时自动执行（需 config.yaml 启用 scripts 自动执行）
```

若不支持 scripts 自动执行，在 AGENTS.md 开头加：

```markdown
## 0. 技能检索方法

技能检索使用 ~/.hermes/vdb/ 的 Chroma + SiliconFlow BGE-M3 混合检索。
禁用 available_skills 手动匹配。始终用以下方式：

    from matcher import search
    results = search(query)

只有当 search() 返回空时才走备用：skills_list → skill_view。
```

## 模型选择

### 推荐：硅基流动 SiliconFlow —— 免费、低延迟

| 指标 | 值 |
|------|-----|
| 模型 | BAAI/bge-m3 |
| 维度 | 1024 |
| 延迟 | ~116ms/query（含 API 往返） |
| 跨语言 | 优秀（cos sim 0.4-0.7 中→英） |
| 费用 | 免费（2000 RPM / 500k TPM） |
| 端点 | https://api.siliconflow.cn/v1/embeddings |

### 替代方案

#### A. 本地部署 BGE-M3（需 GPU）

```bash
pip install transformers torch sentence-transformers
# 约 2.2GB 显存，CPU 推理 ~2s/query
```

修改 `embed.py`：

```python
def _get_client():
    # 返回 None 表示使用本地模型
    return None

def get_cloud_dense(texts):
    from sentence_transformers import SentenceTransformer
    model = SentenceTransformer("BAAI/bge-m3")
    return model.encode(texts).tolist()
```

#### B. OpenAI text-embedding-ada-002

```bash
echo 'OPENAI_API_KEY=sk-...' >> ~/.hermes/.env
```

修改 `embed.py`：

```python
API_URL = "https://api.openai.com/v1/embeddings"
MODEL = "text-embedding-ada-002"    # 1536d
```

注意：更换模型后需 `build_index(force=True)` 重建。

#### C. 其他兼容 OpenAI 协议的向量 API

- **NVIDIA NIM**: `https://integrate.api.nvidia.com/v1/embeddings`（延迟 ~6s）
- **阿里云 DashScope**: 改 `base_url` 和 `api_key`
- **智谱 GLM**: `https://open.bigmodel.cn/api/paas/v4/embeddings`

## 文件结构

```
~/.hermes/vdb/
├── sparse.py          # 纯 Python lexical weights（无依赖）
├── embed.py           # 云端稠密 API + 本地 sparse 接口
├── indexer.py         # Chroma 索引构建
├── matcher.py         # 检索入口 search()
├── __init__.py        # 包入口
├── .venv/             # 隔离 Python 环境
└── chroma/            # 持久化向量存储（~1.2MB）
```

## 性能

| 操作 | 耗时 |
|------|------|
| 索引构建（57 技能） | ~1.5s |
| 单次查询（预热后） | ~116ms |
| Chroma 磁盘占用 | ~1.2MB |
| 内存占用 | ~50MB |

## 调参

`matcher.py` 顶部可调权重：

```python
VEC_WEIGHT = 0.6       # 稠密向量权重（语义）
SPARSE_WEIGHT = 0.4    # 稀疏关键词权重（精确匹配）
```

## 排障

### "No module named 'chromadb'"

```bash
source ~/.hermes/vdb/.venv/bin/activate
pip install chromadb openai python-dotenv
```

### "Insufficient Balance" / 401

检查 API Key 和余额：

```bash
curl -s https://api.siliconflow.cn/v1/user/info \
  -H "Authorization: Bearer $(grep SILICONFLOW_API_KEY ~/.hermes/.env | cut -d= -f2 | tr -d ' \"')" | head
```

### 查询结果差

1. `build_index(force=True)` 重建索引
2. 检查技能 SKILL.md 的 trigger_tags 是否覆盖相关关键词
3. 尝试调整 `VEC_WEIGHT` / `SPARSE_WEIGHT`
