# general aliases
alias cat='bat'
alias cdls='cd $1 && ls'
alias code='zed -n'
alias edit='zed -n'
alias grep='grep --color'
alias guid='uuidgen | tr "[A-Z]" "[a-z]"'
alias img='imgcat'
alias man="batman"
alias mkcd='(){mkdir -p "$1"; cd "$1"}'
alias new='touch'
alias sysinfo='system_profiler SPSoftwareDataType'
alias dotfiles='git --git-dir=$HOME/.dotfiles/'

# SHORTCUTS
alias c='cp -i'
alias cls='clear && ll'
alias h='history -10'
alias r='source ~/.config/zsh/.zshrc'
alias x="exit"

# IP ADDRESSES
alias ipv4="curl -4 ifconfig.me"
alias ipv6="curl -6 ifconfig.me"


# Edit files
alias -s {js,json,env,md,html,css,php,toml,xml}=code

# For Fun.
alias quip="fortune | lolcat"
