---------------------
---- MY PROGRAMS ----
---------------------

return {
  -- Core applications
  apps = {
    terminal = 'kitty',
    fileManager = 'dolphin',
    menu = '$SUPERHOME/bin/fuzzelpicker',
    statusBar = 'ashell',
  },

  -- Theme configurations (https://reddit.com)
  themes = {
    gtk4 = "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'",
    gtk3 = "gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'",
    qt = {
      env_var = 'QT_QPA_PLATFORMTHEME',
      value = 'qt6ct',
    },
  },
}
