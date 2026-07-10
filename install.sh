#!/usr/bin/env bash
# Hermes Base Config 安装脚本
#
# 用法:
#   bash install.sh             自动检测新装/存量
#   bash install.sh --force     强制全量覆盖（新装机）
#   bash install.sh --dry       预览变更不执行
#
# 重点文件说明:
#   SOUL.md, AGENTS.md, memories/USER.md
#   如果是已有用户（~/.hermes/ 存在），这三个文件不会被覆盖。
#   新装机用户会全部复制。
#   已有用户请手动 diff 后按需合并。

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
HERMES_DIR="${HOME}/.hermes"
IS_NEW=false
FORCE=false
DRY=false

# ── 参数 ────────────────────────────────────────────────────────────
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=true ;;
        --dry)   DRY=true ;;
    esac
done

if [ ! -d "$HERMES_DIR" ]; then
    IS_NEW=true
fi

echo "=========================================="
echo " Hermes Base Config — 安装脚本"
echo "=========================================="
echo ""
echo "  源目录: $REPO_DIR"
echo "  目标目录: $HERMES_DIR"
if $IS_NEW; then
    echo "  类型: 全新安装"
elif $FORCE; then
    echo "  类型: 强制覆盖"
else
    echo "  类型: 存量更新（保留核心配置）"
fi
echo ""

# ── 函数: 复制 ───────────────────────────────────────────────────────
do_cp() {
    local src="$1" dst="$2" label="$3"
    if $DRY; then
        echo "  [DRY] cp -r $src $dst  ← $label"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    cp -r "$src" "$dst"
    echo "  ✓ $label"
}

# ── 1. 核心配置（按新装/存量决定）─────────────────────────────────
echo "── 第 1 步: 核心配置 ―――――――――――――――――――――――――――――――――――"

if $IS_NEW || $FORCE; then
    # 新装机: 全量复制
    do_cp "$REPO_DIR/SOUL.md"            "$HERMES_DIR/SOUL.md"                      "SOUL.md"
    do_cp "$REPO_DIR/AGENTS.md"          "$HERMES_DIR/AGENTS.md"                    "AGENTS.md"
    do_cp "$REPO_DIR/memories/USER.md"   "$HERMES_DIR/memories/USER.md"             "memories/USER.md"
else
    # 存量用户: 警告 + 跳过
    echo "  ⚠ 检测到已有 ~/.hermes/ 目录（存量用户）"
    echo "  ⚠ SOUL.md / AGENTS.md / memories/USER.md 不会被自动覆盖"
    echo "  ⚠ 请手动对比后按需合并:"
    echo "     diff -u ~/.hermes/SOUL.md  $REPO_DIR/SOUL.md"
    echo "     diff -u ~/.hermes/AGENTS.md $REPO_DIR/AGENTS.md"
    echo "     diff -u ~/.hermes/memories/USER.md $REPO_DIR/memories/USER.md"
    echo ""
fi

# ── 2. .env 模板 ────────────────────────────────────────────────────
echo "── 第 2 步: .env 配置 ―――――――――――――――――――――――――――――――――――"
if [ ! -f "$HERMES_DIR/.env" ]; then
    do_cp "$REPO_DIR/.env.example" "$HERMES_DIR/.env" ".env（模板）"
    echo "   请编辑 $HERMES_DIR/.env，填入你的 SILICONFLOW_API_KEY"
else
    echo "  ✓ .env 已存在，跳过（需要新字段请手动合并）"
fi
echo ""

# ── 3. 技能目录 ─────────────────────────────────────────────────────
echo "── 第 3 步: 技能目录 ―――――――――――――――――――――――――――――――――――"
if [ -d "$REPO_DIR/skills" ]; then
    # 存量用户: 只补不删（不覆盖已有技能）
    count_before=$(find "$HERMES_DIR/skills" -name "SKILL.md" 2>/dev/null | wc -l)
    if $IS_NEW || $FORCE; then
        do_cp "$REPO_DIR/skills/" "$HERMES_DIR/skills/" "skills/（全量）"
    else
        # 只补充不覆盖
        for skill_dir in "$REPO_DIR/skills"/*/; do
            name=$(basename "$skill_dir")
            target="$HERMES_DIR/skills/$name"
            if [ ! -d "$target" ]; then
                do_cp "$skill_dir" "$target" "skills/$name（新增）"
            else
                echo "  - skills/$name 已存在，跳过"
            fi
        done
        # 根目录 .md 技能文件
        for skill_file in "$REPO_DIR/skills"/*.md; do
            [ -f "$skill_file" ] || continue
            name=$(basename "$skill_file")
            target="$HERMES_DIR/skills/$name"
            if [ ! -f "$target" ]; then
                do_cp "$skill_file" "$target" "skills/$name（新增）"
            else
                echo "  - skills/$name 已存在，跳过"
            fi
        done
    fi
    count_after=$(find "$HERMES_DIR/skills" -name "SKILL.md" 2>/dev/null | wc -l)
    echo "  技能总数: $count_before → $count_after"
fi
echo ""

# ── 4. vdb 工具链 ──────────────────────────────────────────────────
echo "── 第 4 步: vdb 工具链 ――――――――――――――――――――――――――――――――"
if [ -d "$REPO_DIR/vdb" ]; then
    mkdir -p "$HERMES_DIR/vdb"
    for f in sparse.py embed.py indexer.py matcher.py __init__.py; do
        if [ -f "$REPO_DIR/vdb/$f" ]; then
            do_cp "$REPO_DIR/vdb/$f" "$HERMES_DIR/vdb/$f" "vdb/$f"
        fi
    done
fi
echo ""

# ── 5. scripts ──────────────────────────────────────────────────────
echo "── 第 5 步: 辅助脚本 ――――――――――――――――――――――――――――――――――"
if [ -d "$REPO_DIR/scripts" ]; then
    mkdir -p "$HERMES_DIR/scripts"
    for f in "$REPO_DIR/scripts"/*; do
        name=$(basename "$f")
        do_cp "$f" "$HERMES_DIR/scripts/$name" "scripts/$name"
    done
fi
echo ""

# ── 6. vdb 环境初始化 ──────────────────────────────────────────────
echo "── 第 6 步: vdb 环境初始化 ――――――――――――――――――――――――――――――"
if $DRY; then
    echo "  [DRY] 跳过环境初始化"
elif $IS_NEW || $FORCE; then
    echo "  运行: bash $HERMES_DIR/scripts/init-vdb.sh"
    bash "$HERMES_DIR/scripts/init-vdb.sh"
else
    echo "  检测到已有 ~/.hermes/vdb/.venv，跳过"
    echo "  如需重建: bash $HERMES_DIR/scripts/init-vdb.sh"
fi
echo ""

# ── 完成 ────────────────────────────────────────────────────────────
echo "=========================================="
if $DRY; then
    echo " DRY RUN 完成 — 未执行任何实际变更"
else
    echo " 安装完成"
    echo ""
    echo " 下一步:"
    if $IS_NEW; then
        echo "   1. 编辑 $HERMES_DIR/.env 填入 API Key"
        echo "   2. 重启 Hermes 会话"
        echo "   3. 运行 'hermes chat' 验证 vdb 自动加载"
    else
        echo "   1. 手动合并 SOUL.md / AGENTS.md（见上方提示）"
        echo "   2. 重启 Hermes 会话"
    fi
fi
echo "=========================================="
