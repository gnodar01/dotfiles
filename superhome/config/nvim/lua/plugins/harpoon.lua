-- https://github.com/ThePrimeagen/harpoon/tree/harpoon2
-- which is a branch of
-- https://github.com/ThePrimeagen
-- quick file navigation

return {
  'ThePrimeagen/harpoon',
  name = 'harpoon',
  branch = 'harpoon2',
  dependencies = {
    'plenary',
    'telescope',
  },
  config = function()
    local harpoon = require('harpoon')
    -- note it is a method (`:`) not function (`.`)
    -- passed in arg is partial config, merged
    harpoon:setup({
      settings = {
        save_on_toggle = true,
        save_on_ui_close = true,
      },
    })

    vim.keymap.set('n', '<Leader>ha', function()
      harpoon:list():add()
    end, { desc = '[A]dd to harpoon list' })
    vim.keymap.set('n', '<Leader>hm', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = 'Quick [M]enu' })

    vim.keymap.set('n', '<Leader>ho', function()
      harpoon:list():select(1)
    end, { desc = 'Select [O]ne' })
    vim.keymap.set('n', '<Leader>hw', function()
      harpoon:list():select(2)
    end, { desc = 'Select T[W]o' })
    vim.keymap.set('n', '<Leader>ht', function()
      harpoon:list():select(3)
    end, { desc = 'Select [T]hree' })
    vim.keymap.set('n', '<Leader>hf', function()
      harpoon:list():select(4)
    end, { desc = 'Select [F]our' })

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set('n', '<Leader>hn', function()
      harpoon:list():prev()
    end, { desc = '[P]revious' })
    vim.keymap.set('n', '<Leader>hp', function()
      harpoon:list():next()
    end, { desc = '[N]ext' })

    -- setup telescope as UI

    local conf = require('telescope.config').values
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require('telescope.pickers')
        .new({}, {
          prompt_title = 'Harpoon',
          finder = require('telescope.finders').new_table({
            results = file_paths,
          }),
          previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
        })
        :find()
    end

    vim.keymap.set('n', '<Leader>hh', function()
      toggle_telescope(harpoon:list())
    end, { desc = 'Open harpoon window' })
  end,
}
