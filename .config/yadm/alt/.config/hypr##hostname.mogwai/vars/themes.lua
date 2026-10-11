-- Theme configurations (https://reddit.com)
return {
  -- gtk4/libwaita, qt 6.5+, chromium/electron
  color_scheme = "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'",
  -- at least the qt6 implemented "Select what to share" screen (`hyprland-share-picker` via `xdg-desktop-portal-hyprland`)
  -- invoked by OBS Studio needs this for dark mode
  qt = {
    env_var = 'QT_QPA_PLATFORMTHEME',
    value = 'xdgdesktopportal',
  },
}
