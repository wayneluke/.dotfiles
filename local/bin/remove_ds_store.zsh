#!/usr/bin/env zsh
# remove_ds_store.zsh
# Deletes all .DS_Store files in the given directory tree.
# Usage: remove_ds_store.zsh [directory]
# If no directory is given, uses the current directory.

target="${1:-.}"

if [[ ! -d "$target" ]]; then
  echo "Error: '$target' is not a directory." >&2
  exit 1
fi

# Resolve to absolute path for clarity in output
target="$(cd "$target" && pwd)"

echo "Searching for .DS_Store files under: $target"

count=0
while IFS= read -r -d '' file; do
  echo "Removing: $file"
  rm -- "$file"
  (( count++ ))
done < <(find "$target" -name ".DS_Store" -print0)

if (( count == 0 )); then
  echo "No .DS_Store files found."
else
  echo "Done. Removed $count .DS_Store file(s)."
fi
