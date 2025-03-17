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
--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
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
		install = "lua_ls",
		config = {
			-- cmd = { ... },
			-- filetypes = { ... },
			-- capabilities = {},
			settings = {
				Lua = {
					completion = {
						callSnippet = "Replace",
					},
					-- toggle below to ignore Lua_LS's noisy `missing-fields` warnings
					-- diagnostics = { disable = { 'missing-fields' } },
				},
			},
		},
	},
}

-- These go to `mason-lspconfig` in `plugins/lsp`
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
-- `formatter_definitions` is a table of `ext_name` to a list of definitions.
--   The definintion is a list of strings of the formatter names.
--
--   A mapping of `ext_name` to the formatter names goes to `conform`,
--     in the `formatters_by_ft` field
--   A combined list of just the formatter names, goes to `mason-tool-installer`.
--
-- View configured and available formatters
--   `:ConformInfo`
local formatter_definitions = {
	-- https://github.com/JohnnyMorganz/StyLua
	-- Lua language formatter
	lua = { "stylua" },

	-- `conform` can also run multiple formatters sequentially
	-- python = { "isort", "black" },
	--
	-- can use 'stop_after_first' to run the first available formatter from the list
	-- javascript = { "prettierd", "prettier", stop_after_first = true },
}

-- These go to `conform` in the `formatters_by_ft` field.
mason_pkgs.ext_formatters = formatter_definitions

local formatters = {}
for _, frmtrs in pairs(mason_pkgs.ext_formatters) do
	vim.list_extend(formatters, frmtrs)
end

-- These go to `mason-tool-installer` in `plugins/mason`.
mason_pkgs.ensure_installed = {}
for _, data in pairs(lsp_definitions) do
	if data.install then
		table.insert(mason_pkgs.ensure_installed, data.install)
	end
end
vim.list_extend(mason_pkgs.ensure_installed, formatters)

return mason_pkgs
