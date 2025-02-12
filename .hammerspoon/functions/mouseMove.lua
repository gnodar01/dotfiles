-- Move the mouse by some fraction of the screen dimensions
-- params: table of left,right,up,down as a percent of the screen, [0,1]
-- params.cycle (optional): if present and true, and moving the mouse collides with the screen edge
--                          then wrap around (screen as toroid), else stop at screen edge
-- e.g. move mouse diagonally up and to the left, by 1/5 of the screen width and 1/4 the screen height
--      continue on right/bottom edge if colliding with left/top edge during movement
--      mouse_move{left: 1/5, up: 1/4, cycle: true}
function mouse_move(params)
  -- the screen containing the mouse pointer
  local screen = hs.mouse.getCurrentScreen()
  -- an hs.geometry rect object
  local screenFrame = screen:frame()

  -- relative to top left of current screen
  -- point object
  local mousePos = hs.mouse.getRelativePosition()

  -- calculate movement
  local dx = (params.right or 0) * screenFrame.w - (params.left or 0) * screenFrame.w
  local dy = (params.down or 0) * screenFrame.h - (params.up or 0) * screenFrame.h

  -- calculate new position
  local newX = mousePos.x + dx
  local newY = mousePos.y + dy

  -- handle wrapping (toroidal movement)
  if params.cycle then
    if newX < 0 then
      newX = screenFrame.w + newX
    elseif newX > screenFrame.w then
      newX = newX - screenFrame.w
    end

    if newY < 0 then
      newY = screenFrame.h + newY
    elseif newY > screenFrame.h then
      newY = newY - screenFrame.h
    end
  else
    -- clamp within screen bounds
    newX = math.max(0, math.min(newX, screenFrame.w))
    newY = math.max(0, math.min(newY, screenFrame.h))
  end

  hs.mouse.setRelativePosition{x = newX, y = newY}
end

-- https://en.wikipedia.org/wiki/Thunk
function thunk_mouse_move(params)
  function thunk()
    mouse_move(params)
  end
  return thunk
end

