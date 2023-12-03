#!/usr/bin/env bash

echo "Need to recapture iTerm settings"
exit -1

# TODO: Need to figure out the settings for the following:
#    1) Finder: Left nav, favorite items with their order
#    2) Dock: Items with order
#    3) Security & Privacy Preferences: Full Disk Access, Camera, Microphone
#    4) Login items for my user (i.e. apps started when I login)
#    5) Global Keyboard shortcuts: Cmd+Shift+/ (Help menu)
#    6) Retina displays

##
# This is a script with useful tips taken from:
#   https://gist.github.com/DAddYE/2108403
#
# Run in interactive mode with:
#   $ sh -c "$(curl -sL https://gist.githubusercontent.com/vraravam/5e28ca1720c9dddacdc0e6db61e093fe/raw/460cf7359ff348657760f03cbef2fb22099e27d6/osx_defaults.sh)"
#
# or run it without prompt questions:
#   $ sh -c "$(curl -sL https://gist.githubusercontent.com/vraravam/5e28ca1720c9dddacdc0e6db61e093fe/raw/460cf7359ff348657760f03cbef2fb22099e27d6/osx_defaults.sh)" -s silent
#
# Please, share your tips commenting here:
#   https://gist.github.com/vraravam/5e28ca1720c9dddacdc0e6db61e093fe
#
# Author: @vraravam
# Thanks to: @erikh, @DAddYE, @mathiasbynens
#

case $1 in
  "-s" | "-y" | "--silent" | "silent" )
    echo "Running in silent mode..."
    auto=Y
    shift 1
    ;;
  *)
    auto=N
    if [ ! -t 0 ]; then
      echo "Interactive mode needs terminal!" >&2
      exit 1
    fi
    ;;
esac

function ask {
  while true; do
    if [ "$2" == "Y" ]; then
      prompt="\033[1;32mY\033[0m/n"
      default=Y
    elif [ "$2" == "N" ]; then
      prompt="y/\033[1;32mN\033[0m"
      default=N
    else
      prompt="y/n"
      default=
    fi

    printf "$1 [$prompt] "

    if [ "$auto" == "Y" ]; then
      echo
    else
      read yn
    fi

    if [ -z "$yn" ]; then
      yn=$default
    fi

    case $yn in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
    esac
  done
}

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# While applying any changes to SoftwareUpdate defaults, set software update to OFF to avoid any conflict with the defaults system cache. (Also close the System Preferences app)
sudo softwareupdate --schedule OFF


###############################################################################
# Couldn't find the following settings in macOS Mojave (10.14.3)              #
###############################################################################

# Expand "save as..." dialog by default
# defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
# defaults write -g NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
# defaults write -g PMPrintingExpandedStateForPrint -bool true
# defaults write -g PMPrintingExpandedStateForPrint2 -bool true

# Restore the 'Save As' menu item (Equivalent to adding a Keyboard shortcut in the System Preferences.app )
# defaults write -g NSUserKeyEquivalents -dict-add 'Save As...' '@$S'

# Global User Interface Scale Multiplier:
# defaults write -g AppleDisplayScaleFactor -float

# Enable continuous spell checking everywhere:
# defaults write -g WebContinuousSpellCheckingEnabled -boolean

# Enable automatic dash replacement everywhere:
# defaults write -g WebAutomaticDashSubstitutionEnabled -boolean

# Enable automatic text replacement everywhere:
# defaults write -g WebAutomaticTextReplacementEnabled -boolean

# Icon Size for Open Panels:
# defaults write -g NSNavPanelIconViewIconSizeForOpenMode -number

# Keyboard press and hold behavior:
# defaults write -g ApplePressAndHoldEnabled -boolean

###############################################################################
# Login Window                                                                #
###############################################################################

if ask "Reveal system info (IP address, hostname, OS version, etc.) when clicking the clock in the login screen" Y; then
  sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
fi

if ask "Show language menu in the top right corner of the boot screen" Y; then
  sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true
fi

if ask "Disable guest login" Y; then
  sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false
fi

if ask "Add a message to the login screen" Y; then
  sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "Beware\! You are logging into Vijay's laptop\!"
fi

if ask "Change login screen background" N; then
  sudo defaults write /Library/Preferences/com.apple.loginwindow DesktopPicture "/Library/Desktop Pictures/Aqua Blue.jpg"
fi

if ask "Show Shutdown Button on Login Window" Y; then
  defaults write com.apple.loginwindow ShutDownDisabled -bool false
fi

if ask "Remove Restart Button From Login Window" N; then
  defaults write com.apple.loginwindow RestartDisabled -bool true
fi

if ask "Disable Login for Hidden User '>Console'" N; then
  defaults write com.apple.loginwindow DisableConsoleAccess -bool true
fi

###############################################################################
# MenuBar                                                                     #
###############################################################################

# Disable menu bar transparency - Couldn't find this in mac OS Mojave
# defaults write -g AppleEnableMenuBarTransparency -bool false

if ask "Show remaining battery time" N; then
  defaults write com.apple.menuextra.battery ShowTime -string "YES"
fi

if ask "Show remaining battery percentage" Y; then
  defaults write com.apple.menuextra.battery ShowPercent -string "YES"
fi

###############################################################################
# General UI/UX                                                               #
###############################################################################

#if ask "Set computer name (as done via System Preferences → Sharing)" Y; then
#  sudo scutil --set ComputerName "Evgenii MBP"
#  sudo scutil --set HostName "Evgenii"
#  sudo scutil --set LocalHostName "Evgenii"
#  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "Evgenii"
#fi

#if ask "Set standby delay to 6 hours (default: 1 hour)" Y; then
#  sudo pmset -a standbydelay 21600
#fi

# Disable the sound effects on boot
# sudo nvram SystemAudioVolume=" "

for domain in ~/Library/Preferences/ByHost/com.apple.systemuiserver.*; do
  defaults write "${domain}" dontAutoLoad -array \
    "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
    "/System/Library/CoreServices/Menu Extras/Volume.menu" \
    "/System/Library/CoreServices/Menu Extras/User.menu"
done
defaults write com.apple.systemuiserver menuExtras -array \
  "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
  "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
  "/System/Library/CoreServices/Menu Extras/Battery.menu" \
  "/System/Library/CoreServices/Menu Extras/Clock.menu" \
  "/System/Library/CoreServices/Menu Extras/User.menu" \
  "/System/Library/CoreServices/Menu Extras/Volume.menu"

defaults write com.apple.systemuiserver "NSStatusItem Visible Siri" -bool false
defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.airport" -bool true
defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.appleuser" -bool true
defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.battery" -bool true
defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.bluetooth" -bool true
defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.volume" -bool true


if ask "Set the sidebar icon size to small(1), medium(2) or Large(3)" Y; then
  defaults write -g NSTableViewDefaultSizeMode -int 1
fi

if ask "Show scrollbars when scrolling" Y; then
  # Possible values: `WhenScrolling`, `Automatic` and `Always`
  defaults write -g AppleShowScrollBars -string "WhenScrolling"
fi

if ask "Temperature units" Y; then
  defaults write -g AppleTemperatureUnit -string "Celsius"
fi

if ask "Automatically quit printer app once the print jobs complete" Y; then
  defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
fi

if ask "Turn off the 'Application Downloaded from Internet' quarantine warning" Y; then
  defaults write com.apple.LaunchServices LSQuarantine -bool false
fi

if ask "Remove duplicates in the 'Open With' menu (also see 'lscleanup' alias)" Y; then
  /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
fi

# Display ASCII control characters using caret notation in standard text views
# Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
# defaults write -g NSTextShowsControlCharacters -bool true

# if ask "Enable multitouch trackpad auto orientation sensing (for all users)" Y; then
#   defaults write /Library/Preferences/com.apple.MultitouchSupport ForceAutoOrientation -boolean
# fi

if ask "Map navigation swipe to 3 fingers (turn this off to get 4-finger navigation swipe)" Y; then
  defaults write com.apple.systempreferences com.apple.preference.trackpad.3fdrag-4fNavigate -bool false
fi

if ask "Enable Resume applications on reboot (system-wide)" Y; then
  defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool true
  defaults write -g NSQuitAlwaysKeepsWindows -bool true
fi

if ask "Disable automatic termination of inactive apps" Y; then
  defaults write -g NSDisableAutomaticTermination -bool true
fi

if ask "Disable the crash reporter (quit dialog after an application crash) (default: 'crashreport')" Y; then
  defaults write com.apple.CrashReporter DialogType -string "none"
fi

if ask "Set Help Viewer windows to non-floating mode" Y; then
  defaults write com.apple.helpviewer DevMode -bool true
fi

if ask "Restart automatically if the computer freezes" Y; then
  sudo systemsetup -setrestartfreeze on
fi

if ask "Set the timezone" Y; then
  # see 'sudo systemsetup -listtimezones' for other values
  sudo systemsetup -settimezone "Asia/Calcutta"
fi

if ask "Set the time using the network time" Y; then
  systemsetup -setusingnetworktime on
fi

if ask "Set the computer sleep time to 10 minutes" Y; then
  # To never go into computer sleep mode, use 'Never' or 'Off'
  sudo systemsetup -setcomputersleep 10
fi

if ask "Set the display sleep time to 10 minutes" Y; then
  # To never go into display sleep mode, use 'Never' or 'Off'
  sudo systemsetup -setdisplaysleep 10
fi

if ask "Set the harddisk sleep time to 15 minutes" Y; then
  # To never go into harddisk sleep mode, use 'Never' or 'Off'
  sudo systemsetup -setharddisksleep 15
fi

# Disable Notification Center and remove the menu bar icon
# launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null

if ask "Disable automatic capitalization as it’s annoying when typing code" Y; then
  defaults write -g NSAutomaticCapitalizationEnabled -bool false
fi

if ask "Enable smart dashes as they’re annoying when typing code" Y; then
  defaults write -g NSAutomaticDashSubstitutionEnabled -bool true
fi

if ask "Set the languages present" Y; then
  defaults write -g NSLinguisticDataAssetsRequested -array "en_IN" "en_US" "en"
  defaults delete NSGlobalDomain NSNavRecentPlaces
fi

# TODO: defaults write -g NSPreferredWebServices NSWebServicesProviderWebSearch

if ask "Set the some english acronyms/short forms for ease of typing" Y; then
  defaults write -g NSUserDictionaryReplacementItems -array \
    '{ on = 1; replace = cyl; with = "Cya later!"; }' \
    '{ on = 1; replace = ttyl; with = "Talk to you later!"; }' \
    '{ on = 1; replace = omw; with = "On my way!"; }' \
    '{ on = 1; replace = omg; with = "Oh my God!"; }'
fi

if ask "Disable automatic period substitution as it’s annoying when typing code" Y; then
  defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
fi

if ask "Enable auto-correct" Y; then
  defaults write -g NSAutomaticSpellingCorrectionEnabled -bool true
fi

###############################################################################
# Text Edit                                                                   #
###############################################################################

if ask "Use plain text mode for new TextEdit documents" Y; then
  defaults write com.apple.TextEdit RichText -int 0
fi

if ask "Open and save files as UTF-8 in TextEdit" Y; then
  defaults write com.apple.TextEdit PlainTextEncoding -int 4
  defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4
fi

###############################################################################
# SSD-specific tweaks                                                         #
###############################################################################

if ask "Disable hibernation (speeds up entering sleep mode)" Y; then
  sudo pmset -a hibernatemode 0
fi

if ask "Disable the sudden motion sensor as it’s not useful for SSDs" Y; then
  sudo pmset -a sms 0
fi

if ask "Increase sound quality for Bluetooth headphones/headsets" Y; then
  defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40
fi

###############################################################################
# DiskUtility                                                                 #
###############################################################################

if ask "Show a Debug menu in Disk Utility" Y; then
  defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
fi

if ask "Enables additional disk image options" Y; then
  defaults write com.apple.DiskUtility advanced-image-options -bool true
fi

if ask "Shows all partitions for a disk in the main list" Y; then
  defaults write com.apple.DiskUtility DUShowEveryPartition -bool true
fi

if ask "Skip checksum verification for images on remote volumes" Y; then
  defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true
fi

if ask "Skip checksum verification for images on locked volumes" Y; then
  defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
fi

if ask "Allows Disk Images As RAIDs" Y; then
  defaults write com.apple.DiskUtility DUAllowsDiskImagesAsRAIDs -bool true
fi

if ask "Disk Skip Verify" Y; then
  defaults write com.apple.DiskUtility DURestoreCanSkipVerify -bool true
fi

if ask "Debug All Message Level" Y; then
  defaults write com.apple.DiskUtility DUDebugMessageLevel -int 4
fi

if ask "Show Details In First Aid" Y; then
  defaults write com.apple.DiskUtility DUShowDetailsInFirstAid -bool true
fi

if ask "Disable disk image verification" Y; then
  defaults write com.apple.frameworks.diskimages skip-verify -bool true
fi

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

if ask "Enable Trackpad Gestures" Y; then
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -int 1
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad DragLock -int 0
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging -int 0
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 0
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFiveFingerPinchGesture -int 2
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerHorizSwipeGesture -int 2
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerPinchGesture -int 2
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerVertSwipeGesture -int 2
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadHandResting -int 1
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadHorizScroll -int 1
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadMomentumScroll -int 1
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadPinch -int 1
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -int 1
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRotate -int 1
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadScroll -int 1
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -int 0
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 2
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 0
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 2
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerDoubleTapGesture -int 1
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 3
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad USBMouseStopsTrackpad -int 0
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad UserPreferences -int 1
fi

if ask "Enable tap to click on trackpad" Y; then
  defaults write -g com.apple.mouse.tapBehavior -int 1
fi

if ask "Enable 'natural' (Lion-style) scrolling" Y; then
  defaults write -g com.apple.swipescrolldirection -bool true
fi

if ask "Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)" Y; then
  defaults write -g AppleKeyboardUIMode -int 3
fi

if ask "Set language and text formats" Y; then
  # Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
  # `Inches`, `en_GB` with `en_US`, and `true` with `false`.
  defaults write -g AppleLanguages -array "en-IN" "en"
  defaults write -g AppleLocale -string "en_IN@currency=INR"
  defaults write -g AppleMeasurementUnits -string "Centimeters"
  defaults write -g AppleMetricUnits -bool true
  defaults write -g AppleActionOnDoubleClick -string "Maximize"
fi

# Stop iTunes from responding to the keyboard media keys
# launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null

if ask "Check spelling as you type by default, unless the application specifies otherwise" Y; then
  defaults write -g CheckSpellingWhileTyping -bool true
fi

###############################################################################
# Finder                                                                      #
###############################################################################

if ask "Allow quitting Finder via ⌘ + Q; doing so will also hide desktop icons" Y; then
  defaults write com.apple.finder QuitMenuItem -bool true
fi

# if ask "Disable window animations and Get Info animations" Y; then
  # defaults write com.apple.finder DisableAllAnimations -bool true
# fi

if ask "Set Desktop as the default location for new Finder windows" Y; then
  # For other paths, use `PfLo` and `file:///full/path/here/`
  defaults write com.apple.finder NewWindowTarget -string "PfHm"
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
fi

if ask "Show icons for hard drives, servers, and removable media on the desktop" Y; then
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
  # defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
fi

# if ask "Show hidden files by default" Y; then
  # defaults write com.apple.finder AppleShowAllFiles -bool true
# fi

if ask "Show all filename extensions" Y; then
  defaults write -g AppleShowAllExtensions -bool true
fi

if ask "Hide status bar" Y; then
  defaults write com.apple.finder ShowStatusBar -bool false
fi

if ask "Start the status bar Path at $HOME (instead of Hard drive)" N; then
  defaults write /Library/Preferences/com.apple.finder PathBarRootAtHome -bool true
fi

if ask "Show path (breadcrumb) bar" Y; then
  defaults write com.apple.finder ShowPathbar -bool true
fi

if ask "Show preview pane" Y; then
  defaults write com.apple.finder ShowPreviewPane -bool false
fi

if ask "Allowing text selection in Quick Look/Preview in Finder by default" Y; then
  defaults write com.apple.finder QLEnableTextSelection -bool true
fi

if ask "Display full POSIX path as Finder window title" Y; then
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
fi

# if ask "Keep folders on top when sorting by name" Y; then
  # defaults write com.apple.finder _FXSortFoldersFirst -bool true
# fi

if ask "When performing a search, search the current folder by default (the default 'This Mac' is 'SCev')" Y; then
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
fi

if ask "Disable the warning when changing a file extension" Y; then
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
fi

# if ask "Enable spring loading for directories" Y; then
  # defaults write -g com.apple.springing.enabled -bool true
# fi

if ask "Remove the delay for spring loading for directories" Y; then
  defaults write -g com.apple.springing.delay -float 0
fi

if ask "Enable snap-to-grid for icons on the desktop and in other icon views" Y; then
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
fi

if ask "Increase grid spacing for icons on the desktop and in other icon views" Y; then
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 54" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 54" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 54" ~/Library/Preferences/com.apple.finder.plist
fi

if ask "Increase the size of icons on the desktop and in other icon views" Y; then
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 64" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 64" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 64" ~/Library/Preferences/com.apple.finder.plist
fi

if ask "Use list view in all Finder windows by default" Y; then
  # Four-letter codes for the other view modes: `icnv` (icon), `Nlsv` (list), `Flwv` (cover flow)
  defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
  defaults write com.apple.finder SearchRecentsSavedViewStyle -string "clmv"
fi

if ask "Disable creation of Metadata Files on Network Volumes (avoids creation of .DS_Store and AppleDouble files.)" Y; then
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
fi

if ask "Disable creation of Metadata Files on USB Volumes (avoids creation of .DS_Store and AppleDouble files.)" Y; then
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
fi

if ask "Disable the warning before emptying the Trash" Y; then
  defaults write com.apple.finder WarnOnEmptyTrash -bool false
fi

if ask "Empty Trash securely by default" Y; then
  defaults write com.apple.finder EmptyTrashSecurely -bool true
fi

if ask "Show app-centric sidebar" Y; then
  defaults write com.apple.finder FK_AppCentricShowSidebar -bool true
fi

if ask "Enable AirDrop over Ethernet and on unsupported Macs running Lion" Y; then
  defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true
fi

if ask "Automatically open a new Finder window when a volume is mounted" Y; then
  defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
  defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
  defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true
fi

if ask "Enable the MacBook Air SuperDrive on any Mac" N; then
  sudo nvram boot-args="mbasd=1"
fi

if ask "Show the '~/Library' folder" Y; then
  chflags nohidden ~/Library
fi

if ask "Show the '/Volumes' folder" Y; then
  sudo chflags nohidden /Volumes
fi

# Remove Dropbox’s green checkmark icons in Finder
# file=/Applications/Dropbox.app/Contents/Resources/emblem-dropbox-uptodate.icns
# [ -e "${file}" ] && mv -f "${file}" "${file}.bak"

if ask "Expand the following File Info panes: 'General', 'Open with', and 'Sharing & Permissions'" Y; then
  defaults write com.apple.finder FXInfoPanesExpanded -dict-add "General" -bool true
  defaults write com.apple.finder FXInfoPanesExpanded -dict-add "MetaData" -bool false
  defaults write com.apple.finder FXInfoPanesExpanded -dict-add "OpenWith" -bool true
  defaults write com.apple.finder FXInfoPanesExpanded -dict-add "Privileges" -bool true
fi

if ask "Windows which were open prior to logging out are re-opened after logging in" Y; then
  defaults write com.apple.finder RestoreWindowState -bool true
fi

if ask "Allow Rubberband scrolling" Y; then
  defaults write -g NSScrollViewRubberbanding -bool true
fi

# if ask "Location and style of scrollbar arrows" N; then
  # Applications often need to be relaunched to see the change.
  # defaults write -g AppleScrollBarVariant -string "DoubleBoth" true
# fi

###############################################################################
# Preview                                                                     #
###############################################################################
if ask "Scale images by default when printing" N; then
  defaults write com.apple.Preview PVImagePrintingScaleMode -bool true
fi

if ask "Preview Auto-rotate by default when printing" N; then
  defaults write com.apple.Preview PVImagePrintingAutoRotate -bool true
fi

if ask "Quit Always Keeps Windows" N; then
  defaults write com.apple.Preview NSQuitAlwaysKeepsWindows -bool true
fi

###############################################################################
# Keychain                                                                    #
###############################################################################

if ask "Keychain shows expired certificates" N; then
  defaults write com.apple.keychainaccess "Show Expired Certificates" -bool true
fi

if ask "Makes Keychain Access display *unsigned* ACL entries in italics" Y; then
  defaults write com.apple.keychainaccess "Distinguish Legacy ACLs" -bool true
fi

###############################################################################
# Remote Desktop                                                              #
###############################################################################

# if ask "Admin Console Allows Remote Control" N; then
#   defaults delete /Library/Preferences/com.apple.RemoteManagement AdminConsoleAllowsRemoteControl
# fi

# if ask "Disable Multicast" N; then
#   defaults write /Library/Preferences/com.apple.RemoteManagement ARD_MulticastAllowed -bool true
# fi

# if ask "Prevents system keys like command-tab from being sent" N; then
#   defaults write com.apple.RemoteDesktop DoNotSendSystemKeys -bool true
# fi

if ask "Show the Debug menu Remote Desktop" Y; then
  defaults write com.apple.remotedesktop IncludeDebugMenu -bool true
fi

if ask "Define user name display behavior" Y; then
  defaults write com.apple.remotedesktop showShortUserName -bool true
fi

# if ask "Set the maximum number of computers that can be observed: (up to 50 opposed to the default of 9)" Y; then
#   defaults write com.apple.RemoteDesktop multiObserveMaxPerScreen -int 9
# fi

###############################################################################
# Screen Sharing                                                              #
###############################################################################

# if ask "Prevent protection when attempting to remotely control this computer" N; then
#   defaults write com.apple.ScreenSharing skipLocalAddressCheck -bool true
# fi

# if ask "Disables system-level key combos like command-option-esc (Force Quit), command-tab (App switcher) to be used on the remote machine" N; then
#   defaults write com.apple.ScreenSharing DoNotSendSystemKeys -bool true
# fi

# if ask "Debug (To Show Bonjour)" N; then
#   defaults write com.apple.ScreenSharing debug -bool true
# fi

# if ask "Do Not Send Special Keys to Remote Machine" N; then
#   defaults write com.apple.ScreenSharing DoNotSendSystemKeys -bool true
# fi

# if ask "Skip local address check" N; then
#   defaults write com.apple.ScreenSharing skipLocalAddressCheck -bool true
# fi

# if ask "Screen sharing image quality" N; then
#   defaults write com.apple.ScreenSharing controlObserveQuality -int
# fi

# if ask "Number of recent hosts on ScreenSharingMenulet" N; then
#   defaults write com.klieme.ScreenSharingMenulet maxHosts -int
# fi

# if ask "Display IP-Addresses of the local hosts on ScreenSharingMenulet" N; then
#   defaults write com.klieme.ScreenSharingMenulet showIPAddresses -bool true
# fi

###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

if ask "Set the icon size of Dock items to 35 pixels" Y; then
  defaults write com.apple.dock tilesize -int 35
fi

if ask "Move the dock to the right side of the screen" Y; then
  defaults write com.apple.dock orientation -string "right"
fi

if ask "Minimize windows into their application’s icon" Y; then
  defaults write com.apple.dock minimize-to-application -bool true
fi

# if ask "Enable spring loading for all Dock items" Y; then
#   defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true
# fi

if ask "Enable highlight hover effect for the grid view of a stack (Dock)" Y; then
  defaults write com.apple.dock mouse-over-hilte-stack -bool true
fi

if ask "Show indicator lights for open applications in the Dock" Y; then
  defaults write com.apple.dock show-process-indicators -bool true
fi

if ask "Animate opening applications from the Dock" Y; then
  defaults write com.apple.dock launchanim -bool true
fi

if ask "Change minimize/maximize window effect" Y; then
  defaults write com.apple.dock mineffect -string "scale"
fi

if ask "Speed up Mission Control animations" Y; then
  defaults write com.apple.dock expose-animation-duration -float 0.5
fi

if ask "Don’t group windows by application in Mission Control (i.e. use the old Exposé behavior instead)" N; then
  defaults write com.apple.dock expose-group-by-app -bool false
fi

if ask "Disable dashboard widgets (saves RAM)" N; then
  defaults write com.apple.dashboard mcx-disabled -bool true
fi

if ask "Disable Mission Control" N; then
  defaults write com.apple.Dock mcx-expose-disabled -bool true
fi

if ask "Don’t show Dashboard as a Space" N; then
  defaults write com.apple.dock dashboard-in-overlay -bool true
fi

if ask "Show image for notifications" Y; then
  defaults write com.apple.dock notification-always-show-image -bool true
fi

if ask "Enable the 2D Dock" N; then
  defaults write com.apple.dock no-glass -bool true
fi

if ask "Disable Bouncing dock icons" N; then
  defaults write com.apple.dock no-bouncing -bool true
fi

if ask "Disable multi-display swoosh animations" N; then
  defaults write com.apple.dock workspaces-swoosh-animation-off -bool false
fi

if ask "Remove the animation when hiding or showing the dock" N; then
  defaults write com.apple.dock autohide-time-modifier -float 0
fi

if ask "Enable iTunes pop-up notifications" N; then
  defaults write com.apple.dock itunes-notifications -boolean true
fi

if ask "Add a 'Recent Applications' stack to the Dock" N; then
  defaults write com.apple.dock persistent-others -array-add '{ "tile-data" = { "list-type" = 1; }; "tile-type" = "recents-tile"; }'
fi

if ask "In Expose, only show windows from the current space" N; then
  defaults write com.apple.dock wvous-show-windows-in-other-spaces -bool false
fi


if ask "Automatically rearrange Spaces based on most recent use" Y; then
  defaults write com.apple.dock mru-spaces -bool true
fi

if ask "Remove the auto-hiding Dock delay" N; then
  defaults write com.apple.dock autohide-delay -float 0
fi

if ask "Remove the animation when hiding/showing the Dock" N; then
  defaults write com.apple.dock autohide-time-modifier -float 0
fi

if ask "Automatically hide and show the Dock" Y; then
  defaults write com.apple.dock autohide -bool true
fi

if ask "Automatically magnify the Dock" Y; then
  defaults write com.apple.dock magnification -bool true
fi

if ask "Make Dock icons of hidden applications translucent" Y; then
  defaults write com.apple.dock showhidden -bool true
fi

if ask "Enable highlight hover effect for the grid view of a stack (Dock)" Y; then
  defaults write com.apple.dock mouse-over-hilite-stack -bool true
fi

if ask "Enable the 'reopen windows when logging back in' option" Y; then
  # This works, although the checkbox will still appear to be checked.
  defaults write com.apple.loginwindow TALLogoutSavesState -bool true
  defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool true
fi

###############################################################################
# Launchpad                                                                   #
###############################################################################
if ask "Number of columns and rows in the dock springboard set to 10" Y; then
  defaults write com.apple.dock springboard-rows -int 10
  defaults write com.apple.dock springboard-columns -int 10
fi
# defaults write com.apple.dock ResetLaunchPad -bool true

if ask "Disable the Launchpad gesture (pinch with thumb and three fingers)" N; then
  defaults write com.apple.dock showLaunchpadGestureEnabled -int 0
fi

# Add iOS & Watch Simulator to Launchpad
# sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" "/Applications/Simulator.app"
# sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator (Watch).app" "/Applications/Simulator (Watch).app"

# Add a spacer to the left side of the Dock (where the applications are)
# defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
# Add a spacer to the right side of the Dock (where the Trash is)
# defaults write com.apple.dock persistent-others -array-add '{tile-data={}; tile-type="spacer-tile";}'

if ask "Hot corners" Y; then
  # Possible values:
  #  0: no-op
  #  2: Mission Control
  #  3: Show application windows
  #  4: Desktop
  #  5: Start screen saver
  #  6: Disable screen saver
  #  7: Dashboard
  # 10: Put display to sleep
  # 11: Launchpad
  # 12: Notification Center
  # Bottom left screen corner → Dashboard
  defaults write com.apple.dock wvous-bl-corner -int 7
  defaults write com.apple.dock wvous-bl-modifier -int 0
  # Top right screen corner → Mission Control
  defaults write com.apple.dock wvous-tr-corner -int 2
  defaults write com.apple.dock wvous-tr-modifier -int 0
  # Bottom right screen corner → Start screen saver
  defaults write com.apple.dock wvous-br-corner -int 5
  defaults write com.apple.dock wvous-br-modifier -int 0
fi

###############################################################################
# Safari & WebKit                                                             #
###############################################################################

if ask "Privacy: don’t send search queries to Apple" Y; then
  defaults write com.apple.Safari UniversalSearchEnabled -bool false
  defaults write com.apple.Safari SuppressSearchSuggestions -bool true
fi

# if ask "Press Tab to highlight each item on a web page" N; then
#   defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
#   defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true
# fi

if ask "Show the full URL in the address bar (note: this still hides the scheme)" Y; then
  defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true
fi

if ask "Set Safari’s home page to `about:blank` for faster loading" Y; then
  defaults write com.apple.Safari HomePage -string "about:blank"
fi

if ask "Prevent Safari from opening ‘safe’ files automatically after downloading" Y; then
  defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
fi

if ask "Allow hitting the Backspace key to go to the previous page in history" Y; then
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true
fi

if ask "Hide Safari’s bookmarks bar by default" Y; then
  defaults write com.apple.Safari ShowFavoritesBar -bool false
  defaults write com.apple.Safari "ShowFavoritesBar-v2" -bool false
fi

if ask "Hide Safari’s sidebar in Top Sites" Y; then
  defaults write com.apple.Safari ShowSidebarInTopSites -bool false
fi

if ask "Disable Safari’s thumbnail cache for History and Top Sites" Y; then
  defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2
fi

if ask "Enable Safari’s debug menu" Y; then
  defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
fi

if ask "Make Safari’s search banners default to Contains instead of Starts With" Y; then
  defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false
fi

if ask "Remove useless icons from Safari’s bookmarks bar" Y; then
  defaults write com.apple.Safari ProxiesInBookmarksBar "()"
fi

if ask "Warn about fraudulent websites" Y; then
  defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true
fi

if ask "Block pop-up windows" Y; then
  defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false
fi

if ask "Disable auto-playing video" Y; then
  defaults write com.apple.Safari WebKitMediaPlaybackAllowsInline -bool false
  defaults write com.apple.SafariTechnologyPreview WebKitMediaPlaybackAllowsInline -bool false
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false
  defaults write com.apple.SafariTechnologyPreview com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false
fi

if ask "Enable 'Do Not Track'" Y; then
  defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true
fi

if ask "Enable the Develop menu and the Web Inspector in Safari" Y; then
  defaults write com.apple.Safari IncludeDevelopMenu -bool true
  defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
fi

# Requires Safari 5.0.1 or later. Feature that is intended to increase the speed at which pages load. DNS (Domain Name System) prefetching kicks in when you load a webpage that contains links to other pages. As soon as the initial page is loaded, Safari 5.0.1 (or later) begins resolving the listed links’ domain names to their IP addresses. Prefetching can occasionally result in 'slow performance, partially-loaded pages, or webpage ‘cannot be found’ messages.”
if ask "Increase page load speed in Safari" Y; then
  defaults write com.apple.safari WebKitDNSPrefetchingEnabled -bool true
fi

if ask "Disable Data Detectors" Y; then
  defaults write com.apple.Safari WebKitUsesEncodingDetector -bool false
fi

if ask "Google Suggestion" Y; then
  defaults write com.apple.safari DebugSafari4IncludeGoogleSuggest -bool true
fi

if ask "Automatically spell check web forms" Y; then
  defaults write com.apple.safari WebContinuousSpellCheckingEnabled -bool true
fi

if ask "Automatically grammar check web forms" Y; then
  defaults write com.apple.safari WebGrammarCheckingEnabled -bool true
fi

if ask "Include page background colors and images when printing" N; then
  defaults write com.apple.safari WebKitShouldPrintBackgroundsPreferenceKey -bool true
fi

if ask "Enable developer menu in Safari" Y; then
  defaults write com.apple.Safari IncludeDebugMenu -bool true
fi



###############################################################################
# Parallels                                                                   #
###############################################################################

if ask "Disable Advertisments" Y; then
  defaults write com.parallels.Parallels\ Desktop ProductPromo.ForcePromoOff -bool true
fi


###############################################################################
# Spotlight                                                                   #
###############################################################################

if ask "Hide Spotlight tray-icon (and subsequent helper) from menubar" Y; then
  sudo chmod 600 /System/Library/CoreServices/Search.bundle/Contents/MacOS/Search
fi

if ask "Disable Spotlight indexing for any volume that gets mounted and has not yet been indexed before." N; then
  # Use `sudo mdutil -i off "/Volumes/foo"` to stop indexing any volume.
  sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"
fi

if ask "Change indexing order and disable some search results" Y; then
  defaults write com.apple.spotlight orderedItems -array \
    '{"enabled" = 1;"name" = "APPLICATIONS";}' \
    '{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
    '{"enabled" = 0;"name" = "DIRECTORIES";}' \
    '{"enabled" = 0;"name" = "PDF";}' \
    '{"enabled" = 0;"name" = "FONTS";}' \
    '{"enabled" = 0;"name" = "DOCUMENTS";}' \
    '{"enabled" = 0;"name" = "MESSAGES";}' \
    '{"enabled" = 0;"name" = "CONTACT";}' \
    '{"enabled" = 0;"name" = "EVENT_TODO";}' \
    '{"enabled" = 0;"name" = "IMAGES";}' \
    '{"enabled" = 0;"name" = "BOOKMARKS";}' \
    '{"enabled" = 0;"name" = "MUSIC";}' \
    '{"enabled" = 0;"name" = "MOVIES";}' \
    '{"enabled" = 0;"name" = "PRESENTATIONS";}' \
    '{"enabled" = 0;"name" = "SPREADSHEETS";}' \
    '{"enabled" = 1;"name" = "SOURCE";}' \
    '{"enabled" = 1;"name" = "MENU_DEFINITION";}' \
    '{"enabled" = 0;"name" = "MENU_OTHER";}' \
    '{"enabled" = 1;"name" = "MENU_CONVERSION";}' \
    '{"enabled" = 1;"name" = "MENU_EXPRESSION";}' \
    '{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
    '{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'
fi

if ask "Load new settings before rebuilding the index" Y; then
  killall mds > /dev/null 2>&1
fi

if ask "Make sure indexing is enabled for the main volume" Y; then
  sudo mdutil -i on / > /dev/null
fi

if ask "Rebuild the index from scratch" Y; then
  sudo mdutil -E / > /dev/null
fi

###############################################################################
# Apple Multitouch Trackpad                                                   #
###############################################################################
if ask "Apple Multitouch trackpad features" Y; then
  defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1
  defaults write com.apple.AppleMultitouchTrackpad DragLock -int 0
  defaults write com.apple.AppleMultitouchTrackpad Dragging -int 0
  defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 1
  defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -int 0
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
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 2
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 2
  defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerDoubleTapGesture -int 1
  defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 3
  defaults write com.apple.AppleMultitouchTrackpad USBMouseStopsTrackpad -int 0
  defaults write com.apple.AppleMultitouchTrackpad UserPreferences -int 1
fi

###############################################################################
# Terminal                                                                    #
###############################################################################

if ask "New window opens in the same directory as the current window" Y; then
  defaults write com.apple.Terminal NewWindowWorkingDirectoryBehavior -int 2
fi

if ask "Disable Secure Keyboard Entry in Terminal.app" Y; then
  # (see: https://security.stackexchange.com/a/47786/8918)
  defaults write com.apple.Terminal SecureKeyboardEntry -bool false
  defaults write com.apple.Terminal Shell -string ""
  defaults write com.apple.Terminal "Default Window Settings" -string Basic
  defaults write com.apple.Terminal "Startup Window Settings" -string Basic
fi

# Note: To print the values, use this:
# /usr/libexec/PlistBuddy -c "Print :'Window Settings':Basic" ~/Library/Preferences/com.apple.Terminal.plist
profile_array=(Basic Pro)
for profile in ${profile_array[*]}
do
  # Close the window if the shell exited cleanly - TODO: These error out and stop the whole file from being executed - need to fix
  # /usr/libexec/PlistBuddy -c "Delete :'Window Settings':$profile:shellExitAction" ~/Library/Preferences/com.apple.Terminal.plist
  # /usr/libexec/PlistBuddy -c "Add :'Window Settings':$profile:shellExitAction integer 1" ~/Library/Preferences/com.apple.Terminal.plist

  if ask "Set window size in Terminal.app" Y; then
    /usr/libexec/PlistBuddy -c "Delete :'Window Settings':$profile:rowCount" ~/Library/Preferences/com.apple.Terminal.plist
    /usr/libexec/PlistBuddy -c "Add :'Window Settings':$profile:rowCount integer 48" ~/Library/Preferences/com.apple.Terminal.plist
    /usr/libexec/PlistBuddy -c "Delete :'Window Settings':$profile:columnCount" ~/Library/Preferences/com.apple.Terminal.plist
    /usr/libexec/PlistBuddy -c "Add :'Window Settings':$profile:columnCount integer 160" ~/Library/Preferences/com.apple.Terminal.plist
  fi

  if ask "do not close the window if these programs are running" Y; then
    /usr/libexec/PlistBuddy -c "Delete :'Window Settings':$profile:noWarnProcesses" ~/Library/Preferences/com.apple.Terminal.plist
    /usr/libexec/PlistBuddy -c "Add :'Window Settings':$profile:noWarnProcesses array" ~/Library/Preferences/com.apple.Terminal.plist
    /usr/libexec/PlistBuddy -c "Add :'Window Settings':$profile:noWarnProcesses:0:ProcessName string screen" ~/Library/Preferences/com.apple.Terminal.plist
    /usr/libexec/PlistBuddy -c "Add :'Window Settings':$profile:noWarnProcesses:1:ProcessName string tmux" ~/Library/Preferences/com.apple.Terminal.plist
    /usr/libexec/PlistBuddy -c "Add :'Window Settings':$profile:noWarnProcesses:2:ProcessName string rlogin" ~/Library/Preferences/com.apple.Terminal.plist
    /usr/libexec/PlistBuddy -c "Add :'Window Settings':$profile:noWarnProcesses:3:ProcessName string ssh" ~/Library/Preferences/com.apple.Terminal.plist
    /usr/libexec/PlistBuddy -c "Add :'Window Settings':$profile:noWarnProcesses:4:ProcessName string slogin" ~/Library/Preferences/com.apple.Terminal.plist
    /usr/libexec/PlistBuddy -c "Add :'Window Settings':$profile:noWarnProcesses:5:ProcessName string telnet" ~/Library/Preferences/com.apple.Terminal.plist
  fi
done

# Focus follows Mouse
# defaults write com.apple.Terminal FocusFollowsMouse -bool true

###############################################################################
# iTerm 2                                                                     #
###############################################################################

# TODO: Need to set the keyboard overrides for "back/forward 1 word" AND "Jobs to Ignore"
if ask "iTerm2 settings" Y; then
  defaults write com.googlecode.iterm2 AllowClipboardAccess -bool true
  defaults write com.googlecode.iterm2 AppleAntiAliasingThreshold -bool true
  defaults write com.googlecode.iterm2 AppleScrollAnimationEnabled -bool false
  defaults write com.googlecode.iterm2 AppleSmoothFixedFontsSizeThreshold -bool true
  defaults write com.googlecode.iterm2 AppleWindowTabbingMode -string "manual"
  defaults write com.googlecode.iterm2 AutoCommandHistory -bool false
  defaults write com.googlecode.iterm2 CheckTestRelease -bool true
  defaults write com.googlecode.iterm2 DimBackgroundWindows -bool true
  defaults write com.googlecode.iterm2 HideTab -bool false
  defaults write com.googlecode.iterm2 HotkeyMigratedFromSingleToMulti -bool true
  defaults write com.googlecode.iterm2 IRMemory -int 4
  defaults write com.googlecode.iterm2 NSFontPanelAttributes -string "1, 0"
  defaults write com.googlecode.iterm2 NSNavLastRootDirectory -string "${HOME}/Desktop"
  defaults write com.googlecode.iterm2 NSQuotedKeystrokeBinding -string ""
  defaults write com.googlecode.iterm2 NSScrollAnimationEnabled -bool false
  defaults write com.googlecode.iterm2 NSScrollViewShouldScrollUnderTitlebar -bool false
  defaults write com.googlecode.iterm2 NoSyncCommandHistoryHasEverBeenUsed -bool true
  defaults write com.googlecode.iterm2 NoSyncDoNotWarnBeforeMultilinePaste -bool true
  defaults write com.googlecode.iterm2 NoSyncDoNotWarnBeforeMultilinePaste_selection -bool false
  defaults write com.googlecode.iterm2 NoSyncDoNotWarnBeforePastingOneLineEndingInNewlineAtShellPrompt -bool true
  defaults write com.googlecode.iterm2 NoSyncDoNotWarnBeforePastingOneLineEndingInNewlineAtShellPrompt_selection -bool true
  defaults write com.googlecode.iterm2 NoSyncHaveRequestedFullDiskAccess -bool true
  defaults write com.googlecode.iterm2 NoSyncHaveWarnedAboutPasteConfirmationChange -bool true
  defaults write com.googlecode.iterm2 NoSyncPermissionToShowTip -bool true
  defaults write com.googlecode.iterm2 NoSyncSuppressBroadcastInputWarning -bool true
  defaults write com.googlecode.iterm2 NoSyncSuppressBroadcastInputWarning_selection -bool false
  defaults write com.googlecode.iterm2 OnlyWhenMoreTabs -bool false
  defaults write com.googlecode.iterm2 OpenArrangementAtStartup -bool false
  defaults write com.googlecode.iterm2 OpenNoWindowsAtStartup -bool false
  defaults write com.googlecode.iterm2 PromptOnQuit -bool false
  defaults write com.googlecode.iterm2 SUAutomaticallyUpdate -bool true
  defaults write com.googlecode.iterm2 SUEnableAutomaticChecks -bool true
  defaults write com.googlecode.iterm2 SUFeedAlternateAppNameKey -string iTerm;
  defaults write com.googlecode.iterm2 SUFeedURL -string "https://iterm2.com/appcasts/final.xml?shard=69"
  defaults write com.googlecode.iterm2 SUHasLaunchedBefore -bool true
  defaults write com.googlecode.iterm2 SUUpdateRelaunchingMarker -bool false
  defaults write com.googlecode.iterm2 SavePasteHistory -bool false
  defaults write com.googlecode.iterm2 ShowBookmarkName -bool false
  defaults write com.googlecode.iterm2 SplitPaneDimmingAmount -string "0.4070612980769232"
  defaults write com.googlecode.iterm2 StatusBarPosition -integer 1
  defaults write com.googlecode.iterm2 SuppressRestartAnnouncement -bool true
  defaults write com.googlecode.iterm2 TabStyleWithAutomaticOption -integer 4
  defaults write com.googlecode.iterm2 TraditionalVisualBell -bool true
  defaults write com.googlecode.iterm2 UseBorder -bool true
  defaults write com.googlecode.iterm2 WordCharacters -string "/-+\\\\~-integer."
  defaults write com.googlecode.iterm2 findMode_iTerm -bool false
  defaults write com.googlecode.iterm2 kCPKSelectionViewPreferredModeKey -bool false
  defaults write com.googlecode.iterm2 kCPKSelectionViewShowHSBTextFieldsKey -bool false

  # TODO: Need to set up the font settings for Powerline font in iTerm2
  # TODO: Need to set up the "Natural text editing" preset in Profiles > Keys preference pane for iTerm2
  # TODO: Need to set up the status bar layout and prefs in iTerm2

  # Note: To print the values, use this:
  # /usr/libexec/PlistBuddy -c "Print :'New Bookmarks':0:'Jobs to Ignore'" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add :'New Bookmarks' array" ~/Library/Preferences/com.googlecode.iterm2.plist # Note: This is a naive way to ensure that the array is present on newly images OS
  /usr/libexec/PlistBuddy -c "Delete :'New Bookmarks':0:Rows" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add :'New Bookmarks':0:Rows integer 48" ~/Library/Preferences/com.googlecode.iterm2.plist

  /usr/libexec/PlistBuddy -c "Delete :'New Bookmarks':0:Columns" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add :'New Bookmarks':0:Columns integer 160" ~/Library/Preferences/com.googlecode.iterm2.plist

  /usr/libexec/PlistBuddy -c "Delete :'New Bookmarks':0:'Silence Bell'" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add :'New Bookmarks':0:'Silence Bell' bool false" ~/Library/Preferences/com.googlecode.iterm2.plist

  /usr/libexec/PlistBuddy -c "Delete :'New Bookmarks':0:'Unlimited Scrollback'" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add :'New Bookmarks':0:'Unlimited Scrollback' bool true" ~/Library/Preferences/com.googlecode.iterm2.plist

  /usr/libexec/PlistBuddy -c "Delete :'New Bookmarks':0:'Use Cursor Guide'" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add :'New Bookmarks':0:'Use Cursor Guide' bool true" ~/Library/Preferences/com.googlecode.iterm2.plist

  /usr/libexec/PlistBuddy -c "Delete :'New Bookmarks':0:'Visual Bell'" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add :'New Bookmarks':0:'Visual Bell' bool true" ~/Library/Preferences/com.googlecode.iterm2.plist

  /usr/libexec/PlistBuddy -c "Delete :'New Bookmarks':0:'Jobs to Ignore'" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add :'New Bookmarks':0:'Jobs to Ignore' array" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add :'New Bookmarks':0:'Jobs to Ignore':0 string screen" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add :'New Bookmarks':0:'Jobs to Ignore':1 string tmux" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add :'New Bookmarks':0:'Jobs to Ignore':2 string rlogin" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add :'New Bookmarks':0:'Jobs to Ignore':3 string ssh" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add :'New Bookmarks':0:'Jobs to Ignore':4 string slogin" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add :'New Bookmarks':0:'Jobs to Ignore':5 string telnet" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add :'New Bookmarks':0:'Jobs to Ignore':5 string zsh" ~/Library/Preferences/com.googlecode.iterm2.plist

  /usr/libexec/PlistBuddy -c "Delete :'New Bookmarks':0:'Minimum Contrast'" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add :'New Bookmarks':0:'Minimum Contrast' integer 0" ~/Library/Preferences/com.googlecode.iterm2.plist
fi

# TODO: Need to add these - stopping due to time constraints
# {
#     "New Bookmarks" =     (
#                 {
#             // Same level as 'Jobs to Ignore'
#             "Character Encoding" -integer 4;
#             "Mouse Reporting" -integer 1;
#             "Close Sessions On End" -bool true
#             Command -string ""
#             Description -string Default
#             "Flashing Bell" -bool true
#             "Idle Code" -bool false
#             Name -string Default
#             "Non Ascii Font" = "Monaco 12";
#             "Non-ASCII Anti Aliased" = 1;
#             "Normal Font" = "MenloForPowerline-Regular 14";
#             "Option Key Sends" -integer 0
#             "Prompt Before Closing 2" -integer 2
#             "Right Option Key Sends" -integer 0
#             Screen -string "-1"
#             "Scrollback Lines" -integer 0
#             "Send Code When Idle" -bool false
#             "Show Status Bar" = 1;
#             "Sync Title" -bool false
#             Transparency -string "0.1610584549492386"
#             "Use Bold Font" -bool true
#             "Use Bright Bold" -bool true
#             "Use Italic Font" -bool true
#             "Use Non-ASCII Font" -bool false
#             "Window Type" -integer 0
#             "Working Directory" -string "${HOME}"
#         }
#     );
# }



###############################################################################
# Docker                                                                      #
###############################################################################
if ask "Docker settings" Y; then
  defaults write com.docker.docker SUAutomaticallyUpdate -bool true
  defaults write com.docker.docker SUEnableAutomaticChecks -bool true
  defaults write com.docker.docker SUUpdateRelaunchingMarker -bool true
fi


###############################################################################
# ImageOptim                                                                  #
###############################################################################
if ask "ImageOptim settings" Y; then
  defaults write net.pornel.ImageOptim AdvPngLevel -int 5
  defaults write net.pornel.ImageOptim JpegOptimMaxQuality -int 85
  defaults write net.pornel.ImageOptim GuetzliEnabled -bool false
  defaults write net.pornel.ImageOptim PngCrush2Enabled -bool true
  defaults write net.pornel.ImageOptim SvgoEnabled -bool true
  defaults write net.pornel.ImageOptim JpegTranStripAll -bool false
  defaults write net.pornel.ImageOptim JpegTranStripAllSetByGuetzli -bool false
fi

###############################################################################
# The-unarchiver                                                              #
###############################################################################
if ask "The-unarchiver settings" Y; then
  defaults write com.macpaw.site.theunarchiver SUEnableAutomaticChecks -bool true
  defaults write com.macpaw.site.theunarchiver changeDateOfFiles -bool true
  defaults write com.macpaw.site.theunarchiver folderModifiedDate -int 2
  defaults write com.macpaw.site.theunarchiver openExtractedFolder -bool true
  defaults write com.macpaw.site.theunarchiver userAgreedToNewTOSAndPrivacy -bool true
fi



###############################################################################
# Vlc                                                                         #
###############################################################################
if ask "Vlc settings" Y; then
  defaults write org.videolan.vlc.plist AudioEffectSelectedProfile -int 0
  defaults write org.videolan.vlc.plist SUEnableAutomaticChecks -bool true
  defaults write org.videolan.vlc.plist VideoEffectSelectedProfile -int 0
  defaults write org.videolan.vlc.plist language -string auto
fi

###############################################################################
# Zoomus                                                                      #
###############################################################################
if ask "Zoomus settings" Y; then
  defaults write us.zoom.xos BounceApplicationSetting -int 2
  defaults write us.zoom.xos NSInitialToolTipDelay -int 100
  defaults write us.zoom.xos NSQuitAlwaysKeepsWindows -bool false
  defaults write us.zoom.xos kZPSettingShowCodeSnippet -bool true
  defaults write us.zoom.xos kZPSettingShowLinkPreview -bool true
fi

###############################################################################
# Activity Monitor                                                            #
###############################################################################

if ask "Show the main window when launching Activity Monitor" Y; then
  defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
fi

if ask "Visualize CPU usage in the Dock icon" Y; then
  defaults write com.apple.ActivityMonitor IconType -int 5
fi

if ask "Show all processes hierarchically" Y; then
  defaults write com.apple.ActivityMonitor ShowCategory -int 101
fi

if ask "Sort Activity Monitor results by CPU usage" Y; then
  defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
  defaults write com.apple.ActivityMonitor SortDirection -int 0
fi

if ask "default to showing the Memory tab" Y; then
  defaults write com.apple.ActivityMonitor SelectedTab -int 1
fi

###############################################################################
# Photos                                                                      #
###############################################################################

if ask "Prevent Photos from opening automatically when devices are plugged in" Y; then
  defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
fi

###############################################################################
# Software Update                                                             #
###############################################################################
if ask "Automatically check for updates (required for any downloads)" Y; then
  sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled -bool true
fi

if ask "Download updates automatically in the background" Y; then
  sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true
fi

if ask "Install app updates automatically" Y; then
  sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool true
  defaults write com.apple.commerce AutoUpdate -bool true
fi

if ask "Don't Install macos updates automatically" Y; then
  sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool false
fi

if ask "Install system data file updates automatically" Y; then
  sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist ConfigDataInstall -bool true
fi

if ask "Install critical security updates automatically" Y; then
  sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist CriticalUpdateInstall -bool true
fi

if ask "Check for software updates daily, not just once per week" Y; then
  defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
fi


###############################################################################
# Screen                                                                      #
###############################################################################
# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -bool true
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Enable subpixel font rendering on non-Apple LCDs (0=off, 1=light, 2=Medium/flat panel, 3=strong/blurred)
# This is mostly needed for non-Apple displays.
defaults write -g AppleFontSmoothing -int 2

# Enable HiDPI display modes (requires restart)
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true



###############################################################################
# Quick Time Player                                                           #
###############################################################################

# Automatically show Closed Captions (CC) when opening a Movie:
# defaults -currentHost write com.apple.QuickTimePlayerX.plist MGEnableCCAndSubtitlesOnOpen -boolean

###############################################################################
## Spaces                                                                     #
###############################################################################

# When switching applications, switch to respective space
defaults write -g AppleSpacesSwitchOnActivate -bool true


###############################################################################
# Kill affected applications                                                  #
###############################################################################

for app in "Activity Monitor" \
	"Address Book" \
	"Calendar" \
	"cfprefsd" \
	"Contacts" \
	"Dock" \
	"Finder" \
	"Flycut" \
	"Google Chrome Canary" \
	"Google Chrome" \
	"Mail" \
	"Safari" \
	"SizeUp" \
	"Spectacle" \
	"SystemUIServer" \
	"iCal"; do
	killall "${app}" &> /dev/null
done

sudo softwareupdate --schedule ON

echo "Need to manually quit and restart 'Terminal' and 'iTerm' - since one of these might be running this script."
echo "Done. Note that some of these changes require a logout/restart to take effect."
