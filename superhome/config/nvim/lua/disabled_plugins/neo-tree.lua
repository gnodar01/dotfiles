-- https://github.com/nvim-neo-tree/neo-tree.nvim
-- browse the file system

return {
  'nvim-neo-tree/neo-tree.nvim',
  name = 'neo-tree',
  -- tag = '3.31.1',
  branch = 'v3.x',
  enabled = false,
  dependencies = {
    'plenary',
    'web-devicons', -- optional
    -- TODO: move to separate plugin file
    {
      -- https://github.com/MunifTanjim/nui.nvim
      'MunifTanjim/nui.nvim',
      name = 'nui',
      --tag = '0.3.0',
    },
    -- optional image support in preview window: See `# Preview Mode` for more information
    -- 'image',
    -- 'window-picker',
  },
  cmd = 'Neotree',
  keys = {
    { '<Leader>n', ':Neotree reveal<CR>', desc = '[N]eoTree reveal', silent = true },
  },
  config = function()
    -- https://github.com/nvim-neo-tree/neo-tree.nvim/blob/main/lua/neo-tree/defaults.lua
    require('neo-tree').setup({
      popup_border_style = 'double',

      --use_default_mappings = false,

      window = {
        mappings = {
          ['<space>'] = 'none',
          --["<space>"] = {
          --  "toggle_node",
          --  nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
          --},

          ['o'] = 'open',
          ['<cr>'] = 'none',
          ---- ['<cr>'] = { 'open', config = { expand_nested_files = true } }, -- expand nested file takes precedence
          --['<2-LeftMouse>'] = 'open',
          --['<esc>'] = 'cancel', -- close preview or floating neo-tree window
          --['P'] = { 'toggle_preview', config = {
          --  use_float = true,
          --  use_image_nvim = false,
          --  -- title = 'Neo-tree Preview', -- You can define a custom title for the preview floating window.
          --} },
          --['<C-f>'] = { 'scroll_preview', config = {direction = -10} },
          --['<C-b>'] = { 'scroll_preview', config = {direction = 10} },
          --['l'] = 'focus_preview',
          --['S'] = 'open_split',
          ---- ['S'] = 'split_with_window_picker',
          --['s'] = 'open_vsplit',
          ---- ['sr'] = 'open_rightbelow_vs',
          ---- ['sl'] = 'open_leftabove_vs',
          ---- ['s'] = 'vsplit_with_window_picker',
          --['t'] = 'open_tabnew',
          ---- ['<cr>'] = 'open_drop',
          ---- ['t'] = 'open_tab_drop',
          --['w'] = 'open_with_window_picker',
          --['C'] = 'close_node',
          --['z'] = 'close_all_nodes',
          ----['Z'] = 'expand_all_nodes',
          --['R'] = 'refresh',

          ['m'] = { 'show_help', nowait = false, config = { title = 'File Ops', prefix_key = 'm' } },
          ['ma'] = {
            'add',
            -- some commands may take optional config options, see `:h neo-tree-mappings` for details
            config = {
              show_path = 'none', -- 'none', 'relative', 'absolute'
            },
          },
          ['a'] = 'none',
          ['mA'] = 'add_directory', -- also accepts the config.show_path and config.insert_as options.
          ['A'] = 'none',
          ['md'] = 'delete',
          ['d'] = 'none',
          ['mr'] = 'rename',
          ['r'] = 'none',
          ['my'] = 'copy_to_clipboard',
          ['y'] = 'none',
          ['mx'] = 'cut_to_clipboard',
          ['x'] = 'none',
          ['mp'] = 'paste_from_clipboard',
          ['p'] = 'none',
          ['mc'] = 'copy', -- takes text input for destination, also accepts the config.show_path and config.insert_as options
          ['c'] = 'none',
          ['mm'] = 'move', -- takes text input for destination, also accepts the config.show_path and config.insert_as options

          --['e'] = 'toggle_auto_expand_width',
          --['q'] = 'close_window',
          --['?'] = 'show_help',
          --['<'] = 'prev_source',
          --['>'] = 'next_source',
        },
      },

      filesystem = {
        window = {
          mappings = {
            ['<Leader>n'] = 'close_window',

            ['I'] = 'toggle_hidden',
            ['H'] = 'none',

            --['/'] = 'fuzzy_finder',
            --['D'] = 'fuzzy_finder_directory',
            ----['/'] = 'filter_as_you_type', -- this was the default until v1.28
            --['#'] = 'fuzzy_sorter', -- fuzzy sorting using the fzy algorithm
            ---- ['D'] = 'fuzzy_sorter_directory',
            --['f'] = 'filter_on_submit',
            --['<C-x>'] = 'clear_filter',
            --['<bs>'] = 'navigate_up',
            --['.'] = 'set_root',
            --['[g'] = 'prev_git_modified',
            --[']g'] = 'next_git_modified',
            --['i'] = 'show_file_details', -- see `:h neo-tree-file-actions` for options to customize the window.
            --['b'] = 'rename_basename',

            ['s'] = { 'show_help', nowait = false, config = { title = 'Order by', prefix_key = 's' } },
            ['sc'] = { 'order_by_created', nowait = false },
            ['sd'] = { 'order_by_diagnostics', nowait = false },
            ['sg'] = { 'order_by_git_status', nowait = false },
            ['sm'] = { 'order_by_modified', nowait = false },
            ['sn'] = { 'order_by_name', nowait = false },
            ['ss'] = { 'order_by_size', nowait = false },
            ['st'] = { 'order_by_type', nowait = false },
            --['o'] = { 'show_help', nowait=false, config = { title = 'Order by', prefix_key = 'o' }},
            ['oc'] = 'none',
            ['od'] = 'none',
            ['og'] = 'none',
            ['om'] = 'none',
            ['on'] = 'none',
            ['os'] = 'none',
            ['ot'] = 'none',
          },
          fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
            --['<down>'] = 'move_cursor_down',
            --['<C-n>'] = 'move_cursor_down',
            --['<up>'] = 'move_cursor_up',
            --['<C-p>'] = 'move_cursor_up',
            --['<esc>'] = 'close'
          },
        },
      },

      buffers = {
        window = {
          mappings = {
            --['<bs>'] = 'navigate_up',
            --['.'] = 'set_root',
            --['d'] = 'buffer_delete',
            --['bd'] = 'buffer_delete',
            --['i'] = 'show_file_details', -- see `:h neo-tree-file-actions` for options to customize the window.
            --['b'] = 'rename_basename',

            ['s'] = { 'show_help', nowait = false, config = { title = 'Order by', prefix_key = 's' } },
            ['sc'] = { 'order_by_created', nowait = false },
            ['sd'] = { 'order_by_diagnostics', nowait = false },
            ['sm'] = { 'order_by_modified', nowait = false },
            ['sn'] = { 'order_by_name', nowait = false },
            ['ss'] = { 'order_by_size', nowait = false },
            ['st'] = { 'order_by_type', nowait = false },
            --['o'] = { 'show_help', nowait=false, config = { title = 'Order by', prefix_key = 'o' }},
            ['oc'] = 'none',
            ['od'] = 'none',
            ['og'] = 'none',
            ['om'] = 'none',
            ['on'] = 'none',
            ['os'] = 'none',
            ['ot'] = 'none',
          },
        },
      },

      git_status = {
        window = {
          mappings = {
            --['A'] = 'git_add_all',
            --['gu'] = 'git_unstage_file',
            --['ga'] = 'git_add_file',
            --['gr'] = 'git_revert_file',
            --['gc'] = 'git_commit',
            --['gp'] = 'git_push',
            --['gg'] = 'git_commit_and_push',
            --['i'] = 'show_file_details', -- see `:h neo-tree-file-actions` for options to customize the window.
            --['b'] = 'rename_basename',

            ['s'] = { 'show_help', nowait = false, config = { title = 'Order by', prefix_key = 's' } },
            ['sc'] = { 'order_by_created', nowait = false },
            ['sd'] = { 'order_by_diagnostics', nowait = false },
            ['sm'] = { 'order_by_modified', nowait = false },
            ['sn'] = { 'order_by_name', nowait = false },
            ['ss'] = { 'order_by_size', nowait = false },
            ['st'] = { 'order_by_type', nowait = false },
            --['o'] = { 'show_help', nowait=false, config = { title = 'Order by', prefix_key = 'o' }},
            ['oc'] = 'none',
            ['od'] = 'none',
            ['og'] = 'none',
            ['om'] = 'none',
            ['on'] = 'none',
            ['os'] = 'none',
            ['ot'] = 'none',
          },
        },
      },

      document_symbols = {
        window = {
          mappings = {
            --['<cr>'] = 'jump_to_symbol',
            --['o'] = 'jump_to_symbol',
            --['A'] = 'noop', -- also accepts the config.show_path and config.insert_as options.
            --['d'] = 'noop',
            --['y'] = 'noop',
            --['x'] = 'noop',
            --['p'] = 'noop',
            --['c'] = 'noop',
            --['m'] = 'noop',
            --['a'] = 'noop',
            --['/'] = 'filter',
            --['f'] = 'filter_on_submit',
          },
        },
      },
    })
  end,
}
