#!/usr/bin/env sh

dockutil --no-restart --remove all
dockutil --no-restart --add "/Applications/Finder.app" # Default app
dockutil --no-restart --add "/Applications/Google Chrome.app"
dockutil --no-restart --add "/Applications/Reminders.app" # Default app
dockutil --no-restart --add "/Applications/Notes.app" # Default app
dockutil --no-restart --add "/Applications/Evernote.app" # MAS
dockutil --no-restart --add "/Applications/Slack.app" # MAS
dockutil --no-restart --add "/Applications/iTerm.app"
dockutil --no-restart --add "/Applications/System Preferences.app" # Default app
dockutil --no-restart --add "/Applications/App Store.app" # Default app
dockutil --no-restart --add "/Applications/Soulver.app"
dockutil --no-restart --add "/Applications/Skype.app"
dockutil --no-restart --add "/Applications/Telegram.app"
dockutil --no-restart --add "/Applications/Safari.app" # Default app

killall Dock

# If you have trouble with icons appearing as generic placeholders, try running
# the following commands.

# sudo rm -rfv /Library/Caches/com.apple.iconservices.store
# sudo find /private/var/folders/ \( -name com.apple.dock.iconcache -or -name com.apple.iconservices \) -exec rm -rfv {} \;
# sleep 3;
# sudo touch /Applications/*
# killall Dock
# killall Finder

# Reference:
# - https://gist.github.com/fabiofl/5873100
# - https://www.hackintosh.blog/article/24/rebuild-icon-cache-macos/