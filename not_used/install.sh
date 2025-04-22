#!/bin/zsh

set -euo pipefail
TRAPERR() print -u2 Exit status: $?

# Defaults
DRY_RUN=false
NO_SCRIPT=false
VERBOSE=false
LOG_FILE=""

SELECTED_SCRIPTS=()

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --no-script)
      NO_SCRIPT=true
      shift
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    --script)
      if [[ -n "${2:-}" ]]; then
        SELECTED_SCRIPTS+=("$2")
        shift 2
      else
        echo "Error: --script requires a filename"
        exit 1
      fi
      ;;
    --log)
      if [[ -n "${2:-}" ]]; then
        LOG_FILE="$2"
        shift 2
      else
        echo "Error: --log requires a filename"
        exit 1
      fi
      ;;
    *)
      echo "Unknown argument: $1"
      cat readme.md
      exit 1
      ;;
  esac
done

# Setup paths
REPO_DIR="${0:A:h}"
SCRIPTS_DIR="$REPO_DIR/install"
CONFIG_SRC="$REPO_DIR/config"
LOCAL_SRC="$REPO_DIR/local"
CONFIG_DEST="$HOME/.config"
LOCAL_DEST="$HOME/.local"


doit() {
  local cmd="$*"
  local prefix=">>>"

  if $DRY_RUN; then
    echo "$prefix [DRY RUN] $cmd"
    [[ -n "$LOG_FILE" ]] && echo "$prefix [DRY RUN] $cmd" >> "$LOG_FILE"
  else
    ## echo "$prefix $cmd"
    if [[ -n "$LOG_FILE" ]]; then
      eval "$cmd" 2>&1 | tee -a "$LOG_FILE"
    else
      eval "$cmd"
    fi
  fi
}

# Prepare log file if requested
if [[ -n "$LOG_FILE" ]]; then
  : > "$LOG_FILE"  # Clear log file
fi


doit "echo \"Starting install script\""
doit "echo \"Dry-run mode: $DRY_RUN\""
doit "echo \"Script execution: $([[ $NO_SCRIPT == true ]] && echo 'disabled' || echo 'enabled')\""
[[ ${#SELECTED_SCRIPTS[@]} -gt 0 ]] && doit "echo \"Selected scripts: ${(j:, :)SELECTED_SCRIPTS}"
[[ -n "$LOG_FILE" ]] && doit "echo \"logging to: $LOG_FILE\""
[[ $VERBOSE == true ]] && doit "echo \"Verbose mode enabled for copying\""

# Copy .config with optional verbosity
if [[ -d "$CONFIG_SRC" ]]; then
  doit "echo \"Copying configuration from $CONFIG_SRC to $CONFIG_DEST\""
  doit "mkdir -p \"$CONFIG_DEST\""
  if $VERBOSE; then
    doit "cp -vr \"$CONFIG_SRC\"/* \"$CONFIG_DEST\"/"
  else
    doit "cp -r \"$CONFIG_SRC\"/* \"$CONFIG_DEST\"/"
  fi
else
  doit "echo \"No .config directory found at $CONFIG_SRC\""
fi


# Run scripts unless disabled
if ! $NO_SCRIPT; then
  if [[ -d "$SCRIPTS_DIR" ]]; then
    doit "echo \"Ensuring scripts in $SCRIPTS_DIR are executable\""
    doit "chmod +x $SCRIPTS_DIR"
    
    doit "echo \"Processing scripts in $SCRIPTS_DIR...\""
    for script_path in "$SCRIPTS_DIR"/*(.x); do
      script_name="${script_path:t}"
      if [[ ${#SELECTED_SCRIPTS[@]} -eq 0 || "${SELECTED_SCRIPTS[@]}"[(Ie)$script_name] -ne 0 ]]; then
        doit "echo \"Executing $script_name\""
        doit "\"$script_path\""
      else
        doit "echo \"Skipping $script_name (not selected)\""
      fi
    done
  else
    doit "echo \"No installation scripts directory found at $SCRIPTS_DIR\""
  fi
else
  doit "echo \"--no-script specified, skipping script execution\""
fi

doit "echo \"Installation complete.\""