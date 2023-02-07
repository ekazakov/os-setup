#!/usr/bin/env bash

#########################################################################################################
# Moom                                                                                                  #
#########################################################################################################

killall Moom &> /dev/null
killall cfprefsd &> /dev/null #disable prefence daemon to reset plist cache

MOOM_CONFIG="com.manytricks.moom.plist"
plutil -convert binary1 -o "${HOME}/Library/Preferences/${MOOM_CONFIG}" "${HOME}/dotfiles/${MOOM_CONFIG}.json"
