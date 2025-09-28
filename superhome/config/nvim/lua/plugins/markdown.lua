return {
  -- https://github.com/MeanderingProgrammer/render-markdown.nvim
  -- Improve markdown files.
  --
  'MeanderingProgrammer/render-markdown.nvim',
  name = 'render-markdown',
  -- tag = 'v8.7.0',
  -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
  -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  config = function()
    require('render-markdown').setup({})
  end,
}
