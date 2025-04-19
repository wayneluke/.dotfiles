#!/bin/bash

set -euo pipefail

# Defaults
DRY_RUN=false
SELECTED_SCRIPTS=()

## Print Header
echo "Luna Installation Script"
echo "------------------------"
echo " "


# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --script)
      if [[ -n "${2-}" ]]; then
        SELECTED_SCRIPTS+=("$2")
        shift 2
      else
        echo "Error: --script requires an argument"
        exit 1
      fi
      ;;
    *)
      echo "Valid options are:"
      echo "  --dry-run: Allows a test run of the script."
      echo "    example: ./install.sh --dry-run"
      echo "  --script: Run one or more scripts fron the install directory."
      echo "    example: ./install.sh --script setup.sh --script install_fonts.sh"
      exit 1
      ;;
  esac
done

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$REPO_DIR/config"
CONFIG_DEST="$HOME/.config"
LOCAL_SRC="$REPO_DIR/local"
LOCAL_DEST="$HOME/.local"
SCRIPTS_DIR="$REPO_DIR/install"

log() {
  echo ">>> $*"
}

run_or_echo() {
  if $DRY_RUN; then
    echo "[DRY RUN] $*"
  else
    eval "$@"
  fi
}

log "Starting install script"
log "Dry-run mode: $DRY_RUN"
if [[ ${#SELECTED_SCRIPTS[@]} -gt 0 ]]; then
  log "Only running selected scripts: ${SELECTED_SCRIPTS[*]}"
fi

# Run scripts
if [[ -d "$SCRIPTS_DIR" ]]; then
  log "Processing scripts in $SCRIPTS_DIR..."
  for script_path in "$SCRIPTS_DIR"/*; do
    script_name="$(basename "$script_path")"
    if [[ -x "$script_path" && -f "$script_path" ]]; then
      if [[ ${#SELECTED_SCRIPTS[@]} -eq 0 || " ${SELECTED_SCRIPTS[*]} " =~ " ${script_name} " ]]; then
        log "Executing $script_name"
        run_or_echo "\"$script_path\""
      else
        log "Skipping $script_name (not selected)"
      fi
    else
      log "Skipping $script_name (not executable or not a file)"
    fi
  done
else
  log "No scripts directory found at $SCRIPTS_DIR"
fi

# Copy .config files
if [[ -d "$CONFIG_SRC" ]]; then
  log "Copying configuration from $CONFIG_SRC to $CONFIG_DEST"
  run_or_echo "mkdir -p \"$CONFIG_DEST\""
  run_or_echo "cp -RPv \"$CONFIG_SRC\"/* \"$CONFIG_DEST\"/ > config.log"
else
  log "No .config directory found at $CONFIG_SRC"
fi

# Copy .local files
if [[ -d "$local_SRC" ]]; then
  log "Copying configuration from $LOCAL_SRC to $LOCAL_DEST"
  run_or_echo "mkdir -p \"$LOCAL_DEST\""
  run_or_echo "cp -RPv \"$LOCAL_SRC\"/* \"$LOCAL_DEST\"/ > local.log"
else
  log "No .local directory found at $LOCAL_SRC"
fi

log "Installation complete."