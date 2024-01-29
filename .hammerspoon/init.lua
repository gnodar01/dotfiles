-- Smart config reload from getting started
-- https://www.hammerspoon.org/go/

hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.grid.GRIDWIDTH = 6
hs.grid.GRIDHEIGHT = 4

require "functions/patch"
require "keys"
require "layout"


