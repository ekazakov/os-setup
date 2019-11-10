#!/usr/bin/env sh

#########################################################################################################
# Moom                                                                                                  #
#########################################################################################################

killall Moom
killall cfprefsd #disable prefence daemon to reset plist cache

MOOM_CONFIG="com.manytricks.moom.plist"
plutil -convert binary1 -o "${HOME}/Library/Preferences/${MOOM_CONFIG}" "${MOOM_CONFIG}.json"
