---
name: hermes-base-config-sync
description: "Hermes Base Config GitHub 同步流程 —— 从本地 Hermes 配置整理通用 SOUL.md/AGENTS.md/USER.md/skills 到开源 repo。触发：更新 hermes-base-config、同步 SOUL.md、发布配置模板、整理技能到 GitHub。禁用：普通 repo push、非 Hermes 配置、未经脱敏的私有资料。"
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags:
      trigger:
        - "hermes-base-config"
        - "同步 SOUL.md"
        - "同步 AGENTS.md"
        - "发布配置模板"
        - "整理技能到 GitHub"
        - "Hermes Base Config"
        - "github sync"
        - "配置 repo"
        - "脱敏发布"
        - "NEW_SKILL_TEMPLATE"
      disable:
        - "普通 git push"
        - "非 Hermes 配置"
        - "未经脱敏"
        - "私有 MEMORY.md"
        - "不发布到开源"
    skill_type: "workflow"
    priority: "high"
    related_skills:
      - "NEW_SKILL_TEMPLATE"
      - "hermes-agent-skill-authoring"
      - "github"
      - "plan"
prerequisites:
  commands:
    - git
    - gh
---

# Hermes Base Config GitHub Sync

## Overview

这个技能用于维护 `hermes-base-config` 这类公开模板仓库：从本地 `~/.hermes/` 提取 SOUL.md / AGENTS.md / USER.md / 核心 skills，整理成通用、脱敏、可复用的 GitHub repo。

核心原则：**本地文件不能直接复制发布。repo 内容必须是通用模板，发布前必须脱敏和结构校验。**

---

## When to Use

- 用户要求整理或更新 Hermes Base Config repo
- 用户要求同步 SOUL.md / AGENTS.md / USER.md 到 GitHub
- 用户要求把本地技能整理为可公开分享的模板
- 用户要求补充 `NEW_SKILL_TEMPLATE.md` 或关联核心技能
- 用户要求维护公开的 Hermes 配置模板仓库

**Do not use for:**
- 普通代码 repo 的 git push
- 私有 MEMORY.md 备份
- 未经脱敏的配置迁移
- 不发布到开源社区的本地个人配置

---

## Canonical Repo Layout

`NEW_SKILL_TEMPLATE.md` 是 `skills/` 目录下的**独立文件**，不是技能目录。

```text
hermes-base-config/
├── README.md
├── LICENSE
├── SOUL.md
├── AGENTS.md
├── USER.md
└── skills/
    ├── NEW_SKILL_TEMPLATE.md
    ├── ai-conv-style-discipline/
    │   └── SKILL.md
    ├── codebase-memory-first/
    │   └── SKILL.md
    ├── doubt-driven-development/
    │   └── SKILL.md
    ├── hermes-agent/
    │   └── SKILL.md
    ├── hermes-oracle-mode/
    │   └── SKILL.md
    ├── hermes-shipping-verification/
    │   └── SKILL.md
    ├── hermes-base-config-sync/
    │   └── SKILL.md
    ├── plan/
    │   └── SKILL.md
    └── source-driven-development/
        └── SKILL.md
```

---

## Absolute Source Files

Use these local source paths only for reading. Do not publish them without sanitization.

```text
~/.hermes/SOUL.md
~/.hermes/AGENTS.md
~/.hermes/memories/USER.md
~/.hermes/memories/MEMORY.md
~/.hermes/skills/NEW_SKILL_TEMPLATE.md
~/.hermes/skills/<category>/<skill>/SKILL.md
```

Publication rule:
- `MEMORY.md` is private by default and must not be published.
- `USER.md` must become a template, not the user's real profile.
- `SOUL.md` must replace personalized identity such as `Hermes-fn` with generic `Hermes`.
- Any path, username, token hint, account name, host name, machine-specific value must be removed or generalized.

---

## Workflow

### Step 1: Load Required Skills

Before any SKILL.md write, load:

```text
skill_view(name='NEW_SKILL_TEMPLATE')
skill_view(name='hermes-agent-skill-authoring')
skill_view(name='github')      # if pushing to GitHub
skill_view(name='plan')        # for multi-step sync
```

Completion criteria:
- NEW_SKILL_TEMPLATE checklist is visible before writing any `*/SKILL.md`.
- Every new skill has frontmatter satisfying the full template, not only Hermes runtime's minimal validator.

### Step 2: Build or Update Plan

Write a plan under `.hermes/plans/` or `~/.hermes/plans/` before mutating files.

Include:
- Target repo path
- Source files
- Sanitization rules
- File list to publish
- Validation commands
- Git push strategy

### Step 3: Stage Files in a Temporary or Repo Workdir

Preferred workdir:

```bash
REPO=/tmp/hermes-base-config
```

If repo does not exist:

```bash
git clone https://github.com/<USER_OR_ORG>/hermes-base-config.git "$REPO"
```

If repo already exists:

```bash
cd "$REPO"
git status --short
git pull --ff-only
```

### Step 4: Sanitize Before Writing Repo Files

Never do blind copy for public repo content. Apply transformations first.

Required replacements:

| Local/private pattern | Public replacement |
|----------------------|--------------------|
| `Hermes-fn` | `Hermes` |
| real GitHub username | `YOUR_USERNAME` or repo owner placeholder |
| `/home/<user>` | `~` or `<HOME>` |
| Windows user path | `~/.hermes/` or `<HERMES_HOME>` |
| hostnames | `<HOSTNAME>` |
| real account names | `<ACCOUNT>` |
| token/PAT hints | remove entirely |
| real hardware inventory | template placeholders |

Do not publish:
- `~/.hermes/memories/MEMORY.md`
- secrets, API keys, PAT scope notes, auth file paths with real accounts
- social media account IDs, phone numbers, emails, machine hostnames
- logs containing tokens or private URLs

### Step 5: Preserve Template Structure

Rules:
- `skills/NEW_SKILL_TEMPLATE.md` stays as a file.
- Normal skills are directories: `skills/<skill-name>/SKILL.md`.
- Repo root contains only public docs/config templates.
- README examples must use `YOUR_USERNAME` or `<USER_OR_ORG>` placeholders.

### Step 6: Validate Skill Frontmatter

For every `skills/*/SKILL.md`, verify:
- `name`, `description`, `version`, `author`, `license`, `platforms`
- `metadata.hermes.tags.trigger` has at least 5 items
- `metadata.hermes.tags.disable` has at least 3 items
- `metadata.hermes.skill_type` is one of `methodology|workflow|tool|integration`
- `metadata.hermes.priority` is one of `highest|high|normal|low`
- body is non-empty

Validation command:

```bash
python3 - <<'PY'
import pathlib, re, sys, yaml
root = pathlib.Path('/tmp/hermes-base-config')
errors = []
for p in sorted(root.glob('skills/*/SKILL.md')):
    text = p.read_text(encoding='utf-8')
    if not text.startswith('---'):
        errors.append(f'{p}: missing frontmatter start')
        continue
    m = re.search(r'\n---\s*\n', text[3:])
    if not m:
        errors.append(f'{p}: missing frontmatter end')
        continue
    fm = yaml.safe_load(text[3:m.start()+3]) or {}
    for key in ['name','description','version','author','license','platforms']:
        if key not in fm:
            errors.append(f'{p}: missing {key}')
    h = (fm.get('metadata') or {}).get('hermes') or {}
    tags = h.get('tags') or {}
    trig = tags.get('trigger') or []
    dis = tags.get('disable') or []
    if len(trig) < 5:
        errors.append(f'{p}: trigger < 5')
    if len(dis) < 3:
        errors.append(f'{p}: disable < 3')
    if h.get('skill_type') not in {'methodology','workflow','tool','integration'}:
        errors.append(f'{p}: invalid/missing skill_type')
    if h.get('priority') not in {'highest','high','normal','low'}:
        errors.append(f'{p}: invalid/missing priority')
    if not text[m.end()+3:].strip():
        errors.append(f'{p}: empty body')
if errors:
    print('\n'.join(errors))
    sys.exit(1)
print('skill frontmatter validation OK')
PY
```

### Step 7: Run Sanitization Scan

Use a denylist scan before commit.

```bash
cd /tmp/hermes-base-config
grep -RInE 'Hermes-fn|dandanlan|/home/lan|C:\\Users\\lan|fnubuntu|ghp_|token|PAT|password|api[_-]?key|secret|老黎|菜鸡的老黎' \
  --include='*.md' . || true
```

Interpretation:
- Expected words like `token` in generic security examples may be acceptable only if no real value or account appears.
- Any real username/account/host/path must be fixed before push.

### Step 8: Verify Repo Structure

```bash
find /tmp/hermes-base-config -maxdepth 3 -type f | sort
```

Must include:

```text
./SOUL.md
./AGENTS.md
./USER.md
./README.md
./LICENSE
./skills/NEW_SKILL_TEMPLATE.md
./skills/<skill>/SKILL.md
```

Must not include:

```text
./MEMORY.md
./skills/NEW_SKILL_TEMPLATE/SKILL.md
```

### Step 9: Commit and Push

```bash
cd /tmp/hermes-base-config
git status --short
git add -A
git commit -m "docs: update Hermes base config templates"
git push
```

If HTTPS remote cannot read username in non-interactive shell, use `gh auth token` only for the push, then reset remote immediately:

```bash
git remote set-url origin "https://$(gh auth token)@github.com/<USER_OR_ORG>/hermes-base-config.git"
git push
git remote set-url origin "https://github.com/<USER_OR_ORG>/hermes-base-config.git"
```

Do not leave token-bearing remote URLs in `.git/config`.

---

## Common Pitfalls

1. **Blind copying local SOUL.md to repo.** Local SOUL.md may contain personalized identity such as `Hermes-fn`. Convert to generic `Hermes` before publishing.

2. **Publishing MEMORY.md.** MEMORY.md contains environment facts, accounts, tokens descriptions, host quirks, and private lessons. It is not part of the public base config.

3. **Turning NEW_SKILL_TEMPLATE.md into a skill folder.** It is a standalone file under `skills/`, not `skills/NEW_SKILL_TEMPLATE/SKILL.md`.

4. **Relying on Hermes runtime validator only.** `skill_manage` only enforces minimal `name` and `description`; community template requires full frontmatter including tags, skill_type, priority.

5. **Not loading NEW_SKILL_TEMPLATE before writing SKILL.md.** AGENTS.md §1.4 makes this action-based: if target path is `*/SKILL.md`, load template first.

6. **Leaving GitHub token in remote URL.** If using `gh auth token` for push, reset origin to non-token URL immediately after push.

7. **README leaking real repo owner.** Public template examples should use `YOUR_USERNAME` or `<USER_OR_ORG>` unless intentionally documenting the canonical upstream.

8. **Assuming current session sees newly created skill.** Skill loader may be cached. Validate file content directly and use a fresh session if needed.

---

## Verification Checklist

- [ ] Plan written before mutations
- [ ] NEW_SKILL_TEMPLATE loaded before any SKILL.md write
- [ ] Repo has `skills/NEW_SKILL_TEMPLATE.md` as a file
- [ ] Repo does not contain `MEMORY.md`
- [ ] USER.md is a template, not a real profile
- [ ] SOUL.md uses generic `Hermes`, not local identity
- [ ] All published skills pass full NEW_SKILL_TEMPLATE frontmatter checklist
- [ ] Sanitization grep returns no private account/path/token/host leakage
- [ ] Git remote does not contain embedded token after push
- [ ] `git log --oneline -1` confirms the intended commit

---

**最后更新**: 2026-07-09