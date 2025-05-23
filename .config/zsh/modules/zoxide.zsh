if exists zoxide; then
    eval "$(zoxide init --cmd cd zsh)"
    
    alias downloads="cd ~/downloads && ll"
    alias documents="cd ~/documents && ll"
    alias sites="cd ~/sites && ll"
    alias files="cd ~/files && ll"
fi