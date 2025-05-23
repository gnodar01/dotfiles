require('functions/push')
require('functions/mouseMove')
require('functions/mouseListeners')
require('functions/applescripts')
require('functions/utils')

local hyper = { 'ctrl', 'cmd', 'alt' }
local super = { 'cmd', 'alt' }
local suuper = { 'shift', 'cmd', 'alt' }
local layoutSuper = { 'cmd', 'ctrl' }
local layoutSuuper = { 'cmd', 'ctrl', 'shift' }

local glyphs = {
  cmd = '⌘',
  ctrl = '⌃',
  opt = '⌥',
  alt = '⌥',
  shift = '⇧',
}

-- show grid
-- broken because of the move+resize issue and fix wont work
-- see functions/patch.lua
-- hs.hotkey.bind(super, "g", hs.grid.show)

-- show shortcuts
hs.hotkey.bind(layoutSuper, '/', toggleShortcuts)

-- full screens
hs.hotkey.bind(layoutSuper, 'm', thunk_push({ width = 1, height = 1 }))
hs.hotkey.bind(layoutSuper, ',', thunk_push({ top = 1 / 8, left = 1 / 8, width = 3 / 4, height = 3 / 4 }))
hs.hotkey.bind(layoutSuper, 'c', thunk_push({ top = 1 / 4, left = 1 / 4, width = 1 / 2, height = 1 / 2 }))

-- half screens
hs.hotkey.bind(layoutSuper, 'h', thunk_push({ width = 1 / 2 }))
hs.hotkey.bind(layoutSuper, 'l', thunk_push({ left = 1 / 2, width = 1 / 2 }))

-- third screens
hs.hotkey.bind(layoutSuper, 'i', thunk_push({ left = 1 / 6, width = 2 / 3 }))
hs.hotkey.bind(layoutSuper, 'left', thunk_push({ width = 2 / 3 }))
hs.hotkey.bind(layoutSuper, 'right', thunk_push({ width = 2 / 3, left = 1 / 3 }))

hs.hotkey.bind(layoutSuuper, 'left', thunk_push({ width = 1 / 3 }))
hs.hotkey.bind(layoutSuuper, 'right', thunk_push({ width = 1 / 3, left = 2 / 3 }))

hs.hotkey.bind(layoutSuuper, 'u', thunk_push({ top = 0, left = 0, width = 1 / 3, height = 1 / 2 }))
hs.hotkey.bind(layoutSuuper, 'o', thunk_push({ top = 0, left = 2 / 3, width = 1 / 3, height = 1 / 2 }))
hs.hotkey.bind(layoutSuuper, 'n', thunk_push({ top = 1 / 2, left = 0, width = 1 / 3, height = 1 / 2 }))
hs.hotkey.bind(layoutSuuper, '.', thunk_push({ top = 1 / 2, left = 2 / 3, width = 1 / 3, height = 1 / 2 }))

hs.hotkey.bind(layoutSuper, 'u', thunk_push({ top = 0, left = 0, width = 1 / 2, height = 1 / 2 }))
hs.hotkey.bind(layoutSuper, 'o', thunk_push({ top = 0, left = 1 / 2, width = 1 / 2, height = 1 / 2 }))
hs.hotkey.bind(layoutSuper, 'n', thunk_push({ top = 1 / 2, left = 0, width = 1 / 2, height = 1 / 2 }))
hs.hotkey.bind(layoutSuper, '.', thunk_push({ top = 1 / 2, left = 1 / 2, width = 1 / 2, height = 1 / 2 }))

hs.hotkey.bind(layoutSuper, 'w', thunk_push({ top = 0, left = 1 / 4, width = 1 / 2, height = 1 / 2 }))
hs.hotkey.bind(layoutSuper, 'a', thunk_push({ top = 1 / 4, left = 0, width = 1 / 2, height = 1 / 2 }))
hs.hotkey.bind(layoutSuper, 'd', thunk_push({ top = 1 / 4, left = 1 / 2, width = 1 / 2, height = 1 / 2 }))
hs.hotkey.bind(layoutSuper, 's', thunk_push({ top = 1 / 2, left = 1 / 4, width = 1 / 2, height = 1 / 2 }))

hs.hotkey.bind(layoutSuuper, 'w', thunk_push({ top = 0, left = 1 / 3, width = 1 / 3, height = 1 / 2 }))
hs.hotkey.bind(layoutSuuper, 'a', thunk_push({ top = 1 / 4, left = 0, width = 1 / 3, height = 1 / 2 }))
hs.hotkey.bind(layoutSuuper, 'd', thunk_push({ top = 1 / 4, left = 2 / 3, width = 1 / 3, height = 1 / 2 }))
hs.hotkey.bind(layoutSuuper, 's', thunk_push({ top = 1 / 2, left = 1 / 3, width = 1 / 3, height = 1 / 2 }))

-- move screens
hs.hotkey.bind(layoutSuper, 'j', thunk_push_win('next'))
hs.hotkey.bind(layoutSuper, 'k', thunk_push_win('prev'))

-- move spaces
hs.hotkey.bind(layoutSuuper, 'h', thunk_push_space('left'))
hs.hotkey.bind(layoutSuuper, 'l', thunk_push_space('right'))

-- listeners
hs.hotkey.bind(hyper, 'm', function()
  if mouseEventTapUpper:isEnabled() then
    hs.alert.show('Menu Bar 🙄')
    mouseEventTapUpper:stop()
  else
    hs.alert.show('Menu Bar 🪦')
    mouseEventTapUpper:start()
  end
end)

hs.hotkey.bind(hyper, 'd', function()
  if mouseEventTapLower:isEnabled() then
    hs.alert.show('Dock 🙄')
    mouseEventTapLower:stop()
  else
    hs.alert.show('Dock 🪦')
    mouseEventTapLower:start()
  end
end)

hs.hotkey.bind(hyper, 'n', killNotifications)

hs.hotkey.bind(hyper, 'c', function()
  hs.openConsole()
end)

hs.hotkey.bind(hyper, 'l', clickOut)

hs.hotkey.bind(super, 'h', thunk_mouse_move({ left = 1 / 10, cycle = false }))
hs.hotkey.bind(super, 'l', thunk_mouse_move({ right = 1 / 10, cycle = false }))
hs.hotkey.bind(super, 'j', thunk_mouse_move({ down = 1 / 10, cycle = false }))
hs.hotkey.bind(super, 'k', thunk_mouse_move({ up = 1 / 10, cycle = false }))

hs.hotkey.bind(suuper, 'h', thunk_mouse_move({ left = 1 / 100, cycle = false }))
hs.hotkey.bind(suuper, 'l', thunk_mouse_move({ right = 1 / 100, cycle = false }))
hs.hotkey.bind(suuper, 'j', thunk_mouse_move({ down = 1 / 100, cycle = false }))
hs.hotkey.bind(suuper, 'k', thunk_mouse_move({ up = 1 / 100, cycle = false }))

--[[
hs.hotkey.bind(hyper, "z", function()
  n = hs.notify.new()
  n = n:alwaysPresent(true)
  n = n:informativeText("hello")
  n = n:withdrawAfter(60)
  n:send()
end)
--]]

--[[
doScrollTimer = nil

local checkScroll = function()
  hs.eventtap.event.newScrollEvent({0,2},{}, "line"):post()
end

hs.hotkey.bind(hyper, "j", function()
  if doScrollTimer and doScrollTimer:running() then
    print('stopping')
    doScrollTimer:stop()
  else
    print('starting')
    doScrollTimer = hs.timer.doEvery(.1, checkScroll)
  end
  --checkScroll()
end)
]]
--
