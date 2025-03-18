return {
	{
		-- https://github.com/williamboman/mason.nvim
		-- package manger for Neovim for LSP, DAP, linters, formatters

		-- `:Mason` for the status window
		{
			"williamboman/mason.nvim",
			--tag = 'v1.11.0',
			-- on rc at time of writing, so v2 proper not out yet
			--tag = 'v2.0.0',
			name = "mason",
			-- `:h mason-settings`
			opts = {
				-- commented out are defaults, unless otherwise noted

				-- can set to DEBUG
				-- log_level = vim.log.levels.INFO,
				-- max_concurrent_installers = 4,
				ui = {
					keymaps = {
						-- expand a package
						--toggle_package_expand = "<CR>",
						-- install the package under the current cursor position
						--install_package = "i",
						-- reinstall/update the package under the current cursor position
						--update_package = "u",
						-- check for new version for the package under the current cursor position
						--check_package_version = "c",
						-- update all installed packages
						--update_all_packages = "U",
						-- check which installed packages are outdated
						--check_outdated_packages = "C",
						-- uninstall a package
						--uninstall_package = "X",
						-- cancel a package installation
						--cancel_installation = "<C-c>",
						-- apply language filter
						--apply_language_filter = "<C-f>",
						-- toggle viewing package installation log
						--toggle_package_install_log = "<CR>",
						-- toggle the help view
						--toggle_help = "g?",
					},
				},
			},
		},
	},
	-- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
	-- install or update third-party tools

	-- To check the current status of installed tools and/or manually install
	-- other tools, run
	--    :Mason
	--
	-- press `g?` for help in this menu.
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		name = "mason-tool-installer",
		dependencies = {
			"mason",
		},
		config = function()
			-- Packages downloaded using `mason-registry`
			-- https://github.com/mason-org/mason-registry
			-- The registry must be downloaded, either automatically on `:MasonInstall`
			-- or manually using `:MasonUpdate`
			local ensure_installed = require("config/mason-pkgs").ensure_installed
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
		end,
	},
	-- https://github.com/stevearc/conform.nvim
	-- formatter plugin
	--
	-- View configured and available formatters
	--   `:ConformInfo`
	-- Help:
	--   `:help conform-formatters`
	{
		"stevearc/conform.nvim",
		name = "conform",
		--tag = 'v9.0.0',
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				-- TODO: where is this triggered?
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		config = function()
			local ext_formatters = require("config/mason-pkgs").ext_formatters
			require("conform").setup({
				notify_on_error = false,
				format_on_save = function(bufnr)
					-- disable "format_on_save lsp_fallback" for languages that don't
					-- have a well standardized coding style
					local disable_filetypes = { c = true, cpp = true }
					local lsp_format_opt
					if disable_filetypes[vim.bo[bufnr].filetype] then
						lsp_format_opt = "never"
					else
						lsp_format_opt = "fallback"
					end
					return {
						timeout_ms = 500,
						lsp_format = lsp_format_opt,
					}
				end,
				formatters_by_ft = ext_formatters,
			})
		end,
	},
}
