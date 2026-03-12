#!/usr/bin/env bash
# adapters/gemini.sh — Adapter for Gemini CLI
#
# Global:
#   ~/.gemini/skills/<name>/SKILL.md  (Gemini CLI reads skills from ~/.gemini/skills/)
#   ~/.gemini/GEMINI.md               (global instructions — read by Gemini CLI at startup)
#
# Project:
#   .gemini/skills/  → symlink to $BUNDLE_DIR/skills
#   GEMINI.md        → generated instructions at project root

GEMINI_DIR="$HOME/.gemini"

setup_gemini_global() {
  log_section "Gemini CLI — Global"

  ensure_dir "$GEMINI_DIR"

  # 1. Install skills
  log_info "Installing skills to ~/.gemini/skills/..."
  install_skills_as_skillmd "$BUNDLE_DIR/skills" "$GEMINI_DIR/skills"

  # 2. Generate global GEMINI.md
  log_info "Generating ~/.gemini/GEMINI.md..."
  generate_instructions_md \
    "$BUNDLE_DIR/skills" \
    "$BUNDLE_DIR/agents" \
    "$GEMINI_DIR/GEMINI.md" \
    "Gemini CLI"

  log_ok "Gemini CLI global setup complete"
}

setup_gemini_project() {
  local project_dir="${1:-$(pwd)}"
  log_section "Gemini CLI — Project ($(basename "$project_dir"))"

  # 1. Symlink .gemini/skills
  local link_path="$project_dir/.gemini/skills"
  ensure_dir "$project_dir/.gemini"
  safe_symlink "$link_path" "$BUNDLE_DIR/skills"

  # 2. Generate GEMINI.md at project root
  log_info "Generating GEMINI.md..."
  generate_instructions_md \
    "$BUNDLE_DIR/skills" \
    "$BUNDLE_DIR/agents" \
    "$project_dir/GEMINI.md" \
    "Gemini CLI"

  log_ok "Gemini CLI project setup complete"
}

setup_gemini() {
  [[ "$SCOPE_GLOBAL"  == "true" ]] && setup_gemini_global
  [[ "$SCOPE_PROJECT" == "true" ]] && setup_gemini_project
}
