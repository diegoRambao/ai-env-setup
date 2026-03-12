#!/usr/bin/env bash
# lib/transform.sh — Transforms canonical SKILL.md and agent JSON files
# into the native formats required by each AI tool.
# Sourced by adapters. Do NOT execute directly.

# =============================================================================
# SKILLS: OpenCode / Claude Code / .agents (SKILL.md is the native format)
# =============================================================================

# Install all skills as SKILL.md files into a target directory.
# Usage: install_skills_as_skillmd <bundle_skills_dir> <target_dir>
install_skills_as_skillmd() {
  local src="$1"     # e.g. $BUNDLE_DIR/skills
  local dst="$2"     # e.g. ~/.config/opencode/skills

  ensure_dir "$dst"

  local count=0
  for skill_dir in "$src"/*/; do
    [[ -f "$skill_dir/SKILL.md" ]] || continue
    local skill_name
    skill_name="$(basename "$skill_dir")"
    local target_skill_dir="$dst/$skill_name"
    ensure_dir "$target_skill_dir"

    if [[ -f "$target_skill_dir/SKILL.md" ]]; then
      backup_if_exists "$target_skill_dir/SKILL.md"
    fi
    safe_copy "$skill_dir/SKILL.md" "$target_skill_dir/SKILL.md"
    log_ok "Installed skill: $skill_name"
    count=$(( count + 1 ))
  done

  log_info "Installed $count skills to $dst"
}

# =============================================================================
# AGENTS: OpenCode (inject into opencode.json)
# =============================================================================

# Inject all agents from bundle/agents/*.json into an opencode.json file.
# Usage: inject_agents_opencode <bundle_agents_dir> <opencode_json_path>
inject_agents_opencode() {
  local agents_dir="$1"
  local config_file="$2"

  require_python3 || return 1

  if [[ ! -f "$config_file" ]]; then
    log_warn "opencode.json not found at $config_file — creating minimal config."
    if [[ "$DRY_RUN" != "true" ]]; then
      cat > "$config_file" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {}
}
EOF
    else
      log_dim "[dry-run] Would create $config_file"
    fi
  fi

  backup_if_exists "$config_file"

  for agent_file in "$agents_dir"/*.json; do
    [[ -f "$agent_file" ]] || continue
    local agent_name
    agent_name="$(python3 -c "import json,sys; d=json.load(open('$agent_file')); print(d['name'])")"

    if [[ "$DRY_RUN" == "true" ]]; then
      log_dim "[dry-run] Would inject agent '$agent_name' into $config_file"
      continue
    fi

    python3 - "$config_file" "$agent_file" "$agent_name" <<'PYEOF'
import json, sys

config_path = sys.argv[1]
agent_path  = sys.argv[2]
agent_name  = sys.argv[3]

with open(config_path) as f:
    config = json.load(f)

with open(agent_path) as f:
    agent = json.load(f)

# Remove the "name" key — OpenCode uses the key name, not an internal name field
agent_body = {k: v for k, v in agent.items() if k != "name"}

config.setdefault("agent", {})[agent_name] = agent_body

with open(config_path, "w") as f:
    json.dump(config, f, indent=2, ensure_ascii=False)
    f.write("\n")
PYEOF
    log_ok "Injected agent '$agent_name' into $(basename "$config_file")"
  done
}

# =============================================================================
# AGENTS: Kiro (create agents/*.json files in kiro format)
# =============================================================================

# Transform bundle agent JSON files into Kiro-compatible agent configs.
# Usage: install_agents_kiro <bundle_agents_dir> <kiro_agents_dir>
install_agents_kiro() {
  local src="$1"   # e.g. $BUNDLE_DIR/agents
  local dst="$2"   # e.g. ~/.kiro/agents

  require_python3 || return 1
  ensure_dir "$dst"

  for agent_file in "$src"/*.json; do
    [[ -f "$agent_file" ]] || continue

    local agent_name
    agent_name="$(python3 -c "import json,sys; d=json.load(open('$agent_file')); print(d['name'])")"
    local kiro_file="$dst/${agent_name}.json"

    if [[ -f "$kiro_file" ]]; then
      backup_if_exists "$kiro_file"
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
      log_dim "[dry-run] Would create Kiro agent: $kiro_file"
      continue
    fi

    python3 - "$agent_file" "$kiro_file" <<'PYEOF'
import json, sys

src_path = sys.argv[1]
dst_path = sys.argv[2]

with open(src_path) as f:
    src = json.load(f)

# Kiro agent_config.json format
kiro = {
    "name":           src.get("name", ""),
    "description":    src.get("description", ""),
    "prompt":         src.get("prompt", None),
    "mcpServers":     {},
    "tools":          list(src.get("tools", {}).keys()) if isinstance(src.get("tools"), dict) else ["read", "write", "shell"],
    "toolAliases":    {},
    "allowedTools":   [],
    "resources":      [],
    "hooks":          {},
    "toolsSettings":  {},
    "includeMcpJson": True,
    "model":          None
}

with open(dst_path, "w") as f:
    json.dump(kiro, f, indent=2, ensure_ascii=False)
    f.write("\n")
PYEOF
    log_ok "Created Kiro agent: $agent_name"
  done
}

# =============================================================================
# INSTRUCTIONS: Generate tool-specific instruction files from SKILL.md files
# =============================================================================

# Build a consolidated instruction markdown document from all skills.
# Used for Claude (CLAUDE.md), Copilot (copilot-instructions.md), etc.
# Usage: generate_instructions_md <bundle_skills_dir> <bundle_agents_dir> <output_file> [tool_name]
generate_instructions_md() {
  local skills_dir="$1"
  local agents_dir="$2"
  local output="$3"
  local tool_name="${4:-AI Assistant}"

  ensure_dir "$(dirname "$output")"

  if [[ "$DRY_RUN" == "true" ]]; then
    log_dim "[dry-run] Would generate instructions at $output"
    return 0
  fi

  {
    cat <<HEADER
# AI Assistant Instructions

> Generated by ai-env-setup. Do not edit manually — re-run the installer to update.

This file configures ${tool_name} with the SDD (Spec-Driven Development) workflow.

## Available Skills

Load these skills on-demand. Skills live in the \`skills/\` directory and follow
the [agentskills.io](https://agentskills.io) standard.

| Skill | Description |
|-------|-------------|
HEADER

    for skill_dir in "$skills_dir"/*/; do
      [[ -f "$skill_dir/SKILL.md" ]] || continue
      local name desc
      name="$(skill_name "$skill_dir/SKILL.md")"
      desc="$(skill_description "$skill_dir/SKILL.md")"
      # Trim description to first sentence / 80 chars
      desc="$(echo "$desc" | head -c 120 | sed 's/\. .*//')"
      printf "| \`%s\` | %s |\n" "$name" "$desc"
    done

    echo ""
    echo "## SDD Workflow"
    echo ""
    echo "Use the \`sdd-orchestrator\` agent to coordinate Spec-Driven Development:"
    echo ""
    echo "| Command | Action |"
    echo "|---------|--------|"
    echo "| \`/sdd-new <name>\` | Start a new change (creates proposal) |"
    echo "| \`/sdd-ff <name>\` | Fast-forward: propose → spec + design → tasks |"
    echo "| \`/sdd-apply <name>\` | Implement tasks in batches |"
    echo "| \`/sdd-verify <name>\` | Verify implementation |"
    echo "| \`/sdd-archive <name>\` | Archive completed change |"
    echo ""
    echo "## Agents"
    echo ""

    for agent_file in "$agents_dir"/*.json; do
      [[ -f "$agent_file" ]] || continue
      python3 - "$agent_file" <<'PYEOF'
import json, sys
with open(sys.argv[1]) as f:
    a = json.load(f)
print(f"### `{a['name']}`\n")
print(f"{a.get('description', '')}\n")
PYEOF
    done

  } > "$output"

  log_ok "Generated instructions: $output"
}

# =============================================================================
# INSTRUCTIONS: .cursorrules specific format
# =============================================================================

# Generate .cursorrules file (same content as generic instructions md).
generate_cursorrules() {
  local skills_dir="$1"
  local agents_dir="$2"
  local output="$3"

  generate_instructions_md "$skills_dir" "$agents_dir" "$output" "Cursor"
}

# =============================================================================
# PROJECT-LEVEL SYMLINK HELPERS
# =============================================================================

# Create a project-level symlink pointing to the bundle skills.
# Usage: link_project_skills <bundle_skills_dir> <project_skills_link_path>
link_project_skills() {
  local bundle_skills="$1"
  local link_path="$2"
  safe_symlink "$link_path" "$bundle_skills"
}

# Create a project-level copy of skills (no symlink, for tools that prefer copies).
# Usage: copy_project_skills <bundle_skills_dir> <project_skills_dir>
copy_project_skills() {
  local bundle_skills="$1"
  local project_skills="$2"

  ensure_dir "$project_skills"
  safe_copy_dir "$bundle_skills" "$project_skills"
  log_ok "Copied skills to $project_skills"
}
