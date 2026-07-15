-- shared list of treesitter languages to install
--
-- used by `plugins/treesitter` (installs on startup) and the yadm provisioning
-- script (`.config/yadm/provision.lua`, front-loads the install during bootstrap
-- so the first interactive launch does not download parsers).
--
-- https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
return {
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
