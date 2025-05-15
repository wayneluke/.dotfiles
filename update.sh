#!/bin/zsh

# Paths
SOURCE_DIR="$PWD"
DEST_HOME="$HOME"

# Colors and tags
INFO="%F{cyan}[INFO]%f"
SUCCESS="%F{green}[DONE]%f"
ERROR="%F{red}[ERR ]%f"

# Logging helpers
log_info() { echo "$INFO $1"; }
log_success() { echo "$SUCCESS $1"; }
log_error() { echo "$ERROR $1" >&2; }

# Run and check a command
run_and_check() {
  local description=$1
  shift
  "$@"
  if [[ $? -eq 0 ]]; then
    log_success "$description succeeded"
  else
    log_error "$description failed"
  fi
}

# Sync a file if it’s new or modified
sync_file() {
  local src=$1
  local dest=$2
  if [[ -f $src ]]; then
    log_info "Syncing file: $src → $dest"
    run_and_check "Syncing $src" rsync -au "$src" "$dest"
  fi
}

# Sync a directory tree
sync_dir() {
  local src=$1
  local dest=$2
  if [[ -d $src ]]; then
    log_info "Syncing directory: $src → $dest"
    run_and_check "Syncing $src" rsync -au "$src/" "$dest/"
  fi
}

# Main
log_info "Starting sync..."
sync_file "$SOURCE_DIR/.zshenv" "$DEST_HOME/.zshenv"
sync_dir "$SOURCE_DIR/config" "$DEST_HOME/.config"
sync_dir "$SOURCE_DIR/local" "$DEST_HOME/.local"
log_info "Sync complete."