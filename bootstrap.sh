#!/bin/zsh

autoload -Uz colors && colors

# Add some logging functions.

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

# Add function to see if command exists.

exists() { command -v "$1" >/dev/null 2>&1; }

####
# Main Script
####

if exists xcode-select; then
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

if exists brew; then
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

