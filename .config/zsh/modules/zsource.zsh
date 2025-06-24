function zsource() {
  local file=$1
  local zwc="${file}.zwc"

  if [[ -f "$file" && (! -f "$zwc" || "$file" -nt "$zwc") ]]; then
    zcompile "$file"
  fi
  source "$file"
}