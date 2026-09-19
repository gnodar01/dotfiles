-- Theme configurations (https://reddit.com)
return {
  gtk4 = "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'",
  gtk3 = "gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'",
  qt = {
    env_var = 'QT_QPA_PLATFORMTHEME',
    value = 'qt6ct',
  },
}
