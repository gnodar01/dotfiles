return {
  -- https://github.com/fladson/vim-kitty
  {
    'fladson/vim-kitty',
    ft = 'kitty',
    -- tag = "v1.5*",
  },
  -- https://github.com/mikesmithgh/kitty-scrollback.nvim
  {
    'mikesmithgh/kitty-scrollback.nvim',
    enabled = true,
    lazy = true,
    cmd = {
      'KittyScrollbackGenerateKittens',
      'KittyScrollbackCheckHealth',
      'KittyScrollbackGenerateCommandLineEditing',
    },
    event = { 'User KittyScrollbackLaunch' },
    -- version = '*', -- latest stable version, may have breaking changes if major version changed
    -- version = '^6.0.0', -- pin major version, include fixes and features that do not have breaking changes
    -- NOTE: the actual launch-time setup() with our option overrides lives in
    -- lua/config/settings.lua, because the kitty kitten reads the configs before
    -- lazy.nvim runs this plugin's config (see comment there). This setup() only
    -- matters for the KittyScrollback* user commands above.
    config = function()
      require('kitty-scrollback').setup()
    end,
  },
}
