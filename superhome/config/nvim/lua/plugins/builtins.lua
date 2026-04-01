-- https://neovim.io/doc/user/plugins/
return {
  -- https://neovim.io/doc/user/plugins/#_builtin-plugin%3a-undotree
  {
    dir = vim.env.VIMRUNTIME .. '/pack/dist/opt/nvim.undotree',
    lazy = false,
    config = function()
      local undotree = require('undotree')
      vim.keymap.set('n', '<Leader>u', undotree.open, { desc = '[U]ndo tree' })
    end,
  },
}
