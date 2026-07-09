---
name: plan
description: "Plan mode: write an actionable markdown plan to .hermes/plans/, no execution. Bite-sized tasks, exact paths, complete code. Trigger: any task that will fire tool calls (ops/deploy/bugfix/SRE/coding)."
version: 2.1.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags:
      trigger:
        - "plan"
        - "planning"
        - "计划"
        - "实施计划"
        - "implementation plan"
        - "实现方案"
      disable:
        - "纯查询"
        - "单轮问答"
        - "不需要执行"
    skill_type: "workflow"
    priority: "high"
    related_skills: [codebase-memory-first, subagent-driven-development, test-driven-development]
prerequisites:
  commands: []
---

# Plan Mode

Use this skill when the **task will involve tool calls and is non-trivial enough to deserve a structured plan** (multi-step operations, multi-file changes, subagent dispatch, debug flows, deployment, refactors, etc.).

## 核心规则

**任何触发工具调用的任务必须在执行前先写 plan**（terminal / file / patch / execute_code / delegate_task / cronjob）。

**豁免**：纯文本回答、一次性 read-only 查询。

## 核心行为

For this turn, you are planning only:
- Do not implement code
- Do not edit project files except the plan markdown file
- Do not run mutating terminal commands, commit, push, or perform external actions
- Your deliverable is a markdown plan saved inside the active workspace under `.hermes/plans/`

## 保存位置

```bash
.hermes/plans/YYYY-MM-DD_HHMMSS-<slug>.md
```

## 计划结构

Every plan **MUST** start with:

```markdown
# [Feature Name] Implementation Plan

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---

## Codebase Memory 查询结果（代码任务必填）

**查询类型：** [search_graph / trace_path / get_architecture]

**关键发现：**
- 相关文件：[path1, path2]
- 调用链：[A → B → C]

---

## Task Structure

### Task N: [Descriptive Name]

**Objective:** What this task accomplishes

**Files:**
- Create: `exact/path/to/new_file.py`
- Modify: `exact/path/to/existing.py:45-67`

**Step 1: [具体步骤]**
**Step 2: [具体步骤]**
...
```

## Task 粒度

**每个 task = 2-5 分钟的专注工作。**

```markdown
### Task 1: Create User model with email field
[10 lines, 1 file]

### Task 2: Add password hash field to User
[8 lines, 1 file]
```

## 前置步骤：Codebase-First

Before writing the plan for any code modification task:
1. Load `codebase-memory-first` skill
2. Run `codebase-memory-mcp cli list_projects`
3. Run appropriate queries (search_graph / trace_path / get_architecture)
4. Document findings in the plan

## 交互风格

- If the request is clear enough, write the plan directly
- If it is genuinely underspecified, ask a brief clarifying question instead of guessing
- After saving the plan, reply briefly with what you planned and the saved path

## 交付后

Offer execution approach:

**"Plan complete. Ready to execute using subagent-driven-development — dispatch a fresh subagent per task with two-stage review (spec compliance then code quality). Shall I proceed?"**

---

**最后更新**: 2026-07-09