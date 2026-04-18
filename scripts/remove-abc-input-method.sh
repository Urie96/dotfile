#!/usr/bin/env bash

remove-abc-input-method() {
  cd ~/Library/Preferences/ || return
  count=$(/usr/libexec/PlistBuddy -c "Print AppleEnabledInputSources" com.apple.HIToolbox.plist | grep -c "Dict")

  for ((i = 0; i < count; i++)); do
    if [ "$(/usr/libexec/PlistBuddy -c "Print AppleEnabledInputSources:$i:KeyboardLayout\ Name" com.apple.HIToolbox.plist 2>/dev/null)" = "ABC" ]; then

      read -p "Confirm to remove default abc input method?(Y/n)" -n 1 -r choice && echo
      case "$choice" in
      y | Y | '') ;;
      *) return ;;
      esac

      /usr/libexec/PlistBuddy -c "Delete :AppleEnabledInputSources:$i" com.apple.HIToolbox.plist
      return
    fi
  done
}

if [ "$(uname)" = "Darwin" ]; then
  remove-abc-input-method
fi
