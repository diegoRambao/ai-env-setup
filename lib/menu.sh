#!/usr/bin/env bash
# lib/menu.sh — Interactive checkbox menus for tool and scope selection.
# Sourced by install.sh. Do NOT execute directly.
#
# Exports after show_scope_menu():
#   SCOPE_GLOBAL  (true|false)
#   SCOPE_PROJECT (true|false)
#
# Exports after show_tools_menu():
#   SETUP_OPENCODE    (true|false)
#   SETUP_CLAUDE      (true|false)
#   SETUP_KIRO        (true|false)
#   SETUP_COPILOT     (true|false)
#   SETUP_ANTIGRAVITY (true|false)
#   SETUP_CURSOR      (true|false)
#   SETUP_GEMINI      (true|false)

# =============================================================================
# INTERNAL HELPERS
# =============================================================================

# _draw_menu <title> <subtitle> <labels_array_nameref> <selected_array_nameref> [<detected_array_nameref>]
# Draws a checkbox list. Uses terminal escape codes to redraw in-place.
# Returns when the user presses Enter (empty input).
_draw_checkbox_list() {
  local -n _labels="$1"
  local -n _selected="$2"
  local -n _detected="$3"
  local count=${#_labels[@]}

  for i in "${!_labels[@]}"; do
    local mark det_marker=""
    if [[ "${_selected[$i]}" == "true" ]]; then
      mark="${GREEN}[x]${NC}"
    else
      mark="[ ]"
    fi
    if [[ "${_detected[$i]}" == "true" ]]; then
      det_marker=" ${DIM}(detected)${NC}"
    fi
    printf "  %s ${BOLD}%d.${NC} %s%s\n" "$mark" "$((i + 1))" "${_labels[$i]}" "$det_marker"
  done
  echo ""
  echo -e "  ${DIM}a${NC} = all   ${DIM}n${NC} = none   ${DIM}1-${count}${NC} = toggle"
}

# _erase_lines <count>
_erase_lines() {
  local n="$1"
  for (( i=0; i<n; i++ )); do
    printf "\033[A\033[2K"
  done
}

# Generic multi-select menu.
# Usage: _multi_select <title> <prompt> <labels_nameref> <selected_nameref> <detected_nameref>
_multi_select() {
  local title="$1"
  local prompt="$2"
  local labels_ref="$3"
  local selected_ref="$4"
  local detected_ref="$5"

  local -n _ms_labels="$labels_ref"
  local -n _ms_selected="$selected_ref"
  local -n _ms_detected="$detected_ref"

  local count=${#_ms_labels[@]}
  # lines: count items + 1 empty + 1 hint line
  local menu_height=$(( count + 2 ))

  echo -e "${BOLD}${title}${NC}"
  echo -e "${DIM}${prompt}${NC}"
  echo ""

  _draw_checkbox_list "$labels_ref" "$selected_ref" "$detected_ref"

  while true; do
    printf "  Toggle: "
    local choice
    read -r choice

    # Erase the prompt line + menu lines
    _erase_lines $(( menu_height + 1 ))

    case "$choice" in
      a|A)
        for i in "${!_ms_selected[@]}"; do _ms_selected[$i]=true; done
        ;;
      n|N)
        for i in "${!_ms_selected[@]}"; do _ms_selected[$i]=false; done
        ;;
      "")
        break
        ;;
      *)
        # Support space-separated numbers: "1 3 5"
        for num in $choice; do
          if [[ "$num" =~ ^[0-9]+$ ]] && (( num >= 1 && num <= count )); then
            local idx=$(( num - 1 ))
            if [[ "${_ms_selected[$idx]}" == "true" ]]; then
              _ms_selected[$idx]=false
            else
              _ms_selected[$idx]=true
            fi
          fi
        done
        ;;
    esac

    _draw_checkbox_list "$labels_ref" "$selected_ref" "$detected_ref"
  done
}

# =============================================================================
# SCOPE MENU
# =============================================================================

show_scope_menu() {
  local labels=("Global (applies to all projects)" "Project (current directory only)")
  local detected=(false false)
  # Default: both selected
  local selected=(true true)

  echo ""
  _multi_select \
    "Where do you want to install?" \
    "Global = tool config dirs (~/.config/opencode, ~/.claude, ~/.kiro, etc.)" \
    labels selected detected

  SCOPE_GLOBAL="${selected[0]}"
  SCOPE_PROJECT="${selected[1]}"
}

# =============================================================================
# TOOLS MENU
# =============================================================================

show_tools_menu() {
  # Run detection first if not done yet
  if [[ -z "$OPENCODE_INSTALLED" ]]; then
    detect_tools
  fi

  local labels=(
    "OpenCode           (~/.config/opencode/)"
    "Claude Code        (~/.claude/)"
    "Kiro (AWS)         (~/.kiro/)"
    "GitHub Copilot     (VS Code + ~/.config/github-copilot/)"
    "Antigravity        (~/.antigravity/ + ~/.agents/)"
    "Cursor             (~/.cursor/)"
    "Gemini CLI         (~/.gemini/)"
  )

  local detected=(
    "$OPENCODE_INSTALLED"
    "$CLAUDE_INSTALLED"
    "$KIRO_INSTALLED"
    "$COPILOT_INSTALLED"
    "$ANTIGRAVITY_INSTALLED"
    "$CURSOR_INSTALLED"
    "$GEMINI_INSTALLED"
  )

  # Pre-select detected tools
  local selected=(
    "$OPENCODE_INSTALLED"
    "$CLAUDE_INSTALLED"
    "$KIRO_INSTALLED"
    "$COPILOT_INSTALLED"
    "$ANTIGRAVITY_INSTALLED"
    "$CURSOR_INSTALLED"
    "$GEMINI_INSTALLED"
  )

  # Ensure at least OpenCode is selected if nothing detected
  local any=false
  for s in "${selected[@]}"; do [[ "$s" == "true" ]] && { any=true; break; }; done
  if [[ "$any" == "false" ]]; then
    selected[0]=true  # Default to OpenCode
  fi

  echo ""
  _multi_select \
    "Which AI tools do you want to configure?" \
    "Detected tools are pre-selected. Toggle to customize." \
    labels selected detected

  SETUP_OPENCODE="${selected[0]}"
  SETUP_CLAUDE="${selected[1]}"
  SETUP_KIRO="${selected[2]}"
  SETUP_COPILOT="${selected[3]}"
  SETUP_ANTIGRAVITY="${selected[4]}"
  SETUP_CURSOR="${selected[5]}"
  SETUP_GEMINI="${selected[6]}"
}

# =============================================================================
# CONFIRMATION SUMMARY
# =============================================================================

print_plan() {
  echo ""
  log_section "Installation plan:"
  echo ""

  # Scope
  local scope_parts=()
  [[ "$SCOPE_GLOBAL" == "true" ]]  && scope_parts+=("global")
  [[ "$SCOPE_PROJECT" == "true" ]] && scope_parts+=("project ($(basename "$(pwd)"))")
  echo -e "  ${BOLD}Scope:${NC} $(IFS=', '; echo "${scope_parts[*]}")"
  echo ""

  # Tools
  echo -e "  ${BOLD}Tools:${NC}"
  [[ "$SETUP_OPENCODE"    == "true" ]] && echo -e "    ${GREEN}✓${NC} OpenCode"
  [[ "$SETUP_CLAUDE"      == "true" ]] && echo -e "    ${GREEN}✓${NC} Claude Code"
  [[ "$SETUP_KIRO"        == "true" ]] && echo -e "    ${GREEN}✓${NC} Kiro (AWS)"
  [[ "$SETUP_COPILOT"     == "true" ]] && echo -e "    ${GREEN}✓${NC} GitHub Copilot"
  [[ "$SETUP_ANTIGRAVITY" == "true" ]] && echo -e "    ${GREEN}✓${NC} Antigravity"
  [[ "$SETUP_CURSOR"      == "true" ]] && echo -e "    ${GREEN}✓${NC} Cursor"
  [[ "$SETUP_GEMINI"      == "true" ]] && echo -e "    ${GREEN}✓${NC} Gemini CLI"

  # Bundle contents
  echo ""
  echo -e "  ${BOLD}Bundle contents:${NC}"
  if [[ -n "$BUNDLE_DIR" && -d "$BUNDLE_DIR/skills" ]]; then
    local skill_count
    skill_count=$(find "$BUNDLE_DIR/skills" -name "SKILL.md" | wc -l | tr -d ' ')
    echo -e "    ${DIM}${skill_count} SDD skills (sdd-init, sdd-propose, ..., sdd-archive)${NC}"
  fi
  if [[ -n "$BUNDLE_DIR" && -d "$BUNDLE_DIR/agents" ]]; then
    local agent_count
    agent_count=$(find "$BUNDLE_DIR/agents" -name "*.json" | wc -l | tr -d ' ')
    echo -e "    ${DIM}${agent_count} agents (tech-lead, sdd-orchestrator)${NC}"
  fi
  echo ""
}

confirm_plan() {
  print_plan
  printf "  Proceed? [Y/n]: "
  local answer
  read -r answer
  case "$answer" in
    n|N) return 1 ;;
    *)   return 0 ;;
  esac
}
