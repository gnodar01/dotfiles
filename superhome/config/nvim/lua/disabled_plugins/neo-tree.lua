-- https://github.com/nvim-neo-tree/neo-tree.nvim
-- browse the file system

return {
  'nvim-neo-tree/neo-tree.nvim',
  name = 'neo-tree',
  version = '*',
  dependencies = {
    'plenary',
    'web-devicons', -- optional
    -- TODO: move to separate plugin file
    -- https://github.com/MunifTanjim/nui.nvim
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
  },
}

