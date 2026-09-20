local prgs = require('vars/programs')

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = 'SUPER' -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. ' + Q', hl.dsp.exec_cmd(prgs.terminal))
local closeWindowBind = hl.bind(mainMod .. ' + C', hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
hl.bind(
  mainMod .. ' + M',
  hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)
hl.bind(mainMod .. ' + E', hl.dsp.exec_cmd(prgs.fileManager))
hl.bind(mainMod .. ' + V', hl.dsp.window.float({ action = 'toggle' }))
hl.bind(mainMod .. ' + R', hl.dsp.exec_cmd(prgs.menu))
hl.bind(mainMod .. ' + P', hl.dsp.window.pseudo())
hl.bind(mainMod .. ' + A', hl.dsp.layout('togglesplit')) -- dwindle only

-- Move focus with mainMod + vim direction keys
--hl.bind(mainMod .. ' + left', hl.dsp.focus({ direction = 'left' }))
hl.bind(mainMod .. ' + H', hl.dsp.focus({ direction = 'left' }))
hl.bind(mainMod .. ' + L', hl.dsp.focus({ direction = 'right' }))
hl.bind(mainMod .. ' + K', hl.dsp.focus({ direction = 'up' }))
hl.bind(mainMod .. ' + J', hl.dsp.focus({ direction = 'down' }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
  local key = i % 10 -- 10 maps to key 0
  hl.bind(mainMod .. ' + ' .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. ' + SHIFT + ' .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. ' + S', hl.dsp.workspace.toggle_special('scratch'))
hl.bind(mainMod .. ' + SHIFT + S', hl.dsp.window.move({ workspace = 'special:scratch' }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. ' + mouse_down', hl.dsp.focus({ workspace = 'e+1' }))
hl.bind(mainMod .. ' + mouse_up', hl.dsp.focus({ workspace = 'e-1' }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. ' + mouse:272', hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. ' + mouse:273', hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
  'XF86AudioRaiseVolume',
  hl.dsp.exec_cmd('wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+'),
  { locked = true, repeating = true }
)
hl.bind(
  'XF86AudioLowerVolume',
  hl.dsp.exec_cmd('wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-'),
  { locked = true, repeating = true }
)
hl.bind(
  'XF86AudioMute',
  hl.dsp.exec_cmd('wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'),
  { locked = true, repeating = true }
)
hl.bind(
  'XF86AudioMicMute',
  hl.dsp.exec_cmd('wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle'),
  { locked = true, repeating = true }
)
hl.bind('XF86MonBrightnessUp', hl.dsp.exec_cmd('brightnessctl -e4 -n2 set 5%+'), { locked = true, repeating = true })
hl.bind('XF86MonBrightnessDown', hl.dsp.exec_cmd('brightnessctl -e4 -n2 set 5%-'), { locked = true, repeating = true })

-- Requires playerctl
hl.bind('XF86AudioNext', hl.dsp.exec_cmd('playerctl next'), { locked = true })
hl.bind('XF86AudioPause', hl.dsp.exec_cmd('playerctl play-pause'), { locked = true })
hl.bind('XF86AudioPlay', hl.dsp.exec_cmd('playerctl play-pause'), { locked = true })
hl.bind('XF86AudioPrev', hl.dsp.exec_cmd('playerctl previous'), { locked = true })

-- TODO: EXTRAS UNTIL THIS IS MOVED AND ORGANIZED

-- https://wiki.hypr.land/configuring/code-snippets/#windows-magnifier-like-cursor-zoom
local MAX_ZOOM = 3
local MIN_ZOOM = 1
local ZOOM_TOGGLE_FACTOR = 1.5

---@param offset number
---@return nil
local function zoom(offset)
  local current = hl.get_config('cursor.zoom_factor')
  if offset ~= nil then
    current = current + offset
  elseif current ~= MIN_ZOOM then
    current = MIN_ZOOM
  else
    current = ZOOM_TOGGLE_FACTOR
  end
  current = math.max(MIN_ZOOM, math.min(MAX_ZOOM, current))
  hl.config({ cursor = { zoom_factor = current } })
end

hl.bind('SUPER + ALT + 8', zoom)
