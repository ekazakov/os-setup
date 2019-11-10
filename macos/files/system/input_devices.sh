#!/usr/bin/env sh

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

  defaults write com.apple.AppleMultitouchTrackpad ActuateDetents -int 0
  defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1
  defaults write com.apple.AppleMultitouchTrackpad DragLock -int 0
  defaults write com.apple.AppleMultitouchTrackpad Dragging -int 0
  defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 1
  defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -int 1
  defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 1
  defaults write com.apple.AppleMultitouchTrackpad TrackpadCornerSecondaryClick -int 0
  defaults write com.apple.AppleMultitouchTrackpad TrackpadFiveFingerPinchGesture -int 2
  defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 2
  defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerPinchGesture -int 2
  defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -int 2
  defaults write com.apple.AppleMultitouchTrackpad TrackpadHandResting -int 1
  defaults write com.apple.AppleMultitouchTrackpad TrackpadHorizScroll -int 1
  defaults write com.apple.AppleMultitouchTrackpad TrackpadMomentumScroll -int 1
  defaults write com.apple.AppleMultitouchTrackpad TrackpadPinch -int 1
  defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -int 1
  defaults write com.apple.AppleMultitouchTrackpad TrackpadRotate -int 1
  defaults write com.apple.AppleMultitouchTrackpad TrackpadScroll -int 1
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -int 0
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 2
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 0
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 2
  defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerDoubleTapGesture -int 1
  defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 3
  defaults write com.apple.AppleMultitouchTrackpad USBMouseStopsTrackpad -int 0
  defaults write com.apple.AppleMultitouchTrackpad UserPreferences -int 1

# Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Use scroll gesture with the Ctrl (^) modifier key to zoom
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.AppleMultitouchTrackpad HIDScrollZoomModifierMask -int 262144
# Follow the keyboard focus while zoomed in
defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

# Disable press-and-hold for keys in favor of key repeat
#defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Set language and text formats
# Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
# `Inches`, `en_GB` with `en_US`, and `true` with `false`.
defaults write NSGlobalDomain AppleLanguages -array "en" "nl"
defaults write NSGlobalDomain AppleLocale -string "en_GB@currency=EUR"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true

# Show language menu in the top right corner of the boot screen
sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true

# Set the timezone; see `sudo systemsetup -listtimezones` for other values
#sudo systemsetup -settimezone "Europe/Brussels" > /dev/null

# Stop iTunes from responding to the keyboard media keys
#launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null
