-- used in `plugins/lsp` and `plugins/mason`

local mason_pkgs = {}

-- Enable the following language servers.
--
-- `lsp_definitions` is a list of pairs.
--
-- First item in pair is key `install`, the value of which goes to `mason-tool-installer`.
--   It is the LSP to install.
--   `mason-lspconfig` handles translating between `nvim-lspconfig` and `mason.nvim` names
--   (e.g. `lus_ls` <-> `lua-language-server`).
--
--   It can be a string, which is the name, or table where `[1]` is the name, followed by any of
--   `version` (git tag), `auto_update` (boolean), `condition` (function returning boolean on whether to install)
--
-- Second item in pair is key `config`, the value of which goes to native `vim.lsp`.
--   It is the override configuration for the LSP.
--
--    Add any additional override configuration in the `config` tables. Available keys are:
--    - cmd (table): Override the default command used to start the server
--    - filetypes (table): Override the default list of associated filetypes for the server
--    - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
--    - settings (table): Override the default settings passed when initializing the server.
local lsp_definitions = {
  lua_ls = {
    install = 'lua_ls',
    config = {
      --cmd = { ... },
      --filetypes = { ... },
      --capabilities = {},
      settings = {
        -- https://luals.github.io/wiki/settings/
        Lua = {
          diagnostics = { globals = { 'vim', 'hs', 'require' } },
          completion = {
            callSnippet = 'Replace',
          },
          -- toggle below to ignore Lua_LS's noisy `missing-fields` warnings
          -- diagnostics = { disable = { 'missing-fields' } },
        },
      },
    },
  },

  -- TODO: consider switch to basedpyright
  --
  -- https://github.com/microsoft/pyright
  -- Commands:
  --   PyrightOrganizeImports
  --   PyrightSetPythonPath
  pyright = {
    install = 'pyright',
    --  https://microsoft.github.io/pyright/#/settings
    config = {
      -- some reverse engineering starting at `:help lspconfig-all`
      --   -> pyright section -> `root_dir` -> [g]o to [F]ile
      --   where I just changed the order or root_files
      --   so that pyrightconfig.json is first
      root_markers = {
        'pyrightconfig.json',
        'pyproject.toml',
        'setup.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
        '.git',
      },
      -- root_dir takes precedance over root_markers
      -- root_markers will return first directory where any of files match
      -- custom fn in root_dir will return directory of highest precedance file
      root_dir = function(bufnr, cb)
        local dirfile = require('utils/dirfile')

        local found_root = dirfile.find_root({
          'pyrightconfig.json',
          'pyproject.toml',
          'setup.py',
          'setup.cfg',
          'requirements.txt',
          'Pipfile',
          '.git',
        }, bufnr)

        cb(found_root)
      end,
      settings = {
        python = {
          analysis = {
            autoSearchPaths = false,
            diagnosticMode = 'openFilesOnly',
          },
        },
      },
    },
  },

  -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#ts_ls
  -- https://github.com/typescript-language-server/typescript-language-server
  ts_ls = {
    install = 'ts_ls',
    config = {
      settings = {},
    },
  },

  -- https://clangd.llvm.org
  -- https://github.com/clangd/clangd
  -- https://www.lazyvim.org/extras/lang/clangd
  -- https://github.com/p00f/clangd_extensions.nvim
  -- commands:
  --   LspClangdSwitchSourceHeader
  --   LspClangdShowSymbolInfo
  clangd = {
    install = 'clangd',
    config = {
      init_options = {
        fallbackFlags = { '-std=c++20' },
      },
    },
  },
}

-- These go to `nvim-lspconfig` in `plugins/lsp`
mason_pkgs.lsp_server_configs = {}
for name, data in pairs(lsp_definitions) do
  if data.config then
    mason_pkgs.lsp_server_configs[name] = data.config
  end
end

-- Ensure the servers and tools above are installed
--
-- To check the current status of installed tools and/or manually install
-- other tools, run
--    `:Mason`
--
-- press `g?` for help in this menu.
--
-- Add other tools below for Mason to install.
-- Registry:
-- https://mason-registry.dev/registry/list

-- Enable the following formatters.
--
-- `formatter_definitions` is a table of `filetype` to a list of definitions.
--   The definintion is a list of strings of the formatter names.
--
--   A mapping of `filetype` to the formatter names goes to `conform`,
--     in the `formatters_by_ft` field
--   A combined list of just the formatter names, goes to `mason-tool-installer`.
--
-- Get the `filetype` of a buffer
--   `:= vim.bo.filetype`
--
-- View configured and available formatters
--   `:ConformInfo`
local formatter_definitions = {
  -- https://github.com/JohnnyMorganz/StyLua
  -- Lua language formatter
  lua = { 'stylua' },

  -- `conform` can also run multiple formatters sequentially
  -- python = { "isort", "black" },
  --
  -- can use 'stop_after_first' to run the first available formatter from the list
  -- javascript = { "prettierd", "prettier", stop_after_first = true },
  javascript = { 'eslint_d' },
  typescript = { 'eslint_d' },
  json = { 'fixjson' },
  typescriptreact = { 'eslint_d' },
  cpp = { 'clang-format' },
}

-- These go to `conform` to customize defined formatters
--
-- By default, they are automatically *merged*, rather than overwriting in full.
-- To overwrite the entire formatter definition, and *not* merge with the default values,
-- pass `inhert = false`.
--
-- They can be `table` or `function(bufrnr)` that returns a `table`
-- `prepend_args` can also be a `list` or `function(self, ctx)` returning `list`
mason_pkgs.formatter_settings = {
  -- defaults: https://github.com/stevearc/conform.nvim/blob/master/lua/conform/formatters/stylua.lua
  stylua = {
    -- $HOME/.local/share/nvim/mason/bin/stylua --help
    --
    -- quote-style = [AutoPreferSingle | ForceSingle]
    prepend_args = { '--indent-type', 'Spaces', '--indent-width', '2', '--quote-style', 'AutoPreferSingle' },
  },

  eslint_d = {},
}

-- These go to `conform` in the `formatters_by_ft`: field.
mason_pkgs.ft_formatters = formatter_definitions

local formatters = {}
for _, frmtrs in pairs(mason_pkgs.ft_formatters) do
  vim.list_extend(formatters, frmtrs)
end

-- Enable the following linters.
--
-- `linter_definitions` is a table of `filetype` to a list of definitions.
--   The definintion is a list of strings of the linter names.
--
--   A mapping of `filetype` to the linter names goes to `nvim-lint`,
--     in the `linters_by_ft` field
--   A combined list of just the linter names, goes to `mason-tool-installer`.
--
-- A list of supported linters is here:
--   https://github.com/mfussenegger/nvim-lint?tab=readme-ov-file#available-linters
-- But not all available through Mason, so best to just check Mason itself
--
-- Get the `filetype` of a buffer
--   `:= vim.bo.filetype`
--
-- View configured and available lintes
--   `:lua print(require('lint').get_running())`
local linter_definitions = {
  -- TODO: fix vale exited with code 2 error, probably vale.ini needed
  --markdown = { 'vale' },
  --text = { 'vale' },
  --latex = { 'vale' },
  dockerfile = { 'hadolint' },
  json = { 'jsonlint' },
  sh = { 'shellcheck' },
  python = { 'ruff' },
  lua = { 'luacheck' },
  javascript = { 'eslint_d' },
  typescript = { 'eslint_d' },
  typescriptreact = { 'eslint_d' },
}

-- These go to `nvim-lint` to customize defined linters
mason_pkgs.linter_settings = {
  luacheck = {
    args = { '--formatter', 'plain', '--codes', '--ranges', '--globals', 'vim', 'lvim', '-' },
  },
}

-- These go to `nvim-lint` in the `linters_by_ft` field.
mason_pkgs.ft_linters = linter_definitions

local linters = {}
for _, lntrs in pairs(mason_pkgs.ft_linters) do
  vim.list_extend(linters, lntrs)
end

-- tell mason to install these
local debuggers = {
  'debugpy',
  'js-debug-adapter',
}

-- These go to `nvim-dap` via `dap.adapters`
-- setup the debug adapters
-- `:help dap-adapter`
mason_pkgs.debug_adapters = {
  -- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#python
  python = function(cb, config)
    if config.request == 'attach' then
      ---@diagnostic disable-next-line: undefined-field
      local port = (config.connect or config).port
      ---@diagnostic disable-next-line: undefined-field
      local host = (config.connect or config).host or '127.0.0.1'
      cb({
        type = 'server',
        port = assert(port, '`connect.port` is required for a python `attach` configuration'),
        host = host,
        options = {
          source_filetype = 'python',
        },
      })
    else
      cb({
        type = 'executable',
        -- https://github.com/jay-babu/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/adapters/python.lua
        command = vim.fn.exepath('debugpy-adapter'),
        --command = os.getenv('HOME') .. '/.local/share/nvim/mason/bin/debugpy-adapter',
        --command = os.getenv('CONDA_PREFIX') .. '/bin/python',
        --args = { '-m', 'debugpy.adapter' },
      })
    end
  end,

  -- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#javascript-chrome
  ['pwa-chrome'] = {
    type = 'server',
    host = 'localhost',
    port = '${port}',
    executable = {
      command = 'js-debug-adapter',
      args = { '${port}' },
      --command = 'node',
      --args = {
      --  require('mason-registry').get_package('js-debug-adapter'):get_install_path()
      --    .. '/js-debug/src/dapDebugServer.js',
      --  '${port}',
      --},
    },
  },
}
-- not sure if this is needed:
-- mason_pkgs.debug_adapters.debugpy = mason_pkgs.debug_adapters.python

-- steal some logic here for python, especially testing:
-- https://github.com/mfussenegger/nvim-dap-python/tree/master

-- `:help dap-configuration`
mason_pkgs.debug_configurations = {
  python = {
    --{
    --  type = 'python',
    --  request = 'launch',
    --  name = 'Some Launch',
    --},
  },

  javascript = {
    {
      type = 'pwa-chrome',
      request = 'launch',
      name = 'Launch Chrome',
      webRoot = '${workspaceFolder}',
      url = 'http://localhost:3000',
      sourceMaps = true,
    },
  },
}

mason_pkgs.debug_configurations.typescript = mason_pkgs.debug_configurations.javascript
mason_pkgs.debug_configurations.javascriptreact = mason_pkgs.debug_configurations.javascript
mason_pkgs.debug_configurations.typescriptreact = mason_pkgs.debug_configurations.javascript

-- These go to `mason-tool-installer` in `plugins/mason`.
mason_pkgs.ensure_installed = {}
for _, data in pairs(lsp_definitions) do
  if data.install then
    table.insert(mason_pkgs.ensure_installed, data.install)
  end
end
vim.list_extend(mason_pkgs.ensure_installed, formatters)
vim.list_extend(mason_pkgs.ensure_installed, linters)
vim.list_extend(mason_pkgs.ensure_installed, debuggers)

return mason_pkgs
