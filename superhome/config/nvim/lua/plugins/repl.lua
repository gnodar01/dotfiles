-- useful:
-- `vim.inspect( some_table )`
-- `vim.tbl_deep_extend("force", {}, defaults, overrides)`
-- `vim.list_extend(lhs, rhs)`
--return {
--  'ii14/neorepl.nvim',
--  config = function()
--    vim.keymap.set('n', '<Leader>L', function()
--      -- get current buffer and window
--      local buf = vim.api.nvim_get_current_buf()
--      local win = vim.api.nvim_get_current_win()
--      -- create a new split for the repl
--      vim.cmd('split')
--      -- spawn repl and set the context to our buffer
--      require('neorepl').new({
--        lang = 'vim',
--        buffer = buf,
--        window = win,
--      })
--      -- resize repl window and make it fixed height
--      vim.cmd('resize 10 | setl winfixheight')
--    end, { desc = 'REP[L]' })
--  end,
--}
return {
  'yarospace/lua-console.nvim',
  --tag = 'v1.2.5',
  lazy = true,
  keys = {
    { '`', desc = '[L]ua-console - toggle' },
    { '<Leader>``', desc = '[L]ua-console - attach to buffer' },
  },
  --opts = {
  --  mappings = {
  --    quit = { '<Leader>Lq', desc = '[L]ua-console - quit' },
  --    eval = { '<Leader>L<CR>', desc = '[L]ua-console - eval' },
  --    eval_buffer = { '<Leader>L<S-CR>', desc = '[L]ua-console - eval whole buffer' },
  --    kill_ps = { '<Leader>LK', desc = '[L]ua-console - kill eval process' },
  --    open = { '<Leader>Lg', desc = '[L]ua-console - open link' },
  --    messages = { '<Leader>Lm', desc = '[L]ua-console - load nvim messages' },
  --    save = { '<Leader>Ls', desc = '[L]ua-console - save' },
  --    load = { '<Leader>Ll', desc = '[L]ua-console - load' },
  --    resize_up = { '<Leader>L<C-Up>', desc = '[L]ua-console - resize up' },
  --    resize_down = { '<Leader>L<C-Down>', desc = '[L]ua-console - resize down' },
  --    help = { '<Leader>L?', desc = '[L]ua-console - help' },
  --  },
  --},
  opts = {},
}
