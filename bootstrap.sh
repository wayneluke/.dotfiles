#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh — macOS dev environment bootstrap
# Installs: Xcode CLI Tools, Homebrew, and a curated set of tools
#
# Usage:
#   ./bootstrap.sh           # normal run
#   ./bootstrap.sh --dry-run # preview actions without making changes
# =============================================================================

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Log file ─────────────────────────────────────────────────────────────────
LOG_DIR="$HOME/.logs"
LOG_FILE="$LOG_DIR/bootstrap_$(date +%Y%m%d_%H%M%S).log"

# ── Dry-run flag ──────────────────────────────────────────────────────────────
DRY_RUN=false
for arg in "$@"; do
  [[ "$arg" == "--dry-run" || "$arg" == "-n" ]] && DRY_RUN=true
done

# ── Brew tools to install ─────────────────────────────────────────────────────
BREW_TOOLS=(
  bat
  bitwarden
  eza
  ghostty
  git
  httpie
  fd
  fzf
  jq
  mole
  ripgrep    # installed as 'rg'
  rsync
  starship
  tldr
  vivaldi
  zed
  zoxide
)

# =============================================================================
# Helpers
# =============================================================================

_log() {
  local level="$1"; shift
  local msg="$*"
  local ts; ts="$(date '+%Y-%m-%d %H:%M:%S')"
  local line="[$ts] [$level] $msg"

  # Always write plain text to the log file
  echo "$line" >> "$LOG_FILE" 2>/dev/null || true

  # Colour output to the terminal
  case "$level" in
    INFO)  echo -e "${CYAN}${line}${RESET}" ;;
    OK)    echo -e "${GREEN}${line}${RESET}" ;;
    WARN)  echo -e "${YELLOW}${line}${RESET}" ;;
    ERROR) echo -e "${RED}${line}${RESET}" ;;
    DRY)   echo -e "${BOLD}${YELLOW}[DRY-RUN] $msg${RESET}" ;;
    *)     echo "$line" ;;
  esac
}

log_info()  { _log INFO  "$@"; }
log_ok()    { _log OK    "$@"; }
log_warn()  { _log WARN  "$@"; }
log_error() { _log ERROR "$@"; }
log_dry()   { _log DRY   "$@"; }

# Run a command, logging stdout/stderr; honour dry-run mode.
run() {
  local desc="$1"; shift
  if $DRY_RUN; then
    log_dry "Would run: $*"
    return 0
  fi
  log_info "$desc"
  if ! output=$("$@" 2>&1); then
    log_error "$desc — FAILED"
    log_error "  Output: $output"
    echo "$output" >> "$LOG_FILE"
    return 1
  fi
  echo "$output" >> "$LOG_FILE"
  log_ok "$desc — done"
}

# =============================================================================
# Pre-flight
# =============================================================================

preflight() {
  # Ensure log directory exists
  if ! $DRY_RUN; then
    mkdir -p "$LOG_DIR"
    touch "$LOG_FILE"
  fi

  log_info "========================================================"
  log_info "  macOS dev bootstrap — $(date)"
  $DRY_RUN && log_warn "  DRY-RUN mode active — no changes will be made"
  log_info "========================================================"

  # Must be macOS
  if [[ "$(uname -s)" != "Darwin" ]]; then
    log_error "This script is macOS-only. Exiting."
    exit 1
  fi

  log_info "macOS version: $(sw_vers -productVersion)"
  log_info "Architecture:  $(uname -m)"
}

# =============================================================================
# Xcode Command Line Tools
# =============================================================================

install_xcode_clt() {
  if xcode-select -p &>/dev/null; then
    log_ok "Xcode Command Line Tools already installed ($(xcode-select -p))"
    return 0
  fi

  if $DRY_RUN; then
    log_dry "Would install Xcode Command Line Tools via 'xcode-select --install'"
    return 0
  fi

  log_info "Installing Xcode Command Line Tools…"
  # Trigger the GUI installer and wait for it to finish
  xcode-select --install 2>&1 | tee -a "$LOG_FILE" || true

  log_info "Waiting for Xcode CLT installation to complete…"
  until xcode-select -p &>/dev/null; do
    sleep 5
  done

  log_ok "Xcode Command Line Tools installed ($(xcode-select -p))"
}

# =============================================================================
# Homebrew
# =============================================================================

install_homebrew() {
  if command -v brew &>/dev/null; then
    log_ok "Homebrew already installed ($(brew --version | head -1))"
    export_brew
    return 0
  fi

  if $DRY_RUN; then
    log_dry "Would install Homebrew via the official install script"
    log_dry "Would export Homebrew to PATH"
    return 0
  fi

  log_info "Installing Homebrew…"
  if ! NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
      2>&1 | tee -a "$LOG_FILE"; then
    log_error "Homebrew installation failed."
    exit 1
  fi

  export_brew
  log_ok "Homebrew installed ($(brew --version | head -1))"
}

# Export Homebrew's bin/sbin to PATH for the current shell session
export_brew() {
  local brew_prefix
  # Apple Silicon
  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    brew_prefix="/opt/homebrew"
  # Intel
  elif [[ -x "/usr/local/bin/brew" ]]; then
    brew_prefix="/usr/local"
  else
    log_warn "Could not locate Homebrew prefix; PATH not updated."
    return 0
  fi

  if $DRY_RUN; then
    log_dry "Would export PATH: $brew_prefix/bin:$brew_prefix/sbin:\$PATH"
    return 0
  fi

  export PATH="$brew_prefix/bin:$brew_prefix/sbin:${PATH:-}"
  eval "$("$brew_prefix/bin/brew" shellenv)"
  log_info "Homebrew exported to PATH (prefix: $brew_prefix)"
}

update_homebrew() {
  run "Updating Homebrew" brew update
}

# =============================================================================
# Tool installation
# =============================================================================

install_tools() {
  log_info "Installing ${#BREW_TOOLS[@]} tools via Homebrew…"

  for tool in "${BREW_TOOLS[@]}"; do
    # Check if already installed (formula name)
    if ! $DRY_RUN && brew list --formula "$tool" &>/dev/null 2>&1; then
      log_ok "  $tool — already installed"
      continue
    fi

    if $DRY_RUN; then
      log_dry "Would run: brew install $tool"
    else
      log_info "  Installing $tool…"
      if ! brew install "$tool" >> "$LOG_FILE" 2>&1; then
        log_error "  $tool — installation FAILED (see $LOG_FILE for details)"
      else
        log_ok "  $tool — installed"
      fi
    fi
  done
}

# =============================================================================
# Post-install summary
# =============================================================================

summary() {
  log_info "========================================================"
  log_info "  Installation summary"
  log_info "========================================================"

  if $DRY_RUN; then
    log_dry "Dry-run complete — nothing was changed."
    return 0
  fi

  # Verify each tool
  local binary_map=(
    "bat:bat"
    "eza:eza"
    "ghostty:ghostty"
    "git:git"
    "httpie:http"
    "fd:fd"
    "fzf:fzf"
    "jq:jq"
    "mole:mole"
    "ripgrep:rg"
    "rsync:rsync"
    "starship:starship"
    "tldr:tldr"
    "zed:zed"
    "zoxide:zoxide"
  )

  local ok=0 fail=0
  for entry in "${binary_map[@]}"; do
    local formula="${entry%%:*}"
    local binary="${entry##*:}"
    if command -v "$binary" &>/dev/null; then
      log_ok "  ✔  $formula ($binary)"
      (( ok++ )) || true
    else
      log_warn "  ✘  $formula ($binary) — not found in PATH"
      (( fail++ )) || true
    fi
  done

  log_info "  Result: $ok succeeded, $fail not found"
  log_info "  Full log: $LOG_FILE"
  log_info "========================================================"

  # Remind the user to persist brew in their shell profile
  log_info ""
  log_warn "REMINDER: To make Homebrew permanent, add the following to"
  log_warn "~/.zprofile (or ~/.bash_profile / ~/.bashrc):"
  log_warn ""
  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    log_warn '  eval "$(/opt/homebrew/bin/brew shellenv)"'
  else
    log_warn '  eval "$(/usr/local/bin/brew shellenv)"'
  fi
}

# =============================================================================
# Main
# =============================================================================

main() {
  preflight
  install_xcode_clt
  install_homebrew
  update_homebrew
  install_tools
  summary
}

main
