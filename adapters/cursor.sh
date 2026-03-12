#!/usr/bin/env bash
# adapters/cursor.sh — Adapter for Cursor
#
# Global:
#   ~/.cursor/rules/     → skills installed as rule files (Cursor reads .cursor/rules/*.md)
#
# Project:
#   .cursor/rules/       → symlink to $BUNDLE_DIR/skills
#   .cursorrules         → generated instructions file (legacy format, still read by Cursor)

CURSOR_DIR="$HOME/.cursor"

setup_cursor_global() {
  log_section "Cursor — Global"

  ensure_dir "$CURSOR_DIR/rules"

  # Cursor reads ~/.cursor/rules/*.md as global rules.
  # We generate a single consolidated rules file from all skills.
  log_info "Generating global Cursor rules..."
  _install_cursor_rules "$CURSOR_DIR/rules"

  log_ok "Cursor global setup complete"
  log_warn "Note: Restart Cursor to load the new rules."
}

setup_cursor_project() {
  local project_dir="${1:-$(pwd)}"
  log_section "Cursor — Project ($(basename "$project_dir"))"

  # 1. Symlink .cursor/rules → bundle skills
  local link_path="$project_dir/.cursor/rules"
  ensure_dir "$project_dir/.cursor"
  safe_symlink "$link_path" "$BUNDLE_DIR/skills"

  # 2. Generate .cursorrules (legacy format — still read by older Cursor versions)
  log_info "Generating .cursorrules..."
  generate_cursorrules \
    "$BUNDLE_DIR/skills" \
    "$BUNDLE_DIR/agents" \
    "$project_dir/.cursorrules"

  log_ok "Cursor project setup complete"
}

# Install each skill as a separate .md rule file in Cursor's rules dir.
# Cursor picks up *.md files in .cursor/rules/ as individual rules.
_install_cursor_rules() {
  local rules_dir="$1"
  ensure_dir "$rules_dir"

  for skill_dir in "$BUNDLE_DIR/skills"/*/; do
    [[ -f "$skill_dir/SKILL.md" ]] || continue
    local skill_name
    skill_name="$(basename "$skill_dir")"
    local rule_file="$rules_dir/${skill_name}.md"

    if [[ -f "$rule_file" ]]; then
      backup_if_exists "$rule_file"
    fi

    safe_copy "$skill_dir/SKILL.md" "$rule_file"
    log_ok "Installed Cursor rule: $skill_name"
  done
}

setup_cursor() {
  [[ "$SCOPE_GLOBAL"  == "true" ]] && setup_cursor_global
  [[ "$SCOPE_PROJECT" == "true" ]] && setup_cursor_project
}
