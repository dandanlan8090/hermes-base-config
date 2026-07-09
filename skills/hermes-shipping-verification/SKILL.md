---
name: hermes-shipping-verification
description: "Hermes 发布验证：在部署到生产前执行完整质量门控和回滚计划。触发：发布/部署/上线/回滚。禁用：开发环境内部测试/纯功能开发。"
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags:
      trigger:
        - "发布"
        - "部署"
        - "上线"
        - "生产"
        - "deploy"
        - "ship"
        - "release"
        - "回滚"
        - "rollback"
        - "monitoring"
      disable:
        - "开发环境"
        - "本地测试"
        - "纯功能开发"
    skill_type: "workflow"
    priority: "high"
    related_skills: [hermes-oracle-mode, test-driven-development]
prerequisites:
  commands: [delegate_task, terminal]
---

# Hermes Shipping Verification（发布验证）

## 概述

安全发布，不只是部署。目标是：部署时已配套监控、回滚方案就绪、对何为成功有清晰认知。每次发布必须可逆、可观测、增量进行。

## When to Use

- 首次将特性部署到生产
- 向用户发布重大变更
- 迁移数据或基础设施

**When NOT to use**：
- 开发环境内部测试
- 纯功能开发阶段

---

## 发布前质量门控

### 代码质量
- [ ] 所有测试通过
- [ ] 构建成功，无警告
- [ ] Lint 和类型检查通过
- [ ] 代码审查通过并批准

### 安全性
- [ ] 代码中无 secrets
- [ ] 依赖审计无 critical 漏洞
- [ ] 认证和授权检查到位

### 基础设施
- [ ] 生产环境变量已设置
- [ ] 健康检查端点存在且正常响应
- [ ] 日志和错误上报已配置

---

## 回滚策略

每种部署前必须有回滚计划：

```markdown
## 回滚计划 for [特性/发布]

### 触发条件
- 错误率 > 基线 2 倍
- P95 延迟 > [X]ms

### 回滚步骤
1. 禁用 feature flag（如适用）
   或
1. 部署前一版本：`git revert <commit> && git push`
2. 验证回滚：健康检查、错误监控

### 回滚时间
- Feature flag：< 1 分钟
- 重新部署前一版本：< 5 分钟
```

---

## 立即回滚条件

- 错误率增长超过基线 2 倍
- P95 延迟增长超过基线 50%
- 用户报告问题激增
- 检测到数据完整性问题
- 发现安全漏洞

---

## Feature Flag 策略

```
Feature flag 生命周期：
1. DEPLOY with flag OFF     → 代码在生产但未激活
2. ENABLE for team/beta     → 在生产环境做内部测试
3. GRADUAL ROLLOUT          → 5% → 25% → 50% → 100% 用户
4. MONITOR at each stage    → 监控错误率、性能、用户反馈
5. CLEAN UP                 → 完全推广后移除 flag
```

---

## 发布判定阈值

| 指标 | 推进（绿色） | 暂停调查（黄色） | 回滚（红色） |
|------|------------|----------------|------------|
| 错误率 | 在基线 10% 以内 | 基线上 10-100% | >基线 2 倍 |
| P95 延迟 | 在基线 20% 以内 | 基线上 20-50% | >基线 50% |

---

## Red Flags

- 部署时没有回滚计划
- 生产没有监控或错误上报
- 大爆炸发布（一次性全量）
- Feature flag 无到期日或 owner

---

**最后更新**: 2026-07-09