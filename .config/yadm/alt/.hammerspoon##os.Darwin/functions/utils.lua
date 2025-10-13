-- Return the first index with the given value (or nil if not found).
function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function getGoodFocusedWindow(nofull)
    local win = hs.window.focusedWindow()
    if not win or not win:isStandard() then return end
    if nofull and win:isFullScreen() then return end
    return win
end

-- this is a niche use case
-- cmd-l in browser to go to address bar
-- esc does not defocus it totatlly
-- clickOut to click bottom interior of window to defocus it
function clickOut()
    local win = getGoodFocusedWindow(true)
    local screen = win:screen()
    if not win then return end
    local currentCursor = hs.mouse.getRelativePosition()
    local clickPoint = win:frame()
    local safePoint = hs.geometry.point(
        clickPoint.x + (clickPoint.w // 2),
        clickPoint.y + clickPoint.h - 5)
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, safePoint):post()
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, safePoint):post()
    hs.mouse.setRelativePosition(currentCursor, screen)
end

function flashScreen(screen)
    local flash=hs.canvas.new(screen:fullFrame()):appendElements({
    	action = "fill",
	    fillColor = { alpha = 0.35, red=1},
	    type = "rectangle"})

    flash:show()
    hs.timer.doAfter(.25, function () flash:delete() end)
end 

