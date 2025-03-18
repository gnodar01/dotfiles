return {
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
				"<Leader>F",
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
