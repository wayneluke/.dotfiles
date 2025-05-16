link_config_dirs() {
  local src_dir="$HOME/dotfiles/config"
  local dest_dir="$HOME/.config"

  mkdir -p "$dest_dir"

  find "$src_dir" -type d | while read -r src; do
    local rel_path="${src#$src_dir/}"
    local dest="$dest_dir/$rel_path"

    if [[ -e "$dest" || -L "$dest" ]]; then
      rm -rf "$dest"
      print "Removed existing $dest"
    fi

    ln -s "$src" "$dest"
    print "Linked $src -> $dest"
  done
}

link_executables_to_local_bin() {
  local src_dir="${1:-.}"  # Default to current dir if not passed
  local target_dir="$HOME/.local/bin"
  local dry_run=false
  local create_aliases=false

  # Parse options
  zparseopts -D -E -dry=dry_run -alias=create_aliases

  mkdir -p "$target_dir"

  # Find executable files (excluding directories)
  find "$src_dir" -type f -perm -u+x | while read -r exe; do
    local name=$(basename "$exe")
    local target="$target_dir/$name"

    if [[ -e "$target" ]]; then
      echo "⚠️  Skipping '$name': already exists in $target_dir"
    else
      echo "🔗 Linking $exe → $target"
      $dry_run || ln -s "$exe" "$target"
    fi

    if $create_aliases; then
      echo "alias $name='$target'" >> "$HOME/.zsh_executable_aliases"
    fi
  done

  if $create_aliases; then
    echo "✅ Aliases written to ~/.zsh_executable_aliases"
    echo "⚠️  Be sure to 'source ~/.zsh_executable_aliases' in your .zshrc"
  fi
}