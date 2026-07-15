-- https://github.com/nvim-treesitter/nvim-treesitter
-- highlight, edit, and navigate code

-- https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
-- the language list is shared with the yadm provisioning script so both install
-- the exact same set; see `lua/config/ts-langs.lua`
local langs = require('config/ts-langs')

return {
  'nvim-treesitter/nvim-treesitter',
  --tag = 'v0.9.3',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  enabled = true,
  config = function()
    local TS = require('nvim-treesitter')
    TS.setup({
      -- directory to install parsers and queries to (prepended to `runtimepath` to have priority)
      install_dir = vim.fn.stdpath('data') .. '/site',
    })
    -- this is a no-op if parsers are already installed
    -- runs async
    TS.install(langs)

    for _, lang in pairs(langs) do
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { lang },
        callback = function()
          vim.treesitter.start()
        end,
      })
    end
  end,
}
