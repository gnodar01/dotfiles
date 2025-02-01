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
local vim = VimMode:new()

-- Configure apps you do *not* want Vim mode enabled in
-- For example, you don't want this plugin overriding your control of Terminal
-- vim
vim
  :disableForApp('Code')
  :disableForApp('zoom.us')
  :disableForApp('iTerm')
  :disableForApp('iTerm2')
  :disableForApp('Terminal')
  :disableForApp('Sublime Text')

-- If you want the screen to dim (a la Flux) when you enter normal mode
-- flip this to true.
vim:shouldDimScreenInNormalMode(false)

-- If you want to show an on-screen alert when you enter normal mode, set
-- this to true
vim:shouldShowAlertInNormalMode(true)

-- You can configure your on-screen alert font
vim:setAlertFont("Courier New")

-- Enter normal mode by typing a key sequence
vim:enterWithSequence('qp')

-- if you want to bind a single key to entering vim, remove the
-- :enterWithSequence('jk') line above and uncomment the bindHotKeys line
-- below:
--
-- To customize the hot key you want, see the mods and key parameters at:
--   https://www.hammerspoon.org/docs/hs.hotkey.html#bind
--
-- vim:bindHotKeys({ enter = { {'ctrl'}, ';' } })

--------------------------------
-- END VIM CONFIG
--------------------------------
