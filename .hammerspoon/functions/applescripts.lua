function killNotifications()
    source = "tell application \"System Events\"\n  tell process \"NotificationCenter\"\n    if not (window \"Notification Center\" exists) then return\n    set alertGroups to groups of first UI element of first scroll area of first group of window \"Notification Center\"\n    repeat with aGroup in alertGroups\n      try\n        perform (first action of aGroup whose name contains \"Close\" or name contains \"Clear\")\n      on error errMsg\n        log errMsg\n      end try\n    end repeat\n    return \"\"\n  end tell\nend tell\n"
    hs.osascript.applescript(source)
end
