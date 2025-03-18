-- used in `plugins/lsp` and `plugins/mason`

local mason_pkgs = {}

-- Enable the following language servers.
--
-- `lsp_definitions` is a list of pairs.
--
-- First item in pair is key `install`, the value of which goes to `mason-tool-installer`.
--   It is the LSP to install.
--
--   It can be a string, which is the name, or table where `[1]` is the name, followed by any of
--   `version` (git tag), `auto_update` (boolean), `condition` (function returning boolean on whether to install)
--
-- Second item in pair is key `config`, the value of which goes to `mason-lspconfig`.
--   It is the override configuration for the LSP.
--
--    Add any additional override configuration in the `config` tables. Available keys are:
--    - cmd (table): Override the default command used to start the server
--    - filetypes (table): Override the default list of associated filetypes for the server
--    - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
--    - settings (table): Override the default settings passed when initializing the server.
local lsp_definitions = {
  -- clangd = { install = 'clangd', config = {} },
  -- gopls = { install = 'gopls', config = {} },
  -- pyright = { install = 'pyright', config = {} },
  -- rust_analyzer = { install = 'rust_analyzer', config = {} },
  -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
  --
  -- Some languages (like typescript) have entire language plugins that can be useful:
  --    https://github.com/pmizio/typescript-tools.nvim
  --
  -- But for many setups, the LSP (`ts_ls`) will work just fine
  -- ts_ls = { install = 'ts_ls', config = {} },

  lua_ls = {
    install = 'lua_ls',
    config = {
      --cmd = { ... },
      --filetypes = { ... },
      --capabilities = {},
      settings = {
        -- https://luals.github.io/wiki/settings/
        Lua = {
          diagnostics = { globals = { 'vim', 'require' } },
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
    config = {
      --  https://microsoft.github.io/pyright/#/settings
      root_dir = function(fname)
        local util = require('lspconfig.util')
        local root_files = {
          'pyrightconfig.json',
          'pyproject.toml',
          'setup.py',
          'setup.cfg',
          'requirements.txt',
          'Pipfile',
          '.git',
        }
        -- some reverser engineering starting at `:help lspconfig-all`
        --   -> pyright section -> `root_dir` -> [g]o to [F]ile
        --   where I just changed the order or root_files
        --   so that pyrightconfig.json is first
        return util.root_pattern(unpack(root_files))(fname)
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
}

-- These go to `nvim-lspconfig` via `mason-lspconfig` in `plugins/lsp`
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
  markdown = { 'vale' },
  text = { 'vale' },
  latex = { 'vale' },
  dockerfile = { 'hadolint' },
  json = { 'jsonlint' },
  sh = { 'shellcheck' },
  python = { 'ruff' },
  lua = { 'luacheck' },
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

-- These go to `mason-tool-installer` in `plugins/mason`.
mason_pkgs.ensure_installed = {}
for _, data in pairs(lsp_definitions) do
  if data.install then
    table.insert(mason_pkgs.ensure_installed, data.install)
  end
end
vim.list_extend(mason_pkgs.ensure_installed, formatters)
vim.list_extend(mason_pkgs.ensure_installed, linters)

return mason_pkgs
