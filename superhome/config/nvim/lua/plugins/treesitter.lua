-- https://github.com/nvim-treesitter/nvim-treesitter
-- highlight, edit, and navigate code

-- https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
local langs = {
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
  --'jinja',
  --'jinja_inline',
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
  build = ':TSUpdate',
  main = 'nvim-treesitter.configs', -- sets main module to use for opts
  -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
  opts = {
    ensure_installed = langs,
    -- autoinstall languages that are not installed
    auto_install = true,
    highlight = {
      enable = true,
      -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
      --  If experiencing weird indenting issues, add the language to
      --  the list of additional_vim_regex_highlighting and disabled languages for indent.
      additional_vim_regex_highlighting = { 'ruby' },
    },
    indent = { enable = true, disable = { 'ruby' } },
  },
  -- There are additional nvim-treesitter modules that you can use to interact
  -- with nvim-treesitter.
  --
  --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
  --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
  --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
}
