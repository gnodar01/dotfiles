-- fixes the move + resize together issue
-- https://github.com/Hammerspoon/hammerspoon/issues/3224#issuecomment-1294971600
-- other similar issues:
-- https://github.com/Hammerspoon/hammerspoon/issues/2586
-- https://github.com/Hammerspoon/hammerspoon/issues/2316

require "functions/debug"

function axHotfix(win)
  if not win then win = hs.window.frontmostWindow() end

  local axApp = hs.axuielement.applicationElement(win:application())
  local wasEnhanced = axApp.AXEnhancedUserInterface
  if wasEnhanced then
    axApp.AXEnhancedUserInterface = false
  end

  return function()
    if wasEnhanced then
      axApp.AXEnhancedUserInterface = true
    end
  end
end

function withAxHotfix(fn, position)
  if not position then position = 1 end
  return function(...)
    local args = {...}
    local revert = axHotfix(args[position])
    fn(...)
    revert()
  end
end

local windowMT = hs.getObjectMetatable("hs.window")
windowMT.setFrame = withAxHotfix(windowMT.setFrame)
windowMT.setFrameInScreenBounds = withAxHotfix(windowMT.setFrameInScreenBounds)

