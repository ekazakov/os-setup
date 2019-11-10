#!/usr/bin/env sh

# alot about macos defaults https://www.defaults-write.com/

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
#sudo -v

# Keep-alive: update existing `sudo` time stamp until `.setup_macos_defaults` has finished
#while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
