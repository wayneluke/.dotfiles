if  exists fzf; then
    # Set up fzf key bindings and fuzzy completion
    source <(fzf --zsh)
    
    # fzf configuration:
    export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type=d --hidden --strip-cwd-prefix --exclude .git'
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=header,grid --line-range :300 {}"
    export FZF_ALT_C_OPTS="--preview 'bat --color=always --style=header,grid --line-range :300 {}'"
    
    export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
      --color=fg:#d0d0d0,fg+:#d0d0d0,bg:#121212,bg+:#262626
      --color=hl:#5f87af,hl+:#5fd7ff,info:#afaf87,marker:#87ff00
      --color=prompt:#d7005f,spinner:#af5fff,pointer:#af5fff,header:#87afaf
      --color=border:#262626,label:#aeaeae,query:#d9d9d9
      --border="double" --border-label="" --preview-window="border-rounded" --prompt="> "
      --marker=">" --pointer="◆" --separator="─" --scrollbar="│"'
      
      # Use fd (https://github.com/sharkdp/fd) for listing path candidates.
      # - The first argument to the function ($1) is the base path to start traversal
      # - See the source code (completion.{bash,zsh}) for the details.
      _fzf_compgen_path () {
        fd --hidden --no-ignore-vcs --exclude .git . "$1"
      }
      
      # Use fd to generate the list for directory completion
      _fzf_compgen_dir () {
        fd --type=d --hidden --no-ignore-vcs --exclude .git . "$1"
      }
    
fi