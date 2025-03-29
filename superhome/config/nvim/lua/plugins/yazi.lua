-- https://github.com/mikavilpas/yazi.nvim?tab=readme-ov-file
-- file manager

return {
  'mikavilpas/yazi.nvim',
  --tag = 'v10.0.1'
  -- have to call it yazi.nvim otherwise twice installed
  name = 'yazi.nvim',
  event = 'VeryLazy',
  keys = {
    {
      '<Leader>y.',
      mode = { 'n', 'v' },
      '<Cmd>Yazi<CR>',
      desc = 'Open [Y]azi at Current File[.]',
    },
    {
      '<Leader>yy',
      '<Cmd>Yazi cwd<CR>',
      desc = "Open [Y]azi in Nvim's Current Working Director[y]",
    },
    {
      '<Leader>yl',
      '<Cmd>Yazi toggle<CR>',
      desc = "Resume [Y]azi's [L]ast session",
    },
  },
  opts = {
    -- open Yazi instead of netrw
    open_for_directories = true,
    keymaps = {
      show_help = '~',
      grep_in_directory = '<c-/>',
    },
  },
  init = function()
    -- Block netrw plugin load
    -- https://github.com/mikavilpas/yazi.nvim/issues/802
    vim.g.loaded_netrwPlugin = 1
  end,
}
