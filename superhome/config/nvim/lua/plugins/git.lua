return {
  {
    -- https://github.com/NeogitOrg/neogit
    -- a git interface for neovim, inspired by magit
    'NeogitOrg/neogit',
    -- tag = 'v3.0.0',
    lazy = true,
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      -- 'sindrets/diffview.nvim', -- optional - Diff integration

      -- Only one of these is needed.
      'nvim-telescope/telescope.nvim', -- optional
      -- 'ibhagwan/fzf-lua', -- optional
      -- 'nvim-mini/mini.pick', -- optional
      -- 'folke/snacks.nvim', -- optional
    },
    cmd = 'Neogit',
    keys = {
      { '<Leader>gg', '<cmd>Neogit<cr>', desc = '[G]it Show Neo[G]it UI' },
    },
  },
  -- https://github.com/lewis6991/gitsigns.nvim
  -- adds git related signs to the gutter, as well as utilities for managing changes
  --
  {
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
            ---@diagnostic disable-next-line: param-type-mismatch;w
            gitsigns.nav_hunk('next')
          end
        end, { desc = 'Jump to next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            ---@diagnostic disable-next-line: param-type-mismatch;w
            gitsigns.nav_hunk('prev')
          end
        end, { desc = 'Jump to previous git [c]hange' })

        -- Actions
        -- visual mode
        map('v', '<Leader>gs', function()
          gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = '[G]it [s]tage hunk' })
        map('v', '<Leader>gr', function()
          gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = '[G]it [r]eset hunk' })
        -- normal mode
        map('n', '<Leader>gs', gitsigns.stage_hunk, { desc = '[G]it [s]tage hunk' })
        map('n', '<Leader>gr', gitsigns.reset_hunk, { desc = '[G]it [r]eset hunk' })
        map('n', '<Leader>gS', gitsigns.stage_buffer, { desc = '[G]it [S]tage buffer' })
        map('n', '<Leader>gu', gitsigns.stage_hunk, { desc = '[G]it [u]ndo stage hunk' })
        map('n', '<Leader>gR', gitsigns.reset_buffer, { desc = '[G]it [R]eset buffer' })
        map('n', '<Leader>gp', gitsigns.preview_hunk, { desc = '[G]it [p]review hunk' })
        map('n', '<Leader>gb', gitsigns.blame_line, { desc = '[G]it [b]lame line' })
        map('n', '<Leader>gd', gitsigns.diffthis, { desc = '[G]it [d]iff against index' })
        map('n', '<Leader>gD', function()
          ---@diagnostic disable-next-line: param-type-mismatch;w
          gitsigns.diffthis('@')
        end, { desc = '[G]it [D]iff against last commit' })
        -- Toggles
        map('n', '<Leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
        map('n', '<Leader>tD', gitsigns.preview_hunk_inline, { desc = '[T]oggle git show [D]eleted' })
      end,
    },
  },
}
