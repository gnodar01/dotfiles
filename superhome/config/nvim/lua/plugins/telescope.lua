-- https://github.com/nvim-telescope/telescope.nvim?tab=readme-ov-file
-- fuzzy find all the things

return {
  'nvim-telescope/telescope.nvim',
  name = 'telescope',
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
        return vim.fn.executable('make') == 1
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
    require('telescope').setup({
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
    })

    -- enable telescope extensions, if installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    -- See `:help telescope.builtin`
    local builtin = require('telescope.builtin')
    local action_state = require('telescope.actions.state')

    -- toggle hidden with <C-h>
    -- https://github.com/nvim-telescope/telescope.nvim/issues/2874#issuecomment-1900967890
    -- TODO: ignore .git, .pixi
    local my_find_files
    my_find_files = function(opts, no_ignore)
      opts = opts or {}
      no_ignore = vim.F.if_nil(no_ignore, false)
      opts.attach_mappings = function(_, map)
        map({ 'n', 'i' }, '<C-h>', function(prompt_bufnr) -- <C-h> to toggle modes
          local prompt = require('telescope.actions.state').get_current_line()
          require('telescope.actions').close(prompt_bufnr)
          no_ignore = not no_ignore
          my_find_files({ default_text = prompt }, no_ignore)
        end, { desc = 'Toggle Hidden' })
        return true
      end

      if no_ignore then
        opts.no_ignore = true
        opts.hidden = true
        opts.prompt_title = 'Find Files <ALL>'
        builtin.find_files(opts)
      else
        opts.prompt_title = 'Find Files'
        builtin.find_files(opts)
      end
    end

    vim.keymap.set('n', '<Leader>ff', function()
      local cwd = vim.fn.getcwd()
      if cwd == vim.fn.getenv('HOME') .. '/Developer/CellProfiler' then
        my_find_files({ cwd = cwd .. '/CellProfiler/src' })
      else
        my_find_files()
      end
    end, { desc = '[F]uzzy Search [F]iles' })
    vim.keymap.set('n', '<Leader>fj', builtin.git_files, { desc = '[F]uzzy Search [J]Git Files' })
    vim.keymap.set('n', '<Leader>fg', function()
      local cwd = vim.fn.getcwd()
      -- I know, not very "portable", but whatever
      if cwd == vim.fn.getenv('HOME') .. '/Developer/CellProfiler' then
        builtin.live_grep({ cwd = cwd .. '/CellProfiler/src' })
      else
        builtin.live_grep()
      end
    end, { desc = '[F]uzzy Search by [G]rep' })
    -- delete buffers in picker
    -- https://github.com/nvim-telescope/telescope.nvim/issues/621#issuecomment-2094652982
    vim.keymap.set('n', '<Leader>fB', function()
      builtin.buffers({
        initial_mode = 'normal',
        attach_mappings = function(prompt_bufnr, map)
          local delete_buf = function()
            local current_picker = action_state.get_current_picker(prompt_bufnr)
            current_picker:delete_selection(function(selection)
              vim.api.nvim_buf_delete(selection.bufnr, { force = true })
            end)
          end

          map('n', '<c-d>', delete_buf)
          return true
        end,
      }, {
        sort_lastused = true,
        sort_mru = true,
        theme = 'dropdown',
      })
    end, { desc = '[F]uzzy Search Delete [B]uffers' })
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
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
        winblend = 10,
        previewer = false,
      }))
    end, { desc = '[ ] Fuzzily search in current buffer' })

    vim.keymap.set('n', '<leader>f/', function()
      builtin.live_grep({
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      })
    end, { desc = '[F]uzzy Search [/] in Open Files' })

    vim.keymap.set('n', '<leader>fn', function()
      builtin.find_files({ cwd = vim.fn.stdpath('config') })
    end, { desc = '[F]uzzy Search [N]eovim files' })

    local function live_grep_with_dirs()
      vim.ui.input({ prompt = 'Search directories (comma-separated): ' }, function(input)
        if input then
          local dirs = {}
          for dir in string.gmatch(input, '([^,]+)') do
            table.insert(dirs, vim.trim(dir))
          end
          builtin.live_grep({ search_dirs = dirs })
        end
      end)
    end

    vim.keymap.set('n', '<Leader>fG', live_grep_with_dirs, { desc = '[F]uzzy Search in dir with [G]rep' })
  end,
}
