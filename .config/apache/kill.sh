#!/bin/zsh
# 
# Disables the version of Apache installed by Apple.

sudo apachectl -k stop
sudo launchctl unload -w /System/Library/LaunchDaemons/org.apache.httpd.plist 2>/dev/null