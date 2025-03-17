-- https://github.com/nvim-telescope/telescope.nvim?tab=readme-ov-file
-- fuzzy find all the things

return {
  'nvim-telescope/telescope.nvim',
  name = "telescope",
  tag = '0.1.8',
  event = 'VimEnter',
  dependencies = {
    'plenary',
    'web-devicons',
    {
      -- https://github.com/nvim-telescope/telescope-fzf-native.nvim
      'nvim-telescope/telescope-fzf-native.nvim',
      -- extension name is "fzf"
      name = 'telescope-fzf-native',
      -- never tried this, but its another way to build on mac
      -- https://github.com/nvim-telescope/telescope-fzf-native.nvim?tab=readme-ov-file#cmake-windows-linux-macos
      -- build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release'
      -- https://github.com/nvim-telescope/telescope-fzf-native.nvim?tab=readme-ov-file#make-linux-macos-windows-with-mingw
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    {
      -- https://github.com/nvim-telescope/telescope-ui-select.nvim
      'nvim-telescope/telescope-ui-select.nvim',
      -- extension name is "ui-select"
      name = 'telescope-ui-select',
    },
  },
  -- Help:
  --  :help telescope
  --  :help telescope.setup()
  -- Two important keymaps:
  --  - Insert mode: <c-/>
  --  - Normal mode: ?
  --  Opens a window showing all keymaps for current telescope picker
  config = function()
    require('telescope').setup {
      -- default mappings / updates / etc. here
      -- e.g.
      -- defaults = {
      --   mappings = {
      --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
      --   },
      -- },
      -- pickers = {},
      extensions = {
        -- fzf = {},
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    -- enable telescope extensions, if installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    -- See `:help telescope.builtin`
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<Leader>ff', builtin.find_files, { desc = '[F]uzzy Search [F]iles' })
    vim.keymap.set('n', '<Leader>fg', builtin.live_grep, { desc = '[F]uzzy Search by [G]rep' })
    vim.keymap.set('n', '<Leader>fb', builtin.buffers, { desc = '[F]uzzy Search existing [B]uffers' })
    -- :Telescope help_tags
    vim.keymap.set('n', '<Leader>fh', builtin.help_tags, { desc = '[F]uzzy Search [H]elp' })
    vim.keymap.set('n', '<Leader>fk', builtin.keymaps, { desc = '[F]uzzy Search [K]eymaps' })

    vim.keymap.set('n', '<Leader>fs', builtin.builtin, { desc = '[F]uzzy Search [S]elect Telescope' })
    vim.keymap.set('n', '<Leader>fw', builtin.grep_string, { desc = '[F]uzzy Search current [W]ord' })
    vim.keymap.set('n', '<Leader>fd', builtin.diagnostics, { desc = '[F]uzzy Search [D]iagnostics' })
    vim.keymap.set('n', '<Leader>fr', builtin.resume, { desc = '[F]uzzy Search [R]esume' })
    vim.keymap.set('n', '<Leader>f.', builtin.oldfiles, { desc = '[F]uzzy Search Recent Files ("." for repeat)' })

    -- more advanced mappings

    vim.keymap.set('n', '<Leader><Leader>', function()
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[ ] Fuzzily search in current buffer' })

    vim.keymap.set('n', '<leader>f/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[F]uzzy Search [/] in Open Files' })

    vim.keymap.set('n', '<leader>fn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[F]uzzy Search [N]eovim files' })

  end,
}
