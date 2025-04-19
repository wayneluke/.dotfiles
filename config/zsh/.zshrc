# Trigger Debug with `time ZSH_DEBUGRC=1 zsh -i -c exit`
if [[ -n "$ZSH_DEBUGRC" ]]; then
  zmodload zsh/zprof
fi

# Required for $langinfo
zmodload zsh/langinfo

setopt autocd autopushd
setopt NO_VERBOSE

export EDITOR=nvim
export VISUAL=nvim
export MICRO_TRUECOLOR=1
#export BAT_THEME="ansi"

#######
## Load Functions
#######
# Add custom function directory to fpath
fpath=($ZDOTDIR/functions $fpath)

# Autoload all function files in ~/.config/zsh/functions
for func_file in $ZDOTDIR/functions/*(.N); do
  autoload -Uz $(basename "$func_file")
done

#######
## Load Plugins
## Download Znap, if it's not there yet.
#######
[[ -r $ZDOTDIR/plugins/znap/znap.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git $ZDOTDIR/plugins/znap
source $ZDOTDIR/plugins/znap/znap.zsh  # Start Znap

znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-history-substring-search
znap source zdharma-continuum/fast-syntax-highlighting
znap source MichaelAquilina/zsh-you-should-use

#######
## Load Modules
##
## Modules are my own personal mini-plugins for ZSH.
## These can contain completions, aliases, and functions
## that are useful.
## Any file with a zsh extension will be loaded.
#######

for file in $ZDOTDIR/modules/*.zsh; do
  [ -f "$file" ] && source "$file"
done

# [[ -f $ZDOTDIR/functions.zsh ]] && source $ZDOTDIR/functions.zsh
# [[ -f $ZDOTDIR/completions.zsh ]] && source $ZDOTDIR/completions.zsh

#######
## Re-Configure the $PATH
#######
prepend_to_path $HOME/.local/bin $HOME/.composer/vendor/bin
# Move Homebrew Paths to the beginning of the path array.
start_of_path /opt/homebrew/sbin
start_of_path /opt/homebrew/bin

# load local system configuration if it exists
if [ -f "$HOME/.zsh_local" ]; then
  source "$HOME/.zsh_local"
fi

[[ -f $ZDOTDIR/aliases.zsh ]] && source $ZDOTDIR/aliases.zsh 

# The completion system activation
# https://gist.github.com/ctechols/ca1035271ad134841284
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
	compinit;
else
	compinit -C;
fi;

## TODO: Move the below to modules.
# TealDeer (TLDR)
if (command -v tldr) &>/dev/null; then
    export TEALDEER_CONFIG_DIR="$HOME/.config/tealdeer"
fi

if (command -v fzf) &>/dev/null; then
    eval "$(fzf --zsh)"
fi

if (command -v fzf) &>/dev/null; then
    eval "$(thefuck --alias fuck)"
    alias wtf="fuck"
fi

##############################################################################
# Prompt https://starship.rs
##############################################################################
if command -v starship &>/dev/null; then
    export STARSHIP_CONFIG="${HOME}/.config/starship/dracula.toml"
    export STARSHIP_LOG=error    
    eval "$(starship init zsh)"
fi
## End TODO

fortune | lolcat

if [[ -n "$ZSH_DEBUGRC" ]]; then
  zprof
fi
