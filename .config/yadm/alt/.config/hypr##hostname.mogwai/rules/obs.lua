hl.window_rule({
  match = { class = 'com.obsproject.Studio' },
  float = true,
})

-- Fallback check for GTK/Portal system dialogs
hl.window_rule({
  match = { title = 'Select .* to share' },
  float = true,
})
