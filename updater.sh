#!/bin/zsh

set -euo pipefail

copy_new_files() {
  local src_dir="$1"
  local dest_dir="$2"

  echo "Copying from $src_dir to $dest_dir..."

  # Use rsync with flags:
  # -a : archive (recursive, preserve attributes)
  # -u : skip files that are newer on the receiver (here: skip if dest exists)
  # --ignore-existing : skip files that already exist
  rsync -auv --ignore-existing "$src_dir/" "$dest_dir/"
}

main() {
  local config_src="./config"
  local local_src="./local"
  local config_dest="$HOME/.config"
  local local_dest="$HOME/.local"

  mkdir -p "$config_dest" "$local_dest"

  copy_new_files "$config_src" "$config_dest"
  copy_new_files "$local_src" "$local_dest"
}

main "$@"