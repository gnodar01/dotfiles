local prgs = require('programs')

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env(prgs.themes.qt.env_var, prgs.themes.qt.value)
hl.env('MOZ_ENABLE_WAYLAND', '1')

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env('XCURSOR_SIZE', '24')
hl.env('HYPRCURSOR_SIZE', '24')

-- macOS sets TMPDIR by default; Linux doesn't. kitty.conf (shared via dotfiles)
-- relies on ${TMPDIR} for its remote-control socket path, so set it here to
-- keep that config portable across both platforms.
hl.env('TMPDIR', '/tmp')
-- 1Password ssh agent
hl.env('SSH_AUTH_SOCK', '/home/nodar/.1password/agent.sock')
