-- https://github.com/s1n7ax/nvim-window-picker
-- pick a window to open to in neo-tree

return {
  's1n7ax/nvim-window-picker',
  name = 'window-picker',
  event = 'VeryLazy',
  version = '2.*',
  config = function()
      require'window-picker'.setup({
        filter_rules = {
          include_current_win = false,
          autoselect_one = true,
          -- filter using buffer options
          bo = {
            -- if the file type is one of the following, the window will be ignored
            filetype = { 'neo-tree', 'neo-tree-popup', 'notify' },
            -- if the buffer is one of the following, the window will be ignored
            buftype = { 'terminal', 'quickfix' },
          },
        },
      })
  end,
}
