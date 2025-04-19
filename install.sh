#!/bin/bash

set -euo pipefail

# Default values
DRY_RUN=false

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=true
      ;;
    --help)
      echo "Installation Script"
      echo "Options:"
      echo "  --dry-run : test the script"
      echo "  --help :  this output"
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg"
      exit 1
      ;;
  esac
done

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$REPO_DIR/.config"
CONFIG_DEST="$HOME/.config"
SCRIPTS_DIR="$REPO_DIR/scripts"

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

# Run setup scripts
if [[ -d "$SCRIPTS_DIR" ]]; then
  log "Running setup scripts in $SCRIPTS_DIR..."
  for script in "$SCRIPTS_DIR"/*; do
    if [[ -x "$script" && -f "$script" ]]; then
      log "Executing $script"
      run_or_echo "\"$script\""
    else
      log "Skipping non-executable or non-regular file: $script"
    fi
  done
else
  log "No scripts directory found at $SCRIPTS_DIR"
fi

# Copy .config files
if [[ -d "$CONFIG_SRC" ]]; then
  log "Copying configuration from $CONFIG_SRC to $CONFIG_DEST"
  run_or_echo "mkdir -p \"$CONFIG_DEST\""
  run_or_echo "cp -r \"$CONFIG_SRC\"/* \"$CONFIG_DEST\"/"
else
  log "No .config directory found at $CONFIG_SRC"
fi

log "Installation complete."