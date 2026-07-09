---
name: new-skill-template
description: "新增技能开发规范 (Skill Development Guidelines) — 触发：创建新技能/修改现有技能/写 SKILL.md。禁用：纯文档修改/配置调整。"
version: 2.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags:
      trigger:
        - "新技能"
        - "创建技能"
        - "skill"
        - "技能开发"
        - "new skill"
        - "authoring"
        - "写 SKILL"
        - "新建技能目录"
        - "修改 frontmatter"
        - "写技能"
      disable:
        - "纯文档"
        - "配置修改"
        - "不需要创建技能"
    skill_type: "methodology"
    priority: "highest"
prerequisites:
  commands: []
---

# 新增技能开发规范 (Skill Development Guidelines)

版本: 2.0.0
生效日期: 2026-06-11
适用范围: 所有新增或修改的 Hermes Agent 技能

---

## Frontmatter 必填字段

每个技能的 `SKILL.md` frontmatter 必须包含以下字段：

```yaml
---
name: skill-name                          # 必填：技能名（小写，连字符分隔）
description: "中文描述 —— 触发场景。禁用：排除场景。"  # 必填：中英双语，简洁明确
version: 2.0.0                             # 必填：语义化版本号
author: 作者名                              # 必填
license: MIT                               # 必填
platforms: [linux, macos, windows]         # 必填：支持的平台
metadata:
  hermes:
    tags:
      trigger: ["正面条件 1", "正面条件 2", ...]    # 必填：触发关键词（至少 5 个）
      disable: ["负面条件 1", "负面条件 2", ...]    # 必填：禁用场景（至少 3 个）
    skill_type: "methodology|workflow|tool|integration"  # 必填
    priority: "highest|high|normal|low"    # 必填
    next_skill: "下一个技能名"              # 可选：流程链下一个环节
    requires: ["前置技能 1", "前置技能 2"]   # 可选：依赖的前置技能
  homepage: https://github.com/...         # 可选
prerequisites:
  commands: [required-cli-command]         # 可选
  env_vars: [REQUIRED_API_KEY]             # 可选
---
```

---

## 标签设计原则

### trigger（至少 5 个）
- 用户视角词汇：用用户在自然对话中会说的词
- 中英文覆盖：同时包含中文和英文触发词
- 覆盖不同表达方式（同义词、变体）
- 具体明确：避免过于宽泛的词（如"工作"、"做"）

**标签在 vdb 语义匹配中的双重作用**：
1. **稠密向量侧**：tags 拼接在 name+desc 后送入 SiliconFlow BGE-M3（云端 1024d）
2. **稀疏打分侧**：仅 trigger_tags → 本地纯 Python lexical weights → `compute_lexical_matching_score` 与 query 关键词匹配 → 加权融合（0.6 × dense_cosine + 0.4 × sparse_lexical）

因此 trigger 标签质量直接影响召回：
- 标签越精准语义匹配越好
- 建议标签粒度在 2-6 字之间，太短（1字）向量表达弱

### disable（至少 3 个）
- 排除明确场景
- 流程阶段标记
- 技术约束
- 防止与其他技能冲突
- disable 标签不进向量文本，只用于检索后过滤（fuzzy 匹配 ≥ 0.7 则排除）

**必须从以下固定词库选取**，禁止自定义笼统文本（如"无关任务"、"不适用场景"）：

```
DISABLE_TAG_POOL = [
    "cli_only",            # 仅 CLI/TUI 可用，gateway 平台无效
    "long_context",        # 需大量上下文，不适合轻量查询触发
    "code_development",    # 纯代码开发类，不适合运维/问答场景
    "document_parse",      # 文档解析密集型，不适合快速响应
    "network_request",     # 发起外部 API/网络调用
    "windows_only",        # Windows 平台限定
    "deep_review",         # 深度审查/分析，不适合轻量触发
    "platform_gateway",    # 仅 gateway 消息平台可用
    "creative_gen",        # 图片/音视频生成类
    "read_only",           # 只读操作，不修改系统
]
```

选择原则：
- `cli_only`：仅在终端交互时可用，Telegram/Discord 等 gateway 平台不宜触发
- `long_context`：技能自身有大量参考文档，压缩成本高
- `deep_review`：一次性消耗大量 token，不适合频繁触发
- `network_request`：需要联网权限，沙箱环境不可用
- `read_only`：放宽限制，用户只查不问时倾向此类技能

---

## 技能类型定义

| 类型 | 说明 | 例子 |
|------|------|------|
| methodology | 工作方法论，定义"如何做" | TDD、debugging、brainstorming |
| workflow | 流程控制技能，定义环节顺序 | plan、hermes-oracle-mode |
| tool | 特定工具/CLI 的使用指南 | github、blogwatcher |
| integration | 外部服务/API 集成 | notion、airtable |

---

## 优先级定义

| 优先级 | 说明 | 加载策略 |
|--------|------|----------|
| highest | 元技能，每会话必加载 | 会话开始强制加载 |
| high | 核心方法论，任务相关 | 触发词命中必加载 |
| normal | 工具/集成技能 | 触发词命中建议加载 |
| low | 辅助/可选技能 | 仅在明确提到时加载 |

---

## 新增技能检查清单

**Frontmatter 检查：**
- [ ] `name` 是小写、连字符分隔、无空格
- [ ] `description` 是中英双语、包含触发和禁用说明
- [ ] `version` 遵循语义化版本 (MAJOR.MINOR.PATCH)
- [ ] `trigger` 标签至少 5 个，覆盖中文和英文
- [ ] `disable` 标签至少 3 个，明确排除场景
- [ ] `skill_type` 和 `priority` 是预定义值

**标签质量检查：**
- [ ] `trigger` 词汇来自用户自然语言，非技能内部术语
- [ ] `trigger` 和 `disable` 无重叠或矛盾
- [ ] `disable` 覆盖了常见误触发场景

**内容检查：**
- [ ] 技能正文与 frontmatter 描述一致
- [ ] 包含清晰的使用场景和示例
- [ ] 有明确的红线（red flags）和常见借口（rationalizations）

---

## 版本更新规范

- **MAJOR**：破坏性变更（技能流程、核心规则改变）
- **MINOR**：新增功能或标签优化（向后兼容）
- **PATCH**：修正 typo、补充说明（不影响行为）

---

## 元触发说明

本技能通过 AGENTS.md §1.4 实现强制加载：
当 `write_file` / `patch` 的目标是 `*/SKILL.md` 文件时，无论用户消息内容是什么，
都必须先加载本技能并完成 checklist 核对。

---

**最后更新**: 2026-07-09