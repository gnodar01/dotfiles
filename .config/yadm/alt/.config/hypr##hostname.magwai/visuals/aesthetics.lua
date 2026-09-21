-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,

    border_size = 2,

    col = {
      active_border = { colors = { '#8BE9FDEE', '#BD93F9EE' }, angle = 45 },
      inactive_border = '#282A36AA',
    },

    -- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
    allow_tearing = false,
  },

  decoration = {
    rounding = 10,
    rounding_power = 2,

    -- Change transparency of focused and unfocused windows
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    --active_opacity = 0.95,
    --inactive_opacity = 0.85,

    dim_modal = true,

    shadow = {
      enabled = false,
      range = 4,
      render_power = 3,
      color = '#EE1A1A1A',
    },

    blur = {
      enabled = false,
      size = 2,
      passes = 3,
      vibrancy = 0.1696,
      popups = false,
      noise = 0.2,
      xray = false,
    },

    glow = {
      enabled = false,
      range = 10,
    },
  },
})

----------------
----  MISC  ----
----------------

hl.config({
  misc = {
    force_default_wallpaper = -1, -- Set to 0 or 1 to disable the anime mascot wallpapers
    disable_hyprland_logo = true, -- If true disables the random hyprland logo / anime girl background. :(
  },
})
