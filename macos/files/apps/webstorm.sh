#!/usr/bin/env sh

#########################################################################################################
# WebStorm                                                                                              #
#########################################################################################################

if [  -e ~/Library/Preferences/com.jetbrains.WebStorm.plist ]; then
  defaults write com.jetbrains.WebStorm NSUserKeyEquivalents -dict-add "Hide WebStorm" -string "^~@]"
  defaults write com.jetbrains.WebStorm NSUserKeyEquivalents -dict-add "Hide Others" -string "^~@\$]"
  # shellcheck disable=SC2088
  defaults write com.jetbrains.WebStorm NSNavLastRootDirectory -string "~/Workspace"
fi

if [  -e ~/Library/Preferences/com.jetbrains.WebStorm-EAP.plist ]; then
  defaults write com.jetbrains.WebStorm-EAP NSUserKeyEquivalents -dict-add "Hide WebStorm" -string "^~@]"
  defaults write com.jetbrains.WebStorm-EAP NSUserKeyEquivalents -dict-add "Hide Others" -string "^~@\$]"
  # shellcheck disable=SC2088
  defaults write com.jetbrains.WebStorm-EAP NSNavLastRootDirectory -string "~/Workspace";
fi