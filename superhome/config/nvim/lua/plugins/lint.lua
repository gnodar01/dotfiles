return {
  -- https://github.com/mfussenegger/nvim-lint
  -- async linter plugin
  {
    'mfussenegger/nvim-lint',
    name = 'nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local ft_linters = require('config/mason-pkgs').ft_linters
      local linter_settings = require('config/mason-pkgs').linter_settings
      local lint = require('lint')
      -- get defined linters or if nil, disable `nvim-lint` defaults
      lint.linters_by_ft = ft_linters
        or {
          clojure = nil,
          dockerfile = nil,
          inko = nil,
          janet = nil,
          json = nil,
          markdown = nil,
          rst = nil,
          ruby = nil,
          terraform = nil,
          text = nil,
        }
      for ltr, stgs in pairs(linter_settings) do
        lint.linters[ltr] = vim.tbl_deep_extend('force', {}, lint.linters[ltr], stgs)
      end

      -- create autocommand which carries out the actual linting on the specified events
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that we can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if vim.opt_local.modifiable:get() then
            lint.try_lint()
          end
        end,
      })
    end,
  },
}
