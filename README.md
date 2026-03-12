# ai-env-setup

Install the SDD (Spec-Driven Development) agent bundle — skills, agents — across
multiple AI coding tools with a single command.

## Supported tools

| Tool | Global config | Project config |
|------|---------------|----------------|
| **OpenCode** | `~/.config/opencode/` | `.opencode/skills/` |
| **Claude Code** | `~/.claude/` | `CLAUDE.md` + `.claude/skills/` |
| **Kiro (AWS)** | `~/.kiro/` | `.kiro/skills/` + `.kiro/steering/` |
| **GitHub Copilot** | `~/.agents/skills/` | `.github/copilot-instructions.md` |
| **Antigravity** | `~/.agents/skills/` | `.github/copilot-instructions.md` |
| **Cursor** | `~/.cursor/rules/` | `.cursorrules` + `.cursor/rules/` |
| **Gemini CLI** | `~/.gemini/` | `GEMINI.md` + `.gemini/skills/` |

## Quick start

### Interactive (recommended)

```bash
git clone https://github.com/drambao/ai-env-setup.git
cd ai-env-setup
./install.sh
```

### One-liner

```bash
curl -fsSL https://raw.githubusercontent.com/drambao/ai-env-setup/main/install.sh | bash
```

### Specific tools

```bash
./install.sh --opencode --claude           # OpenCode + Claude Code, global + project
./install.sh --global --kiro               # Only Kiro, only global
./install.sh --project --copilot --cursor  # Only project level
./install.sh --all                         # Everything
./install.sh --dry-run --all               # Preview without changes
```

## What gets installed

### Skills (9 SDD skills)

| Skill | Purpose |
|-------|---------|
| `sdd-init` | Initialize SDD environment in a project |
| `sdd-propose` | Create a change proposal |
| `sdd-spec` | Write business specs and scenarios |
| `sdd-design` | Technical architecture and design |
| `sdd-task` | Break design into step-by-step tasks |
| `sdd-explore` | Research and explore the codebase |
| `sdd-apply` | Implement tasks (writes code) |
| `sdd-verify` | Verify implementation matches specs |
| `sdd-archive` | Archive and document completed changes |

### Agents (2)

| Agent | Mode | Purpose |
|-------|------|---------|
| `sdd-orchestrator` | all | SDD workflow orchestrator — delegates to sub-agents, never writes code itself |
| `tech-lead` | primary | Senior engineer / tutor — explains concepts, enforces best practices |

## SDD Workflow

```
/sdd-new <name>    →  propose
/sdd-ff <name>     →  propose → spec + design (parallel) → tasks
/sdd-apply <name>  →  apply (in batches of 3-5 tasks)
/sdd-verify        →  verify
/sdd-archive       →  archive
```

All artifacts are stored in `openspec/changes/<name>/`.

## Repository structure

```
ai-env-setup/
├── install.sh              # Main installer (entrypoint)
├── bundle/
│   ├── skills/             # Canonical SKILL.md files (source of truth)
│   │   ├── sdd-init/SKILL.md
│   │   ├── sdd-propose/SKILL.md
│   │   └── ...
│   └── agents/             # Agent definitions (canonical JSON)
│       ├── tech-lead.json
│       └── sdd-orchestrator.json
├── adapters/               # Per-tool transformation logic
│   ├── opencode.sh
│   ├── claude.sh
│   ├── kiro.sh
│   ├── copilot.sh
│   ├── antigravity.sh
│   ├── cursor.sh
│   └── gemini.sh
└── lib/                    # Shared utilities
    ├── common.sh           # Colors, logging, backup, JSON helpers
    ├── menu.sh             # Interactive checkbox menus
    └── transform.sh        # SKILL.md → native format transformers
```

## Requirements

- Bash 4+ (macOS ships Bash 3; install via `brew install bash`)
- python3 (for JSON manipulation — comes with macOS)
- git or curl (for one-liner install)

## Adding skills

1. Add a directory under `bundle/skills/<skill-name>/`
2. Create a `SKILL.md` file with YAML frontmatter:

```markdown
---
name: my-skill
description: >
  What this skill does and when to trigger it.
---

## Instructions
...
```

3. Re-run `./install.sh` to push the new skill to all configured tools.

## Scope: global vs project

| Scope | What it does |
|-------|-------------|
| **Global** | Installs skills and agents into the tool's user-level config directory. Active for every project. |
| **Project** | Creates symlinks and instruction files (CLAUDE.md, .cursorrules, etc.) in the current working directory. Scoped to that repo. |

Both scopes can be enabled simultaneously.

## License

MIT
