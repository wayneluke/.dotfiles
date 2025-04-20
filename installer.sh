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
  echo -n "Enter your choice [1]: "
  read choice

  case "$choice" in
    2) install_brewfile "essential" ;;
    3) install_brewfile "brews" ;;
    4) install_brewfile "casks" ;;
    5) install_brewfile "mas" ;;
    *)  # Default to all
      install_brewfile "essential"
      install_brewfile "brews"
      install_brewfile "casks"
      install_brewfile "mas"
      ;;
  esac
}

#==============================#
#        Config Copier         #
#==============================#

copy_config_files() {
  local source_dir="./config"
  local dest_dir="$HOME/.config"

  log title "Copying Configuration Files"

  if [[ -d "$source_dir" ]]; then
    mkdir -p "$dest_dir"
    cp -a "$source_dir/." "$dest_dir/"
    log success "Config files copied to $dest_dir"
  else
    log warning "Source directory '$source_dir' not found. Skipping copy."
  fi
}

#==============================#
#         Local Copier         #
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

  local targets=(Sites Files Customers Projects)
  local base_dir="/volumes/secondary/"
  local home_dir="$HOME"

  for dir in "${targets[@]}"; do
    local target_path="$base_dir/$dir"
    local link_path="$home_dir/$dir"

    if [[ -e "$link_path" && ! -L "$link_path" ]]; then
      log warning "$link_path exists and is not a symlink. Skipping."
    elif [[ -L "$link_path" ]]; then
      log info "$link_path already exists as a symlink. Skipping."
    elif [[ -d "$target_path" ]]; then
      ln -s "$target_path" "$link_path"
      log success "Linked $link_path → $target_path"
    else
      log warning "Target $target_path not found. Skipping."
    fi
  done
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
  echo "  Q) Quit"
  echo -n "Enter your choice [1]: "
  read main_choice

  case "$main_choice" in
    2) run_brewfile_menu ;;
    3) copy_config_files ;;
    4) copy_local_files ;;
    Q) log info "Exiting..." && return ;;
    *)
      check_git_installed
      check_homebrew_installed
      run_brewfile_menu
      copy_config_files
      copy_local_files
      ;;
  esac
}

#==============================#
#         Entry Point          #
#==============================#

main_menu