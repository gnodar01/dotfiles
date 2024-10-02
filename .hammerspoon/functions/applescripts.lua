-- stopped working on macOS 15.0, Sequoia
function killNotificationsOld()
    source = "tell application \"System Events\"\n  tell process \"NotificationCenter\"\n    if not (window \"Notification Center\" exists) then return\n    set alertGroups to groups of first UI element of first scroll area of first group of window \"Notification Center\"\n    repeat with aGroup in alertGroups\n      try\n        perform (first action of aGroup whose name contains \"Close\" or name contains \"Clear\")\n      on error errMsg\n        log errMsg\n      end try\n    end repeat\n    return \"\"\n  end tell\nend tell\n"
    print("\n")
    print(source)
    print(hs.osascript.applescript(source))
end

-- found fix to replace above here: https://gist.github.com/lancethomps/a5ac103f334b171f70ce2ff983220b4f
function killNotifications()
    source = "tell application \"System Events\" to tell application process \"NotificationCenter\"\n  try\n    perform (actions of UI elements of UI element 1 of scroll area 1 of group 1 of group 1 of window \"Notification Center\" of application process \"NotificationCenter\" of application \"System Events\" whose name starts with \"Name:Close\" or name starts with \"Name:Clear All\")\n  end try\nend tell"
    hs.osascript.applescript(source)
end

