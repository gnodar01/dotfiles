-- Smart config reload from getting started
-- 
-- https://www.hammerspoon.org/go/

hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.grid.GRIDWIDTH = 6
hs.grid.GRIDHEIGHT = 4

require "functions/patch"
require "cheatsheet"
require "keys"
require "layout"


--------------------------------
-- START VIM CONFIG
--------------------------------

-- https://github.com/dbalatero/VimMode.spoon
-- specifically downloaded witht his commit:
-- https://github.com/dbalatero/VimMode.spoon/tree/dda997f79e240a2aebf1929ef7213a1e9db08e97

local VimMode = hs.loadSpoon("VimMode")
local zvim = VimMode:new()

-- Configure apps you do *not* want Vim mode enabled in
-- For example, you don't want this plugin overriding your control of Terminal
-- zvim
zvim
  :disableForApp('Code')
  :disableForApp('zoom.us')
  :disableForApp('iTerm')
  :disableForApp('iTerm2')
  :disableForApp('Terminal')
  :disableForApp('Sublime Text')

zvim:useFallbackMode("Firefox")
zvim:useFallbackMode("Google Chrome")

-- If you want the screen to dim (a la Flux) when you enter normal mode
-- flip this to true.
zvim:shouldDimScreenInNormalMode(false)

-- If you want to show an on-screen alert when you enter normal mode, set
-- this to true
zvim:shouldShowAlertInNormalMode(true)

-- You can configure your on-screen alert font
zvim:setAlertFont("Courier New")

-- Enter normal mode by typing a key sequence
zvim:enterWithSequence('qp')

-- if you want to bind a single key to entering zvim, remove the
-- :enterWithSequence('jk') line above and uncomment the bindHotKeys line
-- below:
--
-- To customize the hot key you want, see the mods and key parameters at:
--   https://www.hammerspoon.org/docs/hs.hotkey.html#bind
--
-- zvim:bindHotKeys({ enter = { {'ctrl'}, ';' } })

--------------------------------
-- END VIM CONFIG
--------------------------------
