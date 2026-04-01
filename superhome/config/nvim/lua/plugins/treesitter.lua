-- https://github.com/nvim-treesitter/nvim-treesitter
-- highlight, edit, and navigate code

-- https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
local langs = {
  -- https://github.com/tree-sitter-grammars/tree-sitter-query
  -- TS parser for TS query files (schem-like)
  'query',
  'vim',
  'vimdoc',
  'markdown',
  'markdown_inline',
  'diff',
  'bash',
  'lua',
  'luadoc',
  'c',
  'cpp',
  'python',
  'typescript',
  'javascript',
  'css',
  'html',
  'dockerfile',
  'csv',
  'git_config',
  'git_rebase',
  'gitattributes',
  'gitignore',
  'gitcommit',
  'jinja',
  'jinja_inline',
  --'jq',
  'json',
  --'latex',
  'make',
  'readline',
  'regex',
}

return {
  'nvim-treesitter/nvim-treesitter',
  --tag = 'v0.9.3',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  enabled = true,
  config = function()
    local TS = require('nvim-treesitter')
    TS.setup({
      -- directory to install parsers and queries to (prepended to `runtimepath` to have priority)
      install_dir = vim.fn.stdpath('data') .. '/site',
    })
    -- this is a no-op if parsers are already installed
    -- runs async
    TS.install(langs)
  end,
}
