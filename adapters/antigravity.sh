#!/usr/bin/env bash
# adapters/antigravity.sh — Adapter for Antigravity (VS Code fork)
#
# Antigravity is a VS Code fork and shares the cross-agent skills ecosystem.
# Global config mirrors the Copilot global setup (both use ~/.agents/skills).
#
# Global:
#   ~/.agents/skills/<name>/SKILL.md  (cross-agent ecosystem — shared with Copilot)
#
# Project:
#   .github/skills/                  → symlink (same as Copilot)
#   .github/copilot-instructions.md    (Antigravity reads this as a VS Code fork)

ANTIGRAVITY_DIR="$HOME/.antigravity"

setup_antigravity_global() {
  log_section "Antigravity — Global"

  # Antigravity uses the shared ~/.agents/ ecosystem (same as Copilot)
  log_info "Installing skills to ~/.agents/skills/ (shared cross-agent ecosystem)..."
  install_skills_as_skillmd "$BUNDLE_DIR/skills" "$HOME/.agents/skills"

  # Enable MCP gallery in Antigravity settings if settings.json exists
  local settings_file="$HOME/Library/Application Support/Antigravity/User/settings.json"
  if [[ -f "$settings_file" ]]; then
    _ensure_mcp_gallery_enabled "$settings_file"
  fi

  log_ok "Antigravity global setup complete"
  log_warn "Note: Restart Antigravity to load the new skills."
}

setup_antigravity_project() {
  local project_dir="${1:-$(pwd)}"
  log_section "Antigravity — Project ($(basename "$project_dir"))"

  # Antigravity reads .github/copilot-instructions.md (VS Code fork)
  local link_path="$project_dir/.github/skills"
  ensure_dir "$project_dir/.github"
  safe_symlink "$link_path" "$BUNDLE_DIR/skills"

  log_info "Generating .github/copilot-instructions.md..."
  generate_instructions_md \
    "$BUNDLE_DIR/skills" \
    "$BUNDLE_DIR/agents" \
    "$project_dir/.github/copilot-instructions.md" \
    "Antigravity"

  log_ok "Antigravity project setup complete"
}

_ensure_mcp_gallery_enabled() {
  local settings_file="$1"
  require_python3 || return 1

  if [[ "$DRY_RUN" == "true" ]]; then
    log_dim "[dry-run] Would enable chat.mcp.gallery in $settings_file"
    return 0
  fi

  # Settings is a JSONC file — use python3 with comment-stripping
  python3 - "$settings_file" <<'PYEOF'
import json, re, sys

path = sys.argv[1]

with open(path) as f:
    raw = f.read()

# Strip single-line // comments (naive but works for settings.json)
clean = re.sub(r'(?<!:)//.*', '', raw)
# Strip trailing commas before } or ]
clean = re.sub(r',(\s*[}\]])', r'\1', clean)

try:
    data = json.loads(clean)
except json.JSONDecodeError:
    print("WARN: Could not parse settings.json — skipping MCP gallery update")
    sys.exit(0)

changed = False
if not data.get("chat.mcp.gallery.enabled"):
    data["chat.mcp.gallery.enabled"] = True
    changed = True

if changed:
    with open(path, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print("enabled")
PYEOF

  local result
  result=$(python3 - "$settings_file" 2>&1)
  if [[ "$result" == "enabled" ]]; then
    log_ok "Enabled chat.mcp.gallery in Antigravity settings"
  fi
}

setup_antigravity() {
  [[ "$SCOPE_GLOBAL"  == "true" ]] && setup_antigravity_global
  [[ "$SCOPE_PROJECT" == "true" ]] && setup_antigravity_project
}
