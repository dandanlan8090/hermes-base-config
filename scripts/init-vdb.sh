#!/usr/bin/env bash
# vdb 环境一键初始化脚本
# 用法: bash scripts/init-vdb.sh
# 从 repo 根目录运行（或修改 VDB_SRC 路径）

set -euo pipefail

VDB_DST="${HOME}/.hermes/vdb"
VDB_SRC="${VDB_SRC:-$(cd "$(dirname "$0")/.." && pwd)/vdb}"

echo "==> 1. 复制 vdb 工具链到 ~/.hermes/vdb/"
if [ ! -d "$VDB_SRC" ]; then
    echo "错误：找不到 vdb/ 目录（尝试了 $VDB_SRC）"
    echo "请从仓库根目录运行，或设置 VDB_SRC 环境变量"
    exit 1
fi
mkdir -p "$VDB_DST"
cp "$VDB_SRC/sparse.py" "$VDB_SRC/embed.py" "$VDB_SRC/indexer.py" \
   "$VDB_SRC/matcher.py" "$VDB_SRC/__init__.py" "$VDB_DST/"

echo "==> 2. 创建虚拟环境"
python3 -m venv "${VDB_DST}/.venv"
source "${VDB_DST}/.venv/bin/activate"
pip install -q chromadb openai python-dotenv

echo "==> 3. 配置 API Key"
if [ ! -f "${VDB_DST}/.env" ]; then
    if [ -f "$VDB_SRC/.env.example" ]; then
        cp "$VDB_SRC/.env.example" "${VDB_DST}/.env"
        echo "  .env 模板已复制到 ${VDB_DST}/.env"
        echo "  ⚠ 请编辑该文件，填入你的 SILICONFLOW_API_KEY"
    else
        echo "  ⚠ 未找到 .env.example，请手动配置"
    fi
else
    echo "  .env 已存在，跳过"
fi

echo "==> 4. 重建索引"
cd "$VDB_DST"
PYTHONPATH="$PWD" python3 -c "from indexer import build_index; build_index(force=True)"

echo ""
echo "✅ vdb 初始化完成"
echo "   chroma/ 目录已创建（向量存储）"
echo "   现在重启 Hermes 会话即可自动使用 vdb 检索"
