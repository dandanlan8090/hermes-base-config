# 2026-07-10: vdb Profile Path Resolution

## 问题

`vdb/indexer.py` 的 `HERMES_HOME` 和 `SKILLS_DIR` 都写死了 `Path.home() / ".hermes"` / `~/.hermes/skills/`，无视 `$HERMES_HOME` 环境变量。profile 会话下（`hermes -p work chat`）Hermes core 设了 `HERMES_HOME=~/.hermes/profiles/work/`，但 indexer 完全忽略，始终扫 `~/.hermes/skills/`，而实际技能在 `$HERMES_HOME/skills` 即 `~/.hermes/profiles/work/skills/`。

## 解法

`indexer.py` 新增 `_get_hermes_home()` 函数，先读 `$HERMES_HOME`，无则回退 `~/.hermes`。`SKILLS_DIR` 从结果推导，`HERMES_SKILL_DIR` 为最高优先级覆盖。`VDB_DIR` 固定在 `~/.hermes/vdb/`（Chroma 全局共享）。

路径优先级：

| 优先级 | 来源 | 示例 |
|--------|------|------|
| 1 | `HERMES_SKILL_DIR` 环境变量 | 临时覆盖，最高优先级 |
| 2 | `HERMES_HOME` 环境变量 | profile 会话自动设 |
| 3 | 默认 `~/.hermes` | 无环境变量时的回退 |

## 历史纠正

本轮会话中第一步错误的解法是写入 `~/.hermes/active_profile` 持久标记文件，被用户纠正：
用户原话"不是验证有，无的区别，而是用户处于 default 还是 profile"。

**教训：** 不要发明新的持久化状态。profile 的上下文信息已通过 `$HERMES_HOME` 环境变量传递（Hermes core 的 profile wrapper 自动设），读取环境变量比读写文件更简单、更可靠。

## 验证矩阵

| 场景 | 期望 SKILLS_DIR | 测试结果 |
|------|----------------|----------|
| 无环境变量，无 active_profile | `~/.hermes/skills/` | PASS |
| `HERMES_HOME=~/.hermes/profiles/work/` + 目录存在 | `~/.hermes/profiles/work/skills/` | PASS |
| `HERMES_SKILL_DIR=/tmp/custom-skills` | `/tmp/custom-skills` | PASS |

## 后续维护

- 新增 profile 支持 CLI 时无需改 `_get_hermes_home()`，Hermes core 的 profile wrapper 已负责设 `HERMES_HOME`
- 如果未来 vdb 也要 per-profile 存储，才需要改 `VDB_DIR`，当前无需
