# TROUBLESHOOTING — 技能检索避坑指南

## 1. vdb 不会自动替换 Hermes 原生技能匹配

Hermes 有两个并行的技能检索系统：

```
原生系统（默认生效）
  → available_skills（system prompt 内建列表）
  → skill_view() 手动加载
  → 每次会话自动生效

vdb 系统（需要显式启用）
  → Chroma + SiliconFlow BGE-M3
  → search() 函数调用
  → 不激活不生效
```

**克隆仓库、复制 SOUL.md、安装依赖后，Hermes 仍然使用原生匹配。** vdb 只存在于文档描述中，不会自动运行。

### 验证当前是否在用 vdb

查看会话开始时的系统提示——如果 `available_skills` 仍列出所有技能、agent 肉眼扫描列表匹配，说明 vdb 未激活。

### 启用 vdb 作为默认检索方法

需要同时做两件事：

#### A. 更新 AGENTS.md（让 agent 优先用 vdb）

在 `AGENTS.md` §1 Skill/知识加载铁律 之前插入：

```markdown
## 0. 技能检索方法

技能检索使用 `~/.hermes/vdb/` 的 Chroma + SiliconFlow BGE-M3 混合检索系统。
禁用 available_skills 手动匹配。始终用以下方式：

```python
from matcher import search
results = search(query)  # 返回排序后的技能列表
```

只有当 search() 返回空时才走备用：skills_list → skill_view。
```

#### B. 持久化脚本（确保每次会话可用）

创建 `~/.hermes/scripts/vdb-autoload.py`：

```python
"""Hermes 启动时预加载 vdb Chroma + 预热 API 连接"""
import sys, os
sys.path.insert(0, os.path.expanduser("~/.hermes/vdb"))
os.environ.setdefault("SILICONFLOW_API_KEY",
    open(os.path.expanduser("~/.hermes/.env")).read().split("SILICONFLOW_API_KEY=")[1].splitlines()[0].strip().strip("\"'"))
from matcher import search, _get_collection
_get_collection()  # 预热 Chroma
```

然后加可执行：

```bash
chmod +x ~/.hermes/scripts/vdb-autoload.py
```

注意：Hermes 的 scripts 目录在 session 启动时自动执行 `.py` 脚本（根据 `config.yaml` 配置）。

---

## 2. 2026-07-09 已知问题

| 问题 | 现象 | 原因 | 方案 |
|------|------|------|------|
| torch 配额不足 | pip install torch → Disk quota exceeded | Docker overlay 存储配额 < 1GB | sparse.py 纯 Python 等效（零依赖） |
| 首次查询慢 | build_index 后首次 search 513ms | Chroma HNSW + OpenAI client 冷启动 | import matcher 时自动预热（已实现） |
| 空 query | search("") → polymarket 0.35 | 空字符串 embedding 随机语义 | 调用前 check if not query: return |
| disable 下划线 | cli_only vs query "cli only" | 字符串格式不匹配 | matcher.py split→all parts 匹配（已修复） |

---

## 3. disable 标签不生效

```python
from indexer import CHROMA_DIR, COLLECTION_NAME
import chromadb, json
from chromadb.config import Settings

client = chromadb.PersistentClient(str(CHROMA_DIR), settings=Settings(anonymized_telemetry=False))
col = client.get_collection(COLLECTION_NAME)
for m in col.get(include=["metadatas"])["metadatas"]:
    if m["skill_name"] == "target-skill":
        print(json.loads(m["disable_tags"]))
```

常见原因：
- disable_tags 为空列表 → 过滤不触发
- 值不在 DISABLE_TAG_POOL 标准词库 → 拼写错误
- query 不含 disable 关键词 → 用户输入不匹配

---

## 4. 技能更新后索引不同步

手动重建：

```bash
cd ~/.hermes/vdb
source .venv/bin/activate
PYTHONPATH="$PWD" python3 -c "from indexer import build_index; build_index(force=True)"
```

当前无文件监听 watcher（P1.3 未实现），新增/修改 SKILL.md 后手动重建。

---

## 5. API Key / 网络

```
search() → 401 / ConnectionError
```

```bash
# key 是否存在
grep SILICONFLOW_API_KEY ~/.hermes/.env

# 网络连通 + 余额
curl -s https://api.siliconflow.cn/v1/user/info \
  -H "Authorization: Bearer $(grep SILICONFLOW_API_KEY ~/.hermes/.env | cut -d= -f2 | tr -d ' \"')"
```

免费额度：2000 RPM / 500k TPM。超限返回 429。

---

## 6. 查询结果差

```python
from matcher import search

r = search("你的查询", top_k=8)
for x in r:
    print(f"{x['skill_name']:35s} final={x['final_score']:.3f} "
          f"dense={x['dense_score']:.3f} sparse={x['sparse_score']:.3f}")
```

- **dense 低**（<0.4）：语义不匹配，补充中英文 description
- **sparse 低**（<0.1）：关键词不覆盖，加 trigger_tags
- **两者低**：无对应技能

可调权重（`matcher.py` 顶部）：

```python
VEC_WEIGHT = 0.6       # 语义权重
SPARSE_WEIGHT = 0.4    # 关键词精确权重
```
