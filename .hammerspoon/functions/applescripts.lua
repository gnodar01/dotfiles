-- stopped working on macOS 15.0, Sequoia
function killNotificationsSonomaMinus()
    local source = "tell application \"System Events\"\n  tell process \"NotificationCenter\"\n    if not (window \"Notification Center\" exists) then return\n    set alertGroups to groups of first UI element of first scroll area of first group of window \"Notification Center\"\n    repeat with aGroup in alertGroups\n      try\n        perform (first action of aGroup whose name contains \"Close\" or name contains \"Clear\")\n      on error errMsg\n        log errMsg\n      end try\n    end repeat\n    return \"\"\n  end tell\nend tell\n"
    hs.osascript.applescript(source)
end

-- found fix to replace above here: https://gist.github.com/lancethomps/a5ac103f334b171f70ce2ff983220b4f
-- stopped working on macOS 15.1
function killNotificationsSequoiaPlus()
    local source = "tell application \"System Events\" to tell application process \"NotificationCenter\"\n  try\n    perform (actions of UI elements of UI element 1 of scroll area 1 of group 1 of group 1 of window \"Notification Center\" of application process \"NotificationCenter\" of application \"System Events\" whose name starts with \"Name:Close\" or name starts with \"Name:Clear All\")\n  end try\nend tell"
    hs.osascript.applescript(source)
end

-- found fix to replace above here: https://github.com/Ptujec/LaunchBar/blob/master/Notifications/Dismiss%20all%20notifications.lbaction/Contents/Scripts/default.applescript
-- commenter in the gist from killNotificationsSequouiaPlus (Ptujec)
-- https://gist.github.com/lancethomps/a5ac103f334b171f70ce2ff983220b4f?permalink_comment_id=5235632#gistcomment-5235632
function killNotificationsSequoiaPlusPlus()
    local source = "use AppleScript version \"2.4\" -- Yosemite (10.10) or later\nuse scripting additions\nuse framework \"Foundation\"\nproperty NSArray : a reference to current application's NSArray\nproperty closeActionSet : {\"Close\", \"Clear All\", \"Schließen\", \"Alle entfernen\", \"Cerrar\", \"Borrar todo\", \"关闭\", \"清除全部\", \"Fermer\", \"Tout effacer\", \"Закрыть\", \"Очистить все\", \"إغلاق\", \"مسح الكل\", \"Fechar\", \"Limpar tudo\", \"閉じる\", \"すべてクリア\", \"बंद करें\", \"सभी हटाएं\", \"Zamknij\", \"Wyczyść wszystko\"}\n\non run\n  try\n    \n    tell application \"System Events\"\n      set _headings to UI elements of scroll area 1 of group 1 of group 1 of window 1 of application process \"NotificationCenter\" whose role is \"AXHeading\"\n      set _headingscount to count of _headings\n    end tell\n    \n    repeat _headingscount times\n      tell application \"System Events\" to set _roles to role of UI elements of scroll area 1 of group 1 of group 1 of window 1 of application process \"NotificationCenter\"\n      set _headingIndex to its getIndexOfItem:\"AXHeading\" inList:_roles\n      set _closeButtonIndex to _headingIndex + 1\n      tell application \"System Events\" to click item _closeButtonIndex of UI elements of scroll area 1 of group 1 of group 1 of window 1 of application process \"NotificationCenter\"\n      delay 0.4\n    end repeat\n    \n    tell application \"System Events\"\n      set _buttons to buttons of scroll area 1 of group 1 of group 1 of window 1 of application process \"NotificationCenter\" -- whose subrole is not missing value\n      \n      repeat with _button in _buttons\n        set _actions to actions of first item of _buttons # always picking the first to avoid index error\n        repeat with _action in _actions\n          if description of _action is in closeActionSet then\n            perform _action\n          end if\n        end repeat\n      end repeat\n    end tell\n  on error eStr number eNum\n    display notification eStr with title \"Error \" & eNum sound name \"Frog\"\n  end try\nend run\n\non getIndexOfItem:anItem inList:aList\n  set anArray to NSArray's arrayWithArray:aList\n  set ind to ((anArray's indexOfObject:anItem) as number) + 1\n  if ind is greater than (count of aList) then\n    display dialog \"Item '\" & anItem & \"' not found in list.\" buttons \"OK\" default button \"OK\" with icon 2 with title \"Error\"\n    return 0\n  else\n    return ind\n  end if\nend getIndexOfItem:inList:"
    hs.osascript.applescript(source)
end


function killNotifications()
  local majorVersion = tonumber(
    hs.host.operatingSystemVersion()["major"])

  if majorVersion <= 14 then
    killNotificationsSonomaMinus()
  else
    killNotificationsSequoiaPlusPlus()
  end
end

function runiTermCmd()
   script = [[
        -- Save the current clipboard content
        set originalClipboard to the clipboard

        -- Copy the currently selected/highlighted text or set clipboard to an empty string
        delay 0.5 -- Allow time for the copy operation to complete
        tell application "System Events"
            keystroke "c" using {command down} -- Simulate ⌘C to copy the selection
        end tell
        delay 0.5 -- Allow time for the copy operation to complete

        -- Check if the clipboard changed; if not, set it to an empty string
        set newClipboard to the clipboard
        if newClipboard is equal to originalClipboard then
            set the clipboard to "" -- If clipboard content is unchanged, set it to an empty string
        end if

        tell application "System Events"
            -- Get the name of the frontmost application
            set frontApp to name of first application process whose frontmost is true
        end tell

        tell application "iTerm"
            -- Create a new terminal window
            set newWindow to (create window with default profile command "zsh -c $HOME/superhome/bin/vimclip")
            set newWindowID to id of newWindow
        end tell

        repeat
            delay 1
            tell application "iTerm"
                -- Check if the window with the id still exists
                set windowExists to false
                repeat with aWindow in windows
                    if id of aWindow is equal to newWindowID then
                        set windowExists to true
                        exit repeat
                    end if
                end repeat
            end tell

            -- Exit the loop if the window no longer exists
            if not windowExists then
                exit repeat
            end if
        end repeat

        tell application frontApp
            -- Bring the preivously active application to the foreground
            activate
        end tell

        -- Paste the restored clipboard contents
        tell application "System Events"
            keystroke "v" using {command down} -- Simulate ⌘V to paste
        end tell
    ]]
    hs.osascript.applescript(script)
end

