# nvim config

## Languages

Language tooling is split across a few files, all glued together by
`lua/config/mason-pkgs.lua`, which is the single source of truth for which
LSP servers, formatters, linters, and debug adapters are enabled per
filetype:

- **`lua/config/mason-pkgs.lua`** — defines, per language: the LSP server
  (`lsp_definitions`, name + `nvim-lspconfig` override config), formatters
  (`formatter_definitions`), linters (`linter_definitions`), and DAP
  adapters/configs (`debug_adapters` / `debug_configurations`). Also builds
  the combined `ensure_installed` list consumed by `mason-tool-installer`.
- **`lua/plugins/lsp.lua`** — `nvim-lspconfig` + `mason-lspconfig` glue.
  Reads `lsp_server_configs` from `mason-pkgs.lua`, calls `vim.lsp.config` /
  `vim.lsp.enable` for each server. Also sets up `nvim-cmp` completion and
  LSP keymaps (`gd`, `gr`, `<leader>rn`, `<leader>ca`, etc. — see the
  `LspAttach` autocmd).
- **`lua/plugins/mason.lua`** — `mason.nvim` (package manager) +
  `mason-tool-installer` (auto-installs everything in `ensure_installed` on
  startup; `:Mason` to inspect/manage manually).
- **`lua/plugins/format.lua`** — `conform.nvim`, wired to
  `ft_formatters` / `formatter_settings`. Formats on save (except
  `c`/`cpp`/`python`, which are LSP-fallback-disabled); manual format via
  `<leader>F`. `:ConformInfo` to inspect.
- **`lua/plugins/lint.lua`** — `nvim-lint`, wired to `ft_linters` /
  `linter_settings`. Runs on `BufEnter` / `BufWritePost` / `InsertLeave`.
- **`lua/plugins/debug.lua`** — `nvim-dap` + `nvim-dap-ui`, adapters/configs
  merged in from `mason-pkgs.lua`. Keymaps under `<leader>d*`.
- **`lua/plugins/treesitter.lua`** + **`lua/config/ts-langs.lua`** —
  treesitter parser list, installed on startup (also front-loaded by the
  yadm provisioning script so it's ready on first launch).

### Adding a new language

1. Add the parser name to `lua/config/ts-langs.lua`.
2. Add an entry to `lsp_definitions` in `mason-pkgs.lua` (Mason package name
   under `install`, `nvim-lspconfig` overrides under `config`).
3. Add filetype entries to `formatter_definitions` / `linter_definitions` if
   applicable.
4. Add a DAP adapter/config to `debug_adapters` / `debug_configurations` if
   the language needs debugging.
5. Restart Neovim (or `:MasonToolsInstall`) — everything in
   `ensure_installed` installs automatically.

### Per-project LSP settings (e.g. Lua stubs)

Some projects ship pre-generated Lua type stubs for their APIs — e.g.
Hyprland puts its config stubs at `/usr/share/hypr/stubs/`. `lua_ls` (and
most LSPs) support project-local config that's merged on top of the global
settings from `mason-pkgs.lua`, keyed off files at the project root.

For `lua_ls`, drop a `.luarc.json` in the project root:

```json
{
  "workspace": {
    "library": ["/usr/share/hypr/stubs"],
    "checkThirdParty": false
  }
}
```

Its presence also makes `lua_ls` treat that directory as the LSP root
(see `root_markers` in `nvim-lspconfig`'s `lua_ls.lua`). Open a file in the
project (or `:LspRestart`) and the stub types become available for
completion/diagnostics.

For other servers, check `:help lspconfig-<server>` for its `root_markers`
and settings schema — the same pattern (a config file at the project root)
is common (e.g. `pyrightconfig.json` / `pyproject.toml` for `pyright`, see
`root_markers` in `mason-pkgs.lua`'s `pyright` entry).
