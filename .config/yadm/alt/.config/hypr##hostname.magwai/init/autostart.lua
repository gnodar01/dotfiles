local prgs = require('vars/programs')
local themes = require('vars/themes')

-------------------
---- AUTOSTART ----
-------------------

-- See https://hypr.land

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
hl.on('hyprland.start', function()
  -- System services
  hl.exec_cmd(prgs.authAgent)

  -- Core applications
  hl.exec_cmd(prgs.terminal)
  hl.exec_cmd(prgs.statusBar)
  hl.exec_cmd(prgs.wallPaper)

  -- Apply GTK themes
  hl.exec_cmd(themes.gtk4)
  hl.exec_cmd(themes.gtk3)
end)
