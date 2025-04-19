if command -v eza >/dev/null 2>&1; then
  alias ls='eza --git --icons --group-directories-first'
  alias ll='eza -lbhGF --git --icons --group-directories-first'
  alias la='eza -lbhaGF --icons --git --group-directories-first'
  alias ld='eza --only-dirs' # List only directories
  alias lf='eza --only-files' # List only files
  
  function tree() {
    local depth=${1:-2}  # Default depth to 2 if none specified
    shift
    eza --tree --level="$depth" "$@"
  }
fi