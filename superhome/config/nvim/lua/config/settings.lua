-- have Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Terminal settings --

-- NOTE: doesn't work in all teminal emulators/tmux/etc.
-- plus gets in way of <ESC> for terminal vi-mode
--vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
--
-- <C-Esc> somehow works despite the fact <C-[> is already <ESC>
--vim.keymap.set('t', '<C-Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
--
-- this turns out to be awkward
--vim.keymap.set('t', '<C-\\><C-\\>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
--
-- I like this because I'm usually going up to the window above anyway, so just double-tap
vim.keymap.set('t', '<C-k>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
-- inverses above to insert
vim.keymap.set('n', '<C-j>', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local buftype = vim.bo[bufnr].buftype
  if buftype == 'terminal' then
    vim.cmd('startinsert')
  else
    vim.cmd.wincmd('j')
  end
end, { desc = 'Exit terminal mode', silent = true })

local saved_path = nil

-- settings for terminal buffer
vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('nodar-term-open', { clear = true }),
  callback = function()
    -- don't show numbers in terminal
    vim.opt.number = false
    vim.opt.relativenumber = false
    if saved_path then
      vim.api.nvim_chan_send(vim.b.terminal_job_id, 'PATH=' .. '"' .. saved_path .. '" && clear\n')
    end
    saved_path = nil
  end,
})

-- terminal keymaps

vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  callback = function()
    vim.wo.number = true -- show absolute line number
    vim.wo.relativenumber = true -- optional: relative line numbers
    vim.wo.signcolumn = 'yes' -- reserve space for sign column
  end,
})

vim.keymap.set('n', '<Leader>st', function()
  saved_path = vim.env['PATH']
  -- vertical horizontal window
  vim.cmd.new()
  -- put it at bottom (<c-w>J)
  vim.cmd.wincmd('J')
  -- set height to 15
  vim.api.nvim_win_set_height(0, 15)
  -- open a terminal in that new window
  vim.cmd.term()
  -- put in insert mode (<c-\><c-n> to go back to normal mode in terminal)
  vim.api.nvim_feedkeys('i', 'n', true)
end, { desc = 'Open [T]erminal in insert mode' })

vim.keymap.set('n', '<Leader>sT', function()
  local current_win = vim.api.nvim_get_current_win()
  -- vertical horizontal window
  vim.cmd.new()
  -- put it at bottom (<c-w>J)
  vim.cmd.wincmd('J')
  -- set height to 15
  vim.api.nvim_win_set_height(0, 15)
  -- open a terminal in that new window
  vim.cmd.term()
  -- go back to working window
  vim.api.nvim_set_current_win(current_win)
end, { desc = 'Open [T]erminal without focus' })

-- diagnostic keymaps --

vim.keymap.set('n', '<Leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
-- show error message in hover box
vim.keymap.set('n', '<Leader>Q', vim.diagnostic.open_float, { desc = 'Show diagnostics under [Q]cursor' })

vim.g.diagnostic_enable = true
vim.keymap.set('n', '<Leader>td', function()
  vim.g.diagnostic_enable = not vim.g.diagnostic_enable
  vim.diagnostic.enable(vim.g.diagnostic_enable)
end, { desc = '[T]oggle [D]iagnostic' })

-- misc --

-- style winbar
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    local normal = vim.api.nvim_get_hl(0, { name = 'Normal' })
    vim.api.nvim_set_hl(0, 'WinBar', { bg = normal.bg })
    vim.api.nvim_set_hl(0, 'WinBarNC', { bg = normal.bg })
  end,
})

-- for jupytext sync + nbdotrun
vim.keymap.set('n', '<Leader>sw', function()
  local buf = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(buf)

  local keys = vim.api.nvim_replace_termcodes('o.<Esc>k', true, false, true)
  vim.api.nvim_feedkeys(keys, 'n', false)

  -- poll for changes every 500ms up to N times
  local attempts = 0
  local max_attempts = 20
  local last_mtime = nil

  local function poll()
    if vim.uv.fs_stat(filepath).mtime.sec ~= last_mtime then
      -- file was changed externally, trigger checktime manually
      vim.cmd('checktime')
      return
    end

    attempts = attempts + 1
    if attempts < max_attempts then
      vim.defer_fn(poll, 500)
    end
  end

  -- schedule to give time for feedkeys to actully input the keys in buffer
  -- help says its blocking, but it doesn't seem to be
  vim.schedule(function()
    -- save the file
    vim.cmd('w')
    -- set the post-save modified time
    last_mtime = vim.uv.fs_stat(filepath).mtime.sec
    vim.defer_fn(poll, 500)
  end)
end, { desc = '[W]rite and checktime after 1s' })

-- kitty-scrollback.nvim config overrides --
--
-- The kitty kitten launches nvim, appends the plugin to 'runtimepath' and
-- `require`s `kitty-scrollback.launch` from a VimEnter autocmd it registers via
-- `--cmd` (before our init.lua runs). That fires `User KittyScrollbackLaunch`
-- and immediately reads `require('kitty-scrollback').configs`. lazy.nvim defers
-- plugin `init`/`config` until its own (later-registered) VimEnter, so anything
-- routed through the lazy spec runs too late and the launch falls back to
-- builtin defaults (Visual 'darken', cursorline/statusline disabled).
--
-- Registering the autocmd here -- synchronously at startup, before VimEnter --
-- guarantees setup() runs while the kitten is firing the event, so our options
-- actually take effect.
do
  -- No colorscheme loads in the scrollback nvim (colors come from kitty's own
  -- theme via KittyScrollbackNvimNormal), so Visual + CursorLine fall back to
  -- nvim defaults. Set them explicitly to our dracula-soft values so the
  -- selection and the cursorline bar match what we see in a normal nvim.
  local dracula_cursorline = '#33343f'
  local dracula_visual = '#3e4452'
  local overrides = {
    -- false keeps the plugin's laststatus=0, so the (unstyled, since linefly
    -- can't load here) statusline stays hidden for a clean scrollback view
    restore_options = false,
    visual_selection_highlight_mode = 'nvim',
    callbacks = {
      after_ready = function()
        vim.api.nvim_set_hl(0, 'KittyScrollbackNvimVisual', { bg = dracula_visual })
        vim.api.nvim_set_hl(0, 'CursorLine', { bg = dracula_cursorline })
        -- re-enable cursorline (the "horizontal bar") on the scrollback window;
        -- it is disabled window-locally, which a global option can't undo
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == 'kitty-scrollback' then
            vim.wo[win].cursorline = true
          end
        end
      end,
    },
  }
  vim.api.nvim_create_autocmd('User', {
    pattern = 'KittyScrollbackLaunch',
    callback = function()
      require('kitty-scrollback').setup({
        ksb_builtin_last_cmd_output = vim.tbl_extend('force', overrides, {
          kitty_get_text = { extent = 'last_cmd_output' },
        }),
        ksb_builtin_get_text_all = vim.tbl_extend('force', overrides, {
          kitty_get_text = { extent = 'all' },
        }),
        ksb_builtin_last_visited_cmd_output = vim.tbl_extend('force', overrides, {
          kitty_get_text = { extent = 'last_visited_cmd_output' },
        }),
      })
    end,
  })
end
