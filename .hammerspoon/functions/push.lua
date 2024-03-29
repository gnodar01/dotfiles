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

function push_space(dir)
    local window = hs.window.focusedWindow()
    local windowId = window:id()
    local screen = window:screen()
    local screenId = screen:getUUID()
    local spaceId = hs.spaces.focusedSpace()
    local allScreenSpaces = hs.spaces.allSpaces()[screenId]
    local spaceIdx = indexOf(allScreenSpaces, spaceId)
    local nextIdx
    if dir == "left" then
        if spaceIdx >= #allScreenSpaces then
            nextIdx = 1
        else
            nextIdx = spaceIdx + 1
        end
    elseif dir == "right" then
        if spaceIdx <= 1 then
            nextIdx = #allScreenSpaces
        else
            nextIdx = spaceIdx - 1
        end
    end
    local nextSpaceId = allScreenSpaces[nextIdx]
    hs.spaces.moveWindowToSpace(windowId, nextSpaceId)
    --hs.spaces.gotoSpace(nextSpaceId)
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

