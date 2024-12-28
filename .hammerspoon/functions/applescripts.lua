-- stopped working on macOS 15.0, Sequoia
function killNotificationsSonomaMinus()
    local source = [[
      tell application "System Events"
        tell process "NotificationCenter"
          if not (window "Notification Center" exists) then return
          set alertGroups to groups of first UI element of first scroll area of first group of window "Notification Center"
          repeat with aGroup in alertGroups
            try
              perform (first action of aGroup whose name contains "Close" or name contains "Clear")
            on error errMsg
              log errMsg
            end try
          end repeat
          return ""
        end tell
      end tell
    ]]
    hs.osascript.applescript(source)
end

-- found fix to replace above here: https://gist.github.com/lancethomps/a5ac103f334b171f70ce2ff983220b4f
-- stopped working on macOS 15.1
function killNotificationsSequoiaPlus()
    local source = [[
      tell application "System Events" to tell application process "NotificationCenter"
        try
          perform (actions of UI elements of UI element 1 of scroll area 1 of group 1 of group 1 of window "Notification Center" of application process "NotificationCenter" of application "System Events" whose name starts with "Name:Close" or name starts with "Name:Clear All")
        end try
      end tell
    ]]
    hs.osascript.applescript(source)
end

-- found fix to replace above here: https://github.com/Ptujec/LaunchBar/blob/master/Notifications/Dismiss%20all%20notifications.lbaction/Contents/Scripts/default.applescript
-- commenter in the gist from killNotificationsSequouiaPlus (Ptujec)
-- https://gist.github.com/lancethomps/a5ac103f334b171f70ce2ff983220b4f?permalink_comment_id=5235632#gistcomment-5235632
function killNotificationsSequoiaPlusPlus()
    local source = [[
      (* 
      Close notifications Applescript Action for LaunchBar
      by Christian Bender (@ptujec)
      2024-10-15

      requires macOS 15.2 

      Copyright see: https://github.com/Ptujec/LaunchBar/blob/master/LICENSE

      Helpful:
      - https://applehelpwriter.com/2016/08/09/applescript-get-item-number-of-list-item/
      - https://www.macscripter.net/t/coerce-gui-scripting-information-into-string/62842/3
      - https://forum.keyboardmaestro.com/t/understanding-applescript-ui-scripting-to-click-menus/29039/23?page=2
      *)

      use AppleScript version "2.4" -- Yosemite (10.10) or later
      use scripting additions
      use framework "Foundation"
      property NSArray : a reference to current application's NSArray
      property alertAndBannerSet : {"AXNotificationCenterAlert", "AXNotificationCenterBanner"}
      property closeActionSet : {"Close", "Clear All", "Schließen", "Alle entfernen", "Cerrar", "Borrar todo", "关闭", "清除全部", "Fermer", "Tout effacer", "Закрыть", "Очистить все", "إغلاق", "مسح الكل", "Fechar", "Limpar tudo", "閉じる", "すべてクリア", "बंद करें", "सभी हटाएं", "Zamknij", "Wyczyść wszystko"}

      on run
        tell application "System Events"
          try
            set _main_group to group 1 of scroll area 1 of group 1 of group 1 of window 1 of application process "NotificationCenter"
          on error eStr number eNum
            display notification eStr with title "Error " & eNum sound name "Frog"
            return
          end try
          
          
          set _headings to UI elements of _main_group whose role is "AXHeading"
          
          set _headingscount to count of _headings
          
          
        end tell
        
        repeat _headingscount times
          tell application "System Events" to set _roles to role of UI elements of _main_group
          set _headingIndex to its getIndexOfItem:"AXHeading" inList:_roles
          set _closeButtonIndex to _headingIndex + 1
          tell application "System Events" to click item _closeButtonIndex of UI elements of _main_group
          delay 0.4
        end repeat
        
        
        tell application "System Events"
          try
            set _groups to groups of _main_group
            if _groups is {} then
              if subrole of _main_group is in alertAndBannerSet then
                set _actions to actions of _main_group
                repeat with _action in _actions
                  if description of _action is in closeActionSet then
                    perform _action
                  end if
                end repeat
              end if
              return
            end if
            
            repeat with _group in _groups
              set _actions to actions of first item of _groups # always picking the first to avoid index error
              repeat with _action in _actions
                if description of _action is in closeActionSet then
                  perform _action
                end if
              end repeat
            end repeat
          on error
            if subrole of _main_group is in alertAndBannerSet then
              set _actions to actions of _main_group
              repeat with _action in _actions
                if description of _action is in closeActionSet then
                  perform _action
                end if
              end repeat
            end if
          end try
        end tell
      end run

      on getIndexOfItem:anItem inList:aList
        set anArray to NSArray's arrayWithArray:aList
        set ind to ((anArray's indexOfObject:anItem) as number) + 1
        if ind is greater than (count of aList) then
          display dialog "Item '" & anItem & "' not found in list." buttons "OK" default button "OK" with icon 2 with title "Error"
          return 0
        else
          return ind
        end if
      end getIndexOfItem:inList:
    ]]
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

