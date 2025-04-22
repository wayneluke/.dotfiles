#!/bin/zsh

autoload -Uz colors && colors

#==============================#
#        Logging Functions     #
#==============================#

log() {
  local type="$1"; shift
  local prefix ts
  ts="[%D{%H:%M:%S}]"

  case "$type" in
    info)    prefix="%{$fg[cyan]%}ℹ%{$reset_color%}" ;;
    success) prefix="%{$fg[green]%}✔%{$reset_color%}" ;;
    warning) prefix="%{$fg[yellow]%}⚠%{$reset_color%}" ;;
    error)   prefix="%{$fg[red]%}✖%{$reset_color%}" ;;
    title)   prefix="%{$fg_bold[blue]%}➤%{$reset_color%}" ;;
    *)       prefix=" " ;;
  esac

  print -P "${ts} ${prefix} $*"
}

log_box() {
  local title="$1"
  print -P "%{$fg_bold[magenta]%}══════════════════════════════════════"
  print -P "  ${title}"
  print -P "══════════════════════════════════════%{$reset_color%}"
}

#==============================#
#       Installation Checks    #
#==============================#

check_and_install_xcode_cli() {
  log title "Checking Xcode Command Line Tools"

  if xcode-select -p &>/dev/null; then
    log success "Xcode Command Line Tools already installed."
  else
    log warning "Xcode Command Line Tools not found."
    log info "Starting installation..."

    xcode-select --install

    until xcode-select -p &>/dev/null; do
      echo -n "."
      sleep 5
    done

    log success "Xcode Command Line Tools installed."
  fi
}

check_git_installed() {
  log title "Checking Git"

  if command -v git &>/dev/null; then
    log success "Git is installed."
  else
    log warning "Git is not installed."
    check_and_install_xcode_cli

    if command -v git &>/dev/null; then
      log success "Git is now available after installing Xcode CLT."
    else
      log error "Git still not found. Please install manually."
    fi
  fi
}

check_homebrew_installed() {
  log title "Checking Homebrew"

  if command -v brew &>/dev/null; then
    log success "Homebrew is installed."
  else
    log warning "Homebrew is not installed."
    log info "Installing Homebrew..."

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if command -v brew &>/dev/null; then
      log success "Homebrew installed successfully."
    else
      log error "Homebrew installation failed."
    fi
  fi
}

#==============================#
#       Brewfile Installer     #
#==============================#

install_brewfile() {
  local name="$1"
  local file="./homebrew/Brewfile.${name}"

  if [[ -f "$file" ]]; then
    log info "Installing from $file..."
    brew bundle --file="$file"
    log success "Finished installing $file"
  else
    log warning "$file not found. Skipping."
  fi
}

run_brewfile_menu() {
  log_box "Brewfile Installation Menu"

  echo "Select what to install:"
  echo "  1) All (Default)"
  echo "  2) Essential only"
  echo "  3) Brews only"
  echo "  4) Casks only"
  echo "  5) Mac App Store (mas) only"
  echo "  6) Fonts only"
  echo -n "Enter your choice [1]: "
  read choice

  case "$choice" in
    2) install_brewfile "essential" ;;
    3) install_brewfile "brews" ;;
    4) install_brewfile "casks" ;;
    5) install_brewfile "mas" ;;
    6) install_brewfile "fonts" ;;
    *)  # Default to all
      install_brewfile "essential"
      install_brewfile "brews"
      install_brewfile "casks"
      install_brewfile "mas"
      install_brewfile "fonts"
      ;;
  esac
}

#==============================#
#      Copy Local Files        #
#==============================#

copy_local_files() {
  local source_dir="./local"
  local dest_dir="$HOME/.local"
  local bin_dir="$dest_dir/bin"

  log title "Copying Local Files"

  if [[ -d "$source_dir" ]]; then
    mkdir -p "$dest_dir"
    cp -a "$source_dir/." "$dest_dir/"
    log success "Local files copied to $dest_dir"

    if [[ -d "$bin_dir" ]]; then
      chmod +x "$bin_dir"/* 2>/dev/null
      log success "Made all files in $bin_dir executable"
    else
      log warning "No $bin_dir directory found. Skipping chmod."
    fi
  else
    log warning "Source directory '$source_dir' not found. Skipping copy."
  fi
}

#==============================#
#      Copy Config Files       #
#==============================#

copy_config_files() {
  local source_dir="./config"
  local dest_dir="$HOME/.config"
  local zshenv_file="./zshenv"
  local zshenv_target="$HOME/.zshenv"

  log title "Copying Configuration Files"

  if [[ -d "$source_dir" ]]; then
    mkdir -p "$dest_dir"
    cp -a "$source_dir/." "$dest_dir/"
    log success "Config files copied to $dest_dir"
  else
    log warning "Source directory '$source_dir' not found. Skipping config copy."
  fi

  if [[ -f "$zshenv_file" ]]; then
    cp "$zshenv_file" "$zshenv_target"
    log success "Copied zshenv to $zshenv_target"
  else
    log warning "$zshenv_file not found. Skipping .zshenv copy."
  fi
}

#==============================#
#       Link Directories       #
#==============================#

link_common_directories() {
  log title "Creating Common Symlinks"

  local targets=(Sites Files Customer Projects)
  local base_dir="/volumes/secondary/"
  local home_dir="$HOME"
  local backup_dir="$home_dir/.backup_links/$(date +%Y%m%d-%H%M%S)"

  for dir in "${targets[@]}"; do
    local target_path="$base_dir/$dir"
    local link_path="$home_dir/$dir"

    if [[ ! -d "$target_path" ]]; then
      log warning "Target $target_path does not exist. Skipping."
      continue
    fi

    if [[ -L "$link_path" ]]; then
      local resolved="$(readlink "$link_path")"
      if [[ "$resolved" == "$target_path" ]]; then
        log info "$link_path is already a valid symlink. Skipping."
      else
        log warning "$link_path is a symlink to the wrong location. Backing up and replacing."
        mkdir -p "$backup_dir"
        mv "$link_path" "$backup_dir/"
        ln -s "$target_path" "$link_path"
        log success "Re-linked $link_path → $target_path"
      fi
    elif [[ -e "$link_path" ]]; then
      log warning "$link_path exists as a real directory. Backing up and replacing."
      mkdir -p "$backup_dir"
      mv "$link_path" "$backup_dir/"
      ln -s "$target_path" "$link_path"
      log success "Linked $link_path → $target_path"
    else
      ln -s "$target_path" "$link_path"
      log success "Linked $link_path → $target_path"
    fi
  done

  if [[ -d "$backup_dir" ]]; then
    log info "Backups saved in: $backup_dir"
  fi
}

#==============================#
#       Generate SSH Key       #
#==============================#

create_github_ssh_key() {
  log title "GitHub SSH Key Setup"

  local ssh_dir="$HOME/.ssh"
  local key_file="$ssh_dir/id_ed25519"
  local email

  if [[ -f "$key_file" ]]; then
    log success "SSH key already exists at $key_file"
  else
    echo -n "Enter your GitHub email address: "
    read email

    if [[ -z "$email" ]]; then
      log error "Email is required. Aborting."
      return
    fi

    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"

    ssh-keygen -t ed25519 -C "$email" -f "$key_file" -N ""
    log success "SSH key generated at $key_file"

    eval "$(ssh-agent -s)"
    ssh-add "$key_file"

    log success "SSH key added to agent"
  fi

  echo
  log info "Here is your public key (add it to GitHub):"
  echo
  cat "$key_file.pub"
  echo
}

#==============================#
#         Main Menu            #
#==============================#

main_menu() {
  log_box "Setup Menu"

  echo "Choose what to do:"
  echo "  1) Run all tasks (default)"
  echo "  2) Install Brewfiles only"
  echo "  3) Copy config files only"
  echo "  4) Copy local files only"
  echo "  5) Link common directories (sites, files, customer, projects)"
  echo "  6) Source install scripts"
  echo "  7) Create GitHub SSH key"
  echo "  8) Quit"
  echo -n "Enter your choice [1]: "
  read main_choice

  case "$main_choice" in
    2) run_brewfile_menu ;;
    3) copy_config_files ;;
    4) copy_local_files ;;
    5) link_common_directories ;;
    6) source_install_scripts ;;
    7) create_github_ssh_key ;;
    8) log info "Exiting..."; return ;;
    *)
      check_git_installed
      check_homebrew_installed
      run_brewfile_menu
      copy_config_files
      copy_local_files
      link_common_directories
      source_install_scripts      
      create_github_ssh_key
      ;;
  esac
}

#==============================#
#         Entry Point          #
#==============================#

log_box "Initializing System"
check_git_installed
check_homebrew_installed
main_menu