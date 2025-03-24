-- https://github.com/swaits/scratch.nvim

return {
  'https://git.sr.ht/~swaits/scratch.nvim',
  lazy = true,
  keys = {
    { '<leader>ss', '<cmd>Scratch<cr>', desc = 'Scratch Buffer', mode = 'n' },
    { '<leader>sS', '<cmd>ScratchSplit<cr>', desc = 'Scratch Buffer (split)', mode = 'n' },
  },
  cmd = {
    'Scratch',
    'ScratchSplit',
  },
  opts = {},
}
