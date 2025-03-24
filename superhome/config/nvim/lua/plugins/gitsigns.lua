-- https://github.com/lewis6991/gitsigns.nvim
-- adds git related signs to the gutter, as well as utilities for managing changes

return {
  'lewis6991/gitsigns.nvim',
  name = 'gitsigns',
  -- tag = 'v1.0.1',
  opts = {
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },

    on_attach = function(bufnr)
      local gitsigns = require('gitsigns')

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation
      map('n', ']c', function()
        if vim.wo.diff then
          vim.cmd.normal({ ']c', bang = true })
        else
          gitsigns.nav_hunk('next')
        end
      end, { desc = 'Jump to next git [c]hange' })

      map('n', '[c', function()
        if vim.wo.diff then
          vim.cmd.normal({ '[c', bang = true })
        else
          gitsigns.nav_hunk('prev')
        end
      end, { desc = 'Jump to previous git [c]hange' })

      -- Actions
      -- visual mode
      map('v', '<leader>js', function()
        gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
      end, { desc = 'git [s]tage hunk' })
      map('v', '<leader>jr', function()
        gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
      end, { desc = 'git [r]eset hunk' })
      -- normal mode
      map('n', '<leader>js', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
      map('n', '<leader>jr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
      map('n', '<leader>jS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
      map('n', '<leader>ju', gitsigns.stage_hunk, { desc = 'git [u]ndo stage hunk' })
      map('n', '<leader>jR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
      map('n', '<leader>jp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
      map('n', '<leader>jb', gitsigns.blame_line, { desc = 'git [b]lame line' })
      map('n', '<leader>jd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
      map('n', '<leader>jD', function()
        gitsigns.diffthis('@')
      end, { desc = 'git [D]iff against last commit' })
      -- Toggles
      map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
      map('n', '<leader>tD', gitsigns.preview_hunk_inline, { desc = '[T]oggle git show [D]eleted' })
    end,
  },
}
