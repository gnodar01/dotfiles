local mp = require("mp")
local decay_delay = 0.05
local osd_duration = math.max(decay_delay, mp.get_property_number("osd-duration") / 1000)

local fast_speed = 2.0
local slow_speed = 0.5

local function fast_play(table)
	if table == nil or table["event"] == "down" or table["event"] == "repeat" then
		mp.set_property("speed", fast_speed)
		mp.osd_message((">> x%.1f"):format(fast_speed), osd_duration)
	elseif table["event"] == "up" then
		mp.set_property("speed", 1.0)
		mp.osd_message("1.0x", osd_duration)
	end
end

local function slow_play(table)
	if table == nil or table["event"] == "down" or table["event"] == "repeat" then
		mp.set_property("speed", slow_speed)
		mp.osd_message((">> x%.1f"):format(slow_speed), osd_duration)
	elseif table["event"] == "up" then
		mp.set_property("speed", 1.0)
		mp.osd_message("1.0x", osd_duration)
	end
end

mp.add_forced_key_binding("Alt+SPACE", "hold_slow", slow_play, { complex = true, repeatable = false })
mp.add_forced_key_binding("Ctrl+SPACE", "hold_fast", fast_play, { complex = true, repeatable = false })

