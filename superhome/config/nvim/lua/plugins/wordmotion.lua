-- https://github.com/chaoren/vim-wordmotion
-- more useful word motions
-- NOTE: vanilla vim plugin

return {
  'chaoren/vim-wordmotion',
  name = 'wordmotion',
  init = function()
    vim.g.wordmotion_nomap = true
  end,
  config = function()
    vim.keymap.set('n', '<leader>tw', function()
      vim.g.wordmotion_nomap = not vim.g.wordmotion_nomap
      vim.fn['wordmotion#reload']()
    end, { desc = '[T]oggle [W]ordmotion' })
  end,
}
