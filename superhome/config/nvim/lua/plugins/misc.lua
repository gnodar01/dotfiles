-- misc and small utilities

return {
  -- https://github.com/folke/todo-comments.nvim
  -- Highlight todo, notes, etc in comments
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
