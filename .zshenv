# Init Homebrew, Will fix the path later.
eval "$(/opt/homebrew/bin/brew shellenv)"

# Set Directory Variables.
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.local/cache"

# set the amazing ZDOTDIR variable
export ZDOTDIR=$HOME/.config/zsh