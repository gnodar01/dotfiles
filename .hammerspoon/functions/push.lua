-- https://blog.jverkamp.com/2023/01/23/once-again-to-hammerspoon/

require "functions/patch"
require "functions/utils"

-- Move a window to the given coords
-- params: table of top,left,width, height as a percent of the screen, [0,1]
-- params.window (optional) the window to move, defaults to the focused window
-- e.g. focused window on right half of screen is {left: 1/2, width: 1/2}
function push(params)
  -- https://www.hammerspoon.org/docs/hs.window.html
  local window = params["window"] or hs.window.focusedWindow()

  --print(window:application():name() .. "::" .. window:title())

  -- https://www.hammerspoon.org/docs/hs.geometry.html#rect
  local windowFrame = window:frame()
  -- https://www.hammerspoon.org/docs/hs.screen.html
  local screen = window:screen()
  local screenFrame = screen:frame()

  local moved = false
  function cas(old, new)
    if old ~= new then
      moved = true
    end
    return new
  end

  windowFrame.x = cas(windowFrame.x, screenFrame.x + (screenFrame.w * (params["left"] or 0)))
  windowFrame.y = cas(windowFrame.y, screenFrame.y + (screenFrame.h * (params["top"] or 0)))
  windowFrame.w = cas(windowFrame.w, screenFrame.w * (params["width"] or 1))
  windowFrame.h = cas(windowFrame.h, screenFrame.h * (params["height"] or 1))

  window:setFrameInScreenBounds(windowFrame, 0)

  return moved
end

-- https://en.wikipedia.org/wiki/Thunk
function thunk_push(params)
  function thunk()
    push(params)
  end
  return thunk
end

function push_win(dir)
  local window = hs.window.focusedWindow()
  local screen = window:screen()

  -- compute the unitRect of the focused window relative to the current screen
  -- and move the window to the screen setting the same unitRect

  if dir == "next" then
    window:move(window:frame():toUnitRect(screen:frame()), screen:next(), true, 0)
  elseif dir == "prev" then
    window:move(window:frame():toUnitRect(screen:frame()), screen:previous(), true, 0)
  end
end

function thunk_push_win(dir)
  function thunk()
    push_win(dir)
  end
  return thunk
end

-- broken on macOS 14.5 with HS 0.9.100
-- issue here: https://github.com/Hammerspoon/hammerspoon/issues/3636
-- PR here: https://github.com/Hammerspoon/hammerspoon/pull/3638
-- pre-release build here: https://github.com/Hammerspoon/hammerspoon/pull/3638#issuecomment-2195783259
-- UPDATE: now fixed in release 1.0.0
-- UPDATE: now broken again in Sanoma, probably permanently
function push_space_broken(dir)
    local window = hs.window.focusedWindow()
    local windowId = window:id()
    local screen = window:screen()
    local screenId = screen:getUUID()
    local spaceId = hs.spaces.focusedSpace()
    local allScreenSpaces = hs.spaces.allSpaces()[screenId]
    local spaceIdx = indexOf(allScreenSpaces, spaceId)
    local nextIdx
    if dir == "right" then
        if spaceIdx >= #allScreenSpaces then
            nextIdx = 1
        else
            nextIdx = spaceIdx + 1
        end
    elseif dir == "left" then
        if spaceIdx <= 1 then
            nextIdx = #allScreenSpaces
        else
            nextIdx = spaceIdx - 1
        end
    end
    local nextSpaceId = allScreenSpaces[nextIdx]
    hs.spaces.moveWindowToSpace(windowId, nextSpaceId)
    --hs.spaces.gotoSpace(nextSpaceId)
    if dir == "right" then
        hs.eventtap.keyStroke({"option"},"l",0)
    elseif dir == "left" then
        hs.eventtap.keyStroke({"option"},"h",0)
    end

    -- get focus back
    window:focus()
end

-- https://gist.github.com/jdtsmith/8f08cf22a7177884b437cd25c0fba7d5
function switchSpace(skip, dir)
    local indicate = nil
    if dir == "left" then
        indicate = "h"
    elseif dir == "right" then
        indicate = "l"
    end

    for i = 1, skip do
        hs.eventtap.keyStroke({"option"}, indicate, 0)
    end
end

function push_space(dir, switch)
    local win = getGoodFocusedWindow(true)
    if not win then return end
    local screen = win:screen()
    local uuid = screen:getUUID()
    local userSpaces = nil
    
    for k,v in pairs(hs.spaces.allSpaces()) do
        userSpaces = v
        if k == uuid then break end
    end

    if not userSpaces then return end

    for i, spc in ipairs(userSpaces) do
        if hs.spaces.spaceType(spc) ~= "user" then -- skippable space
            table.remove(userSpaces, i)
        end
    end

    if not userSpaces then return end

    local initialSpace = hs.spaces.windowSpaces(win)
    if not initialSpace then return else initialSpace = initialSpace[1] end
    local currentCursor = hs.mouse.getRelativePosition()

    if (dir == "right" and initialSpace == userSpaces[#userSpaces]) or
       (dir == "left" and initialSpace == userSpaces[1]) then
       flashScreen(screen) -- end of valid spaces
   else
       local zoomPoint = hs.geometry(win:zoomButtonRect())
       local safePoint = zoomPoint:move({-1,-1}).topleft
       hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, safePoint):post()
       switchSpace(1, dir)
       hs.timer.waitUntil(
          function () return hs.spaces.windowSpaces(win)[1] ~= initialSpace end,
          function ()
              hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, safePoint):post()
              hs.mouse.setRelativePosition(currentCursor, screen)
       end, 0.05)
   end
end

function thunk_push_space(dir)
    function thunk()
        push_space(dir)
    end
    return thunk
end

-- cell is hs.geometry.rect
function grid(cell)
  -- https://www.hammerspoon.org/docs/hs.grid.html
  hs.grid.set(hs.window.focusedWindow(), cell)
  return true
end

function thunk_grid(cell)
  function thunk()
    grid(cell)
  end
  return thunk
end

