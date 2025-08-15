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

#######
## Re-Configure the $PATH
#######
start_of_path $HOME/.composer/vendor/bin
start_of_path $XDG_BIN_HOME
start_of_path /opt/homebrew/opt/ruby@3.3/bin
start_of_path /opt/homebrew/Cellar/mysql@8.4/8.4.5/bin
start_of_path /opt/homebrew/sbin
start_of_path /opt/homebrew/bin

[[ -f $ZDOTDIR/aliases.zsh ]] && source $ZDOTDIR/aliases.zsh 
[[ -f $ZDOTDIR/completions.zsh ]] && source $ZDOTDIR/completions.zsh 
[[ -f ~/.local.zsh ]] && source ~/.local.zsh

##############################################################################
# Prompt https://starship.rs
##############################################################################
if command -v starship &>/dev/null; then
    export STARSHIP_CONFIG="${HOME}/.config/starship/starship.toml"
    export STARSHIP_LOG=error    
    eval "$(starship init zsh)"
fi
## End TODO

fortune | lolcat

if [[ -n "$ZSH_DEBUGRC" ]]; then
  zprof
fi
