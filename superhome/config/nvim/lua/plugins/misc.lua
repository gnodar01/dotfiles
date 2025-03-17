-- misc and small utilities

return {
  -- https://github.com/folke/todo-comments.nvim
  -- Highlight todo, notes, etc in comments
  --
  -- Use quickfix list to show todos
  --   `:TodoQuickFix`
  -- Use location list to show all todos
  --   `:TodoLocList`
  -- Use Telescope to search through todos
  --   `:TodoTelescope`
  {
    'folke/todo-comments.nvim',
    name = 'todo-comments',
    -- tag = 'v1.4.0',
    event = 'VimEnter',
    dependencies = {
      'plenary'
    },
    opts = {
      signs = true,
      keywords = {},
    },
  },
}
