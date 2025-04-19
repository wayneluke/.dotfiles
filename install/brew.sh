#!/bin/bash

# Brew install and setup
xcode-select --install

# Check for Homebrew, install if not installed
if test ! $(which brew); then
    echo "Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Enables brew in current env
eval "$(/opt/homebrew/bin/brew shellenv)"

# Disables brew telemetry
echo -e "Disabling Homebrew telemetry..."
brew analytics off

# Brew Apps installed from Brewfile
echo -e "Installing apps..."
brew bundle install --file $HOME/.config/Brewfile