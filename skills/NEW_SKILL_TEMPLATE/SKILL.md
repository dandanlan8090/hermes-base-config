---
新增技能开发规范 (Skill Development Guidelines)
版本: 2.0.0  
生效日期: 2026-06-11  
适用范围: 所有新增或修改的 Hermes Agent 技能
---
📋 Frontmatter 必填字段
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
    skill_type: "methodology|workflow|tool|integration"  # 必填：技能类型
    priority: "highest|high|normal|low"    # 必填：优先级
    next_skill: "下一个技能名"              # 可选：流程链下一个环节
    requires: ["前置技能 1", "前置技能 2"]   # 可选：依赖的前置技能
  homepage: https://github.com/...         # 可选：项目主页
prerequisites:
  commands: [required-cli-command]         # 可选：依赖的 CLI 工具
  env_vars: [REQUIRED_API_KEY]             # 可选：依赖的环境变量
---
```
---
🎯 标签设计原则
正面条件 (trigger) - 至少 5 个
设计准则：
用户视角词汇: 使用用户在自然对话中会用的词，而非技能内部术语
中英文覆盖: 同时包含中文和英文触发词
场景覆盖: 覆盖不同表达方式（同义词、变体）
具体明确: 避免过于宽泛的词（如"工作"、"做"）
✅ 好的例子：
```yaml
trigger: 
  - "新功能"        # 用户自然语言
  - "构建"          # 动作词
  - "implement"     # 英文对应
  - "bug 修复"       # 具体场景
  - "重构"          # 专业术语但常用
```
❌ 坏的例子：
```yaml
trigger: 
  - "工作"          # 过于宽泛
  - "RED-GREEN-REFACTOR"  # 技能内部术语，用户不会说
  - "task"         # 只有英文，缺少中文
```
负面条件 (disable) - 至少 3 个
设计准则：
排除明确场景: 清晰定义何时不应该使用此技能
流程阶段标记: 标注其他流程阶段（避免在错误阶段触发）
技术约束: 标注技术上的限制条件
防止冲突: 避免与相关技能同时触发
✅ 好的例子：
```yaml
disable:
  - "原型"          # 排除场景
  - "需求不明确"     # 流程阶段
  - "subagent"      # 技术约束
  - "已有设计"      # 防止与 brainstorming 冲突
```
❌ 坏的例子：
```yaml
disable:
  - "不要在这个时候使用"  # 不是关键词
  - "测试"           # 过于宽泛，可能与 trigger 冲突
```
---
🔍 技能类型定义
类型	说明	例子
methodology	工作方法论，定义"如何做"	TDD、debugging、brainstorming
workflow	流程控制技能，定义环节顺序	using-superpowers、executing-plans
tool	特定工具/CLI 的使用指南	blogwatcher、markitdown
integration	外部服务/API 集成	slack、notion、github
---
📊 优先级定义
优先级	说明	加载策略	例子
highest	元技能，每会话必加载	会话开始强制加载	using-superpowers、brainstorming
high	核心方法论，任务相关	触发词命中必加载	TDD、debugging、verification
normal	工具/集成技能	触发词命中建议加载	blogwatcher、markitdown
low	辅助/可选技能	仅在明确提到时加载	特定领域工具
---
✅ 新增技能检查清单
在提交新技能前，必须逐项检查：
Frontmatter 检查
[ ] `name` 是小写、连字符分隔、无空格
[ ] `description` 是中英双语、包含触发和禁用说明
[ ] `version` 遵循语义化版本 (MAJOR.MINOR.PATCH)
[ ] `trigger` 标签至少 5 个，覆盖中文和英文
[ ] `disable` 标签至少 3 个，明确排除场景
[ ] `skill_type` 是预定义值之一
[ ] `priority` 是预定义值之一
[ ] `next_skill` 和 `requires` 正确定义（如适用）
标签质量检查
[ ] `trigger` 词汇来自用户自然语言，非技能内部术语
[ ] `trigger` 和 `disable` 无重叠或矛盾
[ ] `disable` 覆盖了常见误触发场景
[ ] 中英文关键词都有覆盖
内容检查
[ ] 技能正文与 frontmatter 描述一致
[ ] 如果有 CLI 依赖，在 `prerequisites.commands` 声明
[ ] 如果有 API key 依赖，在 `prerequisites.env_vars` 声明
[ ] 包含清晰的使用场景和示例
测试检查
[ ] 用 3-5 个不同用户消息测试触发
[ ] 验证在禁用场景下不触发
[ ] 确认与相关技能的优先级关系正确
---
📝 示例模板
示例 1：方法论技能
```yaml
---
name: test-driven-development
description: "测试驱动开发 (TDD) —— 先写失败测试，再写最小实现。触发：新功能/bug 修复/重构。禁用：原型/配置/生成代码（需用户明确同意跳过）。"
version: 2.0.0
author: Jesse Vincent (obra)
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags:
      trigger: 
        - "实现"
        - "功能"
        - "bug 修复"
        - "重构"
        - "新代码"
        - "implement"
        - "feature"
        - "bugfix"
        - "fix"
        - "refactor"
        - "test"
      disable: 
        - "原型"
        - "prototype"
        - "配置"
        - "generated"
        - "生成代码"
        - "一次性"
        - "throwaway"
    skill_type: "methodology"
    priority: "high"
    requires: ["brainstorming", "writing-plans"]
---

# Test-Driven Development (TDD)

[技能正文内容...]
```
示例 2：工具技能
```yaml
---
name: markitdown
description: "文档转 Markdown —— 支持 PDF/Word/PPT/Excel。触发：文档转换、提取内容、转 markdown。禁用：图像分析、自定义处理管道。"
version: 1.0.0
author: Microsoft
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags:
      trigger:
        - "文档转换"
        - "转 markdown"
        - "提取内容"
        - "PDF"
        - "Word"
        - "PPT"
        - "Excel"
        - "convert"
        - "document"
      disable:
        - "图像分析"
        - "自定义处理"
        - "批量管道"
        - "image analysis"
    skill_type: "tool"
    priority: "normal"
prerequisites:
  commands: [markitdown]
---

# MarkItDown

[技能正文内容...]
```
---
🔧 维护流程
发现误触发/漏触发时
记录问题: 什么用户消息触发了错误的技能（或未触发正确技能）？
分析标签: 是 trigger 范围太宽/太窄？还是 disable 缺少场景？
更新标签: 修改 `trigger`/`disable` 列表
测试验证: 用类似消息重新测试
提交更新: 更新 `version` 号，提交更改
版本更新规范
MAJOR: 破坏性变更（技能流程、核心规则改变）
MINOR: 新增功能或标签优化（向后兼容）
PATCH: 修正 typo、补充说明（不影响行为）
---
📚 参考文档
技能索引: `skills/SKILL_INDEX.md`
标签系统: 见本文件"标签设计原则"章节
SOUL.md: `~/.hermes/SOUL.md` — 人格定义中的技能加载规则
AGENTS.md: `~/.hermes/AGENTS.md` — 架构指南
---
本规范随技能系统演进而更新，每次重大调整都应同步修订此文档。
