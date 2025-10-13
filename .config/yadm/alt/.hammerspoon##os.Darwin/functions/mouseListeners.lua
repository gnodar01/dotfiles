-- Toggle Menu Bar
-- https://apple.stackexchange.com/questions/70985/make-the-menu-bar-never-show-while-in-full-screen

mouseEventTapUpper = hs.eventtap.new({hs.eventtap.event.types.mouseMoved}, function(event)
    local th = 15
    local rel = hs.mouse.getRelativePosition()
    local scr = hs.mouse.getCurrentScreen()
    if(rel.y < th and scr:name() ~= "Built-in Retina Display") then
        local frame = scr:fullFrame()
        local abs = event:location()
        abs.y = frame.y + th
        local newEvent = event:copy():location(abs)
        newEvent:post()
        return true
    end
end)
-- mouseEventTapUpper:start()

mouseEventTapLower = hs.eventtap.new({hs.eventtap.event.types.mouseMoved}, function(event)
    local th = 5
    local rel = hs.mouse.getRelativePosition()
    local scr = hs.mouse.getCurrentScreen()
    if (scr:name() == "Built-in Retina Display") then
        local frame = scr:fullFrame()
        if(rel.y > frame.h - th) then
            local abs = event:location()
            abs.y = frame.h - th
            local newEvent = event:copy():location(abs)
            newEvent:post()
            return true
        end
    end
end)
-- mouseEventTapLower:start()


