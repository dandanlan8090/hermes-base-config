---
name: source-driven-development
description: "源码驱动开发：每个框架相关实现决策必须引用官方文档。触发：框架/library/boilerplate/best practice。禁用：纯逻辑/typo修复/用户不要验证。"
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags:
      trigger:
        - "框架"
        - "官方文档"
        - "源码"
        - "best practice"
        - "framework"
        - "library"
        - "boilerplate"
        - "API 签名"
        - "implement"
      disable:
        - "纯逻辑"
        - "typo修复"
        - "文件移动"
        - "用户不要验证"
    skill_type: "methodology"
    priority: "high"
    related_skills: [plan, doubt-driven-development]
prerequisites:
  commands: [terminal, web_extract]
---

# Source-Driven Development（源码驱动开发）

## 核心原则

每个框架相关代码决策必须以官方文档为依据。不用记忆实现——先验证、再引用、让用户看到来源。

训练数据会过时，API 会废弃，最佳实践会演进。本 skill 确保用户获得的代码可信赖：每个模式都能追溯到可核查的权威来源。

## When to Use

- 用户要求代码遵循当前最佳实践
- 构建 boilerplate、起始代码、跨项目复制的模式
- 实现依赖框架推荐方式的特性
- **即将凭记忆写框架相关代码时**

**When NOT to use**：
- 纯逻辑，所有版本通用（循环、条件、数据结构）
- 用户明确要求速度优先（"快就行"）

## 核心流程

```
DETECT ──→ FETCH ──→ IMPLEMENT ──→ CITE
```

## Step 1：检测堆栈和版本

| 依赖文件 | 堆栈 |
|---------|------|
| `package.json` | Node / React / Vue |
| `requirements.txt` / `pyproject.toml` | Python / Django / Flask |
| `go.mod` | Go |
| `Cargo.toml` | Rust |

## Step 2：获取官方文档

**来源权威性优先级**：
1. 官方文档（react.dev, docs.djangoproject.com）
2. 官方博客 / changelog
3. Web 标准参考（MDN）
4. 浏览器/运行时兼容性（caniuse.com）

**非权威来源，不得作为主要引用**：Stack Overflow 答案、博客、AI 生成的摘要。

## Step 3：按文档模式实现

- 使用文档中的 API 签名，不用记忆
- 文档展示了新方式，用新方式
- 文档废弃了某模式，不用废弃版本

## Step 4：引用来源

每个框架特定模式必须附引用：

```typescript
// React 19 表单处理 with useActionState
// Source: https://react.dev/reference/react/useActionState#usage
const [state, formAction, isPending] = useActionState(submitOrder, initialState);
```

**引用规则**：
- 完整 URL，不缩短
- 优先带锚点的深度链接
- 找不到文档的模式，必须显式声明 `UNVERIFIED: 未找到该模式的官方文档`

## Common Rationalizations

| 常见借口 | 真相 |
|---------|------|
| "我对这个 API 很有把握" | 训练数据中含有过时模式。必须验证。 |
| "获取文档浪费 token" | 虚构 API 更浪费。获取一次，防止大量返工。 |
| "提一下可能过时就行了" | 免责声明没有帮助。要么验证并引用，要么明确标注未验证。 |

## Red Flags

- 写框架相关代码但未检查该版本的文档
- 用"我相信"/"我觉得"描述 API 而不引用来源
- 实施某模式但不知道它适用于哪个版本
- 引用 Stack Overflow 而非官方文档

---

**最后更新**: 2026-07-09