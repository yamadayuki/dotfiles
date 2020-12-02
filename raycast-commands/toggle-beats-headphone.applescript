#!/usr/bin/env osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Beats Headphone
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon ??
# @raycast.packageName Snippets

activate application "SystemUIServer"
tell application "System Events"
  tell process "SystemUIServer"
    set btMenu to (menu bar item 1 of menu bar 1 whose description contains "bluetooth")
    tell btMenu
      click
      tell (menu item "Yuki's Beats Solo3" of menu 1)
        click

        click menu item 1 of menu 1
        return "Connecting..."
      end tell
    end tell
  end tell
end tell
