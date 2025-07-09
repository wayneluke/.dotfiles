if exists zoxide; then
    eval "$(zoxide init zsh)"
    
    alias downloads="z ~/downloads && ll"
    alias documents="z ~/documents && ll"
    alias sites="z ~/sites && ll"
    alias files="z ~/files && ll"
fi