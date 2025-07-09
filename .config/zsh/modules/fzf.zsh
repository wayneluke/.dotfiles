if  exists fzf; then
    # Set up fzf key bindings and fuzzy completion
    source <(fzf --zsh)
    
    # export FZF_DEFAULT_OPTS=' - height=40% - preview="bat - color=always {}" - preview-window=right:60%:wrap'
fi