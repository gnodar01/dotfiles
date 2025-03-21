-- https://github.com/goolord/alpha-nvim
-- spash screen
-- `:help alpha.txt`

return {
  'goolord/alpha-nvim',
  name = 'alpha',
  dependencies = {
    'plenary',
    'web-devicons',
  },
  event = 'VimEnter',
  -- `:Alpha` to open the alpha buffer
  config = function()
    local dashboard = require('alpha.themes.dashboard')
    local splash = require('config/splash')

    dashboard.section.header.opts = splash.header.opts
    dashboard.section.header.type = splash.header.type
    dashboard.section.header.val = splash.header.val

    dashboard.section.buttons.val = {
      dashboard.button('e', '  New file', '<cmd>ene <CR>'),
      dashboard.button('SPC f f', '󰈞  Find file'),
      --dashboard.button("SPC f h", "󰊄  Recently opened files"),
      --dashboard.button("SPC f r", "  Frecency/MRU"),
      --dashboard.button("SPC f g", "󰈬  Find word"),
      --dashboard.button("SPC f m", "  Jump to bookmarks"),
      --dashboard.button("SPC s l", "  Open last session"),
      dashboard.button('q', '󰅚 > Quit NVIM', ':qa<CR>'),
    }
    require('alpha').setup(dashboard.config)
  end,
}
