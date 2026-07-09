"""Hermes 启动时预加载 vdb Chroma + 预热 API 连接

放置位置: ~/.hermes/scripts/vdb-autoload.py
Hermes session 启动时自动执行此脚本（需 config.yaml 启用 scripts 目录）。
"""

import sys, os

VDB_DIR = os.path.expanduser("~/.hermes/vdb")
ENV_PATH = os.path.expanduser("~/.hermes/.env")

# 确保 vdb 在 Python 路径
if VDB_DIR not in sys.path:
    sys.path.insert(0, VDB_DIR)

# 从 .env 读取 API Key
if not os.environ.get("SILICONFLOW_API_KEY"):
    if os.path.exists(ENV_PATH):
        for line in open(ENV_PATH):
            if line.startswith("SILICONFLOW_API_KEY="):
                val = line.split("=", 1)[1].strip().strip("\"'")
                os.environ["SILICONFLOW_API_KEY"] = val
                break

# 预热 Chroma —— import matcher 即触发 _get_collection()
from matcher import search, _get_collection
_get_collection()
print("[vdb] Chroma 预热完成")
