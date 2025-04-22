# This stuff should only be loaded on MacOS

if [ "$(uname)" = "Darwin" ]; then
  # Disk Utilities
  alias dl='diskutil list'      # macOS only; list all block devices
  alias mount='diskutil mount'    # macOS only; mount drive
  alias unmount='diskutil unmount' # macOS only; unmount drive
  alias eject='diskutil eject'  # macOS only; eject drive
  
  # Finder
  alias fcustomers="open ~/customers"
  alias fdocs="open ~/documents"
  alias fdown="open ~/downloads"
  alias ffiles="open ~/files"
  alias fsites="open ~/sites"
  alias fgo="open "
  
  # Applications
  alias notes="open -a notes.app"
  alias calendar="open -a calendar.app"
  alias music="open -a music.app"
  alias newtab='open -a iterm .'
  alias o="open -a"
  alias preview='open -a preview'
fi