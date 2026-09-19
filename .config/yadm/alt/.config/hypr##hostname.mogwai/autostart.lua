local prgs = require('programs')

-------------------
---- AUTOSTART ----
-------------------

-- See https://hypr.land

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
hl.on('hyprland.start', function()
  -- System services
  hl.exec_cmd('systemctl --user start hyprpolkitagent')

  -- Core applications
  hl.exec_cmd(prgs.apps.terminal)
  hl.exec_cmd(prgs.apps.statusBar)
  hl.exec_cmd('swaybg -i /home/nodar/pictures/a_house_with_a_chair_and_a_bicycle.jpg')

  -- Apply GTK themes
  hl.exec_cmd(prgs.themes.gtk4)
  hl.exec_cmd(prgs.themes.gtk3)
end)
