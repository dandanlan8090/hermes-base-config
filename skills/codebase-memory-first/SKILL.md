---
name: codebase-memory-first
description: "工作流钩子：任何编码/重构/排查任务前，先查询 codebase-memory 代码图谱"
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags:
      trigger:
        - "代码修改"
        - "重构"
        - "bug 排查"
        - "code review"
        - "死代码"
        - "调用链"
      disable:
        - "纯文档"
        - "配置修改"
        - "一次性脚本"
    skill_type: "workflow"
    priority: "high"
    related_skills: [plan, codebase-memory-mcp]
prerequisites:
  commands: [codebase-memory-mcp]
---

# Codebase-First 工作流钩子

## 触发条件

**核心规则：任何涉及代码的任务前必须执行此钩子**（用户没说"不用 skill"时）。

**任务类型**：
- 新增功能 / 修改现有代码
- 重构 / 提取函数 / 移动文件
- 排查 bug / 追踪调用链
- Code Review

**豁免**：
- "不用 skill，直接干"
- 纯文档修改
- 配置文件调整（yaml/json/env）
- 一次性脚本（< 20 行）

---

## 执行步骤

### Step 1: 确认已索引项目

```bash
codebase-memory-mcp cli list_projects
```

如果项目列表为空，立即索引：
```bash
codebase-memory-mcp cli index_repository '{"repo_path":"$(pwd)","project_name":"<name>"}'
```

### Step 2: 根据任务类型选择查询

#### 场景 A: 查找函数实现位置
```bash
codebase-memory-mcp cli search_graph '{"project":"<name>","name_pattern":".*<FunctionName>.*","limit":10}'
```

#### 场景 B: 追踪调用链（谁调用这个函数）
```bash
codebase-memory-mcp cli trace_path '{"project":"<name>","function_name":"<func>","direction":"inbound"}'
```

#### 场景 C: 获取架构概览
```bash
codebase-memory-mcp cli get_architecture '{"project":"<name>"}'
```

### Step 3: 将结果写入 Plan

在 `.hermes/plans/` 中添加"Codebase Memory 查询结果"章节。

---

## 与 plan skill 的关系

此钩子是 `plan` 的**前置步骤**：

```
用户任务 → codebase-memory-first → plan → todo 推进 → 执行
```

---

## 常见问题

- **项目名称不是路径**：用 `list_projects` 查实际项目名称
- **大仓库索引 OOM**：>20K 文件分目录索引，或增加 swap
- **查询结果过多**：加 `limit` 参数

---

**最后更新**: 2026-07-09