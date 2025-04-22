# Homebrew
if command -v brew >/dev/null 2>&1; then

  ## Clean up Homebrew directory to prevent errors.
  delete_ds_store_files /opt/*
  
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_INSECURE_REDIRECT=1
    export HOMEBREW_AUTO_UPDATE_SECS=86400
    export HOMEBREW_NO_ENV_HINTS=True
    export HOMEBREW_NO_INSTALL_CLEANUP=1

    # Aliases 
    alias bfile='brew bundle dump --all --force --file=~/.config/Brewfile'
    alias binfo='brew info'
    alias blist='brew list'
    alias bsearch='brew search'
    alias services='brew services'
    alias pour='brew install'
    alias drain='brew uninstall'

    # Functions

    function brews() {
        local formulae="$(brew leaves | xargs brew deps --installed --formulae --for-each)"
        local casks="$(brew list --cask 2>/dev/null)"

        local blue="$(tput setaf 4)"
        local bold="$(tput bold)"
        local off="$(tput sgr0)"

        echo "${blue}==>${off} ${bold}Formulae${off}"
        echo "${formulae}" | sed "s/^\(.*\):\(.*\)$/\1${blue}\2${off}/"
        echo "\n${blue}==>${off} ${bold}Casks${off}\n${casks}"
    }

    function bupdate() {
        echo "Starting Homebrew maintenance..."

        # Update Homebrew
        if brew update; then
            echo "Homebrew updated successfully."
        else
            echo "Error: Homebrew update failed." >&2
            return 1
        fi

        # Upgrade installed packages
        if brew upgrade; then
            echo "Homebrew packages upgraded successfully."
        else
            echo "Error: Homebrew upgrade failed." >&2
            return 1
        fi
        
        # Check Casks
        if brew cu -q; then
            echo "Homebrew casks upgraded successfully."
        else 
            echo "Error: Cask upgrades failed." >&2
            return 1
        fi
        
        # Cleanup old versions
        if brew cleanup; then
            echo "Homebrew cleanup completed successfully."
        else
            echo "Error: Homebrew cleanup failed." >&2
            return 1
        fi

        echo "Homebrew maintenance completed."
    }
fi