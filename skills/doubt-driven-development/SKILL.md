---
name: doubt-driven-development
description: "怀疑驱动开发：对每个非平凡决策进行全新上下文对抗审查。触发：高风险/生产/安全/不可逆/架构决策。禁用：纯机械操作/用户要求快优先。"
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags:
      trigger:
        - "高风险"
        - "生产环境"
        - "安全性"
        - "不可逆"
        - "架构决策"
        - "production"
        - "security"
        - "架构"
        - "反证"
        - "审查"
      disable:
        - "纯机械操作"
        - "变量重命名"
        - "格式化"
        - "用户要求快"
    skill_type: "methodology"
    priority: "high"
    related_skills: [source-driven-development, code-review-and-audit]
prerequisites:
  commands: [delegate_task]
---

# Doubt-Driven Development（怀疑驱动开发）

## 概述

自信的答案不等于正确的答案。本 skill 的原则是：在任何非平凡输出确立之前，引入一个偏向**反驳**而非批准的全新上下文审查者。

这不是 code review。review 是对已完成产物的裁决。这是飞行中的姿态：非平凡决策在被修正成本还低的时候就被反复质问。

## When to Use

以下任意条件成立时为**非平凡**：
- 引入了或修改了分支逻辑
- 跨越了模块或服务边界
- 正确性依赖于类型系统无法验证的属性（线程安全、幂等性）
- 影响范围不可逆（生产部署、数据迁移）

**触发场景**：
- 即将在不确定性下做架构决策
- 即将提交非平凡代码
- 即将声称非显而易见的事实

**When NOT to use**：
- 机械操作（重命名、格式化、文件移动）
- 用户明确要求速度优先

## 核心流程

```
Doubt cycle:
Step 1: CLAIM     — 写出 claim + 为什么重要
Step 2: EXTRACT   — 提取最小可审查单元（artifact + contract）
Step 3: DOUBT     — 调用全新上下文对抗审查者
Step 4: RECONCILE — 将每个发现归类到 artifact 文本
Step 5: STOP      — 满足停止条件
```

## Step 1：CLAIM — 显式声明决策

```
CLAIM: "新的缓存层在线程安全的读密集型工作负载下是线程安全的。"
WHY THIS MATTERS: 这里的竞争条件会破坏用户数据。
```

## Step 2：EXTRACT — 最小可审查单元

- **代码**：diff 或函数，不是整个文件
- **决策**：3–5 句话的提案 + 必须满足的约束
- **断言**：claim + 据称支撑它的证据

**剥离你的推理**。如果交出结论，得到的是对结论的验证。

## Step 3：DOUBT — 调用全新上下文审查者

审查者的 prompt 必须是**对抗性的**：

```
Adversarial review. Find what is wrong with this artifact.
Assume the author is overconfident. Look for:
- Unstated assumptions
- Edge cases not handled
- Hidden coupling or shared state
- Ways the contract could be violated
- Existing conventions this might break
- Failure modes under unexpected input

Do NOT validate. Do NOT summarize. Find issues.

ARTIFACT: <paste artifact>
CONTRACT: <paste contract>
```

**只传递 ARTIFACT + CONTRACT。不传递 CLAIM。**

## Step 4：RECONCILE — 将发现折叠回去

每个发现按此**优先级顺序**归类：
1. **Contract 误读** — 审查者标记的内容恰恰是因为 CONTRACT 不清晰
2. **有效且可操作** — 需要修改 artifact 的真实问题
3. **有效权衡** — 问题真实存在，但修复成本超出接受成本
4. **噪声** — 审查者标记的内容在上下文下实际是正确的

## Step 5：STOP — 有界循环

满足以下任一条件时停止：
- 下一轮只返回 trivial 发现
- 已完成 3 轮（升级到用户，不再独自磨第四轮）
- 用户明确说"发版"

## 与其他技能的关系

| 技能 | 关系 |
|------|------|
| `source-driven-development` | SDD 验证*框架事实*。Doubt-driven 验证*你对 artifact 的推理*。 |
| `test-driven-development` | TDD 的 RED 步骤是具体化的 doubt。 |
| `hermes-oracle-mode` | Doubt-driven 在主脑模式下运行在编排层。 |

---

**最后更新**: 2026-07-09