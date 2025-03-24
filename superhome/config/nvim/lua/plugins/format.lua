return {
  -- https://github.com/stevearc/conform.nvim
  -- formatter plugin
  --
  -- View configured and available formatters
  --   `:ConformInfo`
  -- Help:
  --   `:help conform-formatters`
  {
    'stevearc/conform.nvim',
    name = 'conform',
    --tag = 'v9.0.0',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<Leader>F',
        function()
          require('conform').format({ async = true, lsp_format = 'fallback' })
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    config = function()
      local ft_formatters = require('config/mason-pkgs').ft_formatters
      local formatter_settings = require('config/mason-pkgs').formatter_settings
      local conform = require('conform')

      -- TODO: per-project settings?
      conform.setup({
        notify_on_error = false,
        format_on_save = function(bufnr)
          -- disable "format_on_save lsp_fallback" for languages that don't
          -- have a well standardized coding style
          local disable_filetypes = { c = true, cpp = true, python = true }
          local lsp_format_opt
          if disable_filetypes[vim.bo[bufnr].filetype] then
            lsp_format_opt = 'never'
          else
            -- TODO: don't want for cellprofiler (.py) in general
            --lsp_format_opt = 'fallback'
            lsp_format_opt = 'never'
          end
          return {
            timeout_ms = 500,
            lsp_format = lsp_format_opt,
          }
        end,
        -- TODO: same as above
        default_format_opts = { lsp_format = 'never' },
        formatters_by_ft = ft_formatters,
      })

      for fmtr, stgs in pairs(formatter_settings) do
        conform.formatters[fmtr] = stgs
      end
    end,
  },
}
