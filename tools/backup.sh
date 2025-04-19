#!/bin/zsh

# Enable associative arrays in Zsh
typeset -A SYNC_DIRS

# Define source → destination mapping
SYNC_DIRS=(
    "$HOME/.config"  "$HOME/files/dotfiles/config"
    "$HOME/.local"   "$HOME/files/dotfiles/local"
)

# Rsync options:
RSYNC_OPTS=(
    -avh           # Archive mode, verbose, human-readable
    --progress     # Show progress
    --delete       # Delete extraneous files from destination
    --exclude "*.cache"  # Exclude cache files
    --exclude ".git"     # Exclude git directories
    --exclude ".DS_Store"  # Exclude macOS system files
    --exclude "Cache/"
)

# Loop through the associative array and sync each directory
for SRC DEST in "${(@kv)SYNC_DIRS}"; do
    echo "🔄 Syncing: $SRC → $DEST"

    # Ensure destination exists
    mkdir -p "$DEST"

    # Perform sync
    rsync "${RSYNC_OPTS[@]}" "$SRC/" "$DEST"

    echo "✅ Done syncing: $SRC → $DEST"
    echo "-----------------------------"
done

echo "🎉 All syncs completed!"