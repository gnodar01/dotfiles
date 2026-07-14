# Dotfiles

Any dotfiles can be individually extracted and used elsewhere, but overall I automate dotfile extraction and maanagement via [yadm](https://yadm.io/).

## Kitty

I use the kitty terminal.

If doing `ssh` into a new server environment, when doing some command that requires interactive terminal (e.g. `bat`), I often encounter
an error about the terminal being unknown.

This error is [addressed here](https://sw.kovidgoyal.net/kitty/faq/#i-get-errors-about-the-terminal-being-unknown-or-opening-the-terminal-failing-or-functional-keys-like-arrow-keys-don-t-work).

Typically I just [manually fix](https://sw.kovidgoyal.net/kitty/kittens/ssh/#manual-terminfo-copy) by doing:

```sh
infocmp -a xterm-kitty | ssh myserver tic -x -o \~/.terminfo /dev/stdin
```

or

```sh
infocmp -a xterm-kitty | pbcopy
ssh myserver
vim blah
# paste contents
cat blah | tic -x -o \~/.terminfo /dev/stdin
rm blah
```

## Prerequisites — install BEFORE `yadm clone`

Programs that should already be on a fresh machine so that `yadm clone` (and the
*bootstrap* it triggers) brings up **git + zsh + neovim** with no manual fixes.

Install them with whatever package manager you have — `brew` (macOS),
`apt`/`pacman`/etc. (Linux), `pixi global`, or devbox/nix. The exact manager
doesn't matter; the binaries just need to be on `PATH`.

Legend: **[essential]** clone/shell won't work without it · **[startup]** errors on
every shell/nvim start · **[feature]** only a specific alias/command breaks if missing.

---

### 1. Clone + core

| Program | Why |
|---|---|
| **yadm** | The dotfiles manager itself. `sudo apt-get install yadm` / `brew install yadm`. **[essential]** |
| **git** | yadm is a git wrapper; also used by zsh_unplugged (clones plugins) and lazy.nvim (clones plugins). **[essential]** |
| **openssh-client** (`ssh`) | The clone URL is `git@github.com:…` (SSH). git needs the `ssh` binary. Usually already present on real machines. **[essential]** |

### 2. zsh shell

| Program | Why |
|---|---|
| **zsh** | The login shell. `~/.zshrc` → `superhome/config/zsh/.zshrc.common`. **[essential]** |
| **starship** | Prompt. `.zshrc.common` runs `eval "$(starship init zsh)"` on every shell. Missing ⇒ prompt error each start. **[startup]** |
| **fzf** (≥ 0.48) | Fuzzy finder + completion/keybindings. `.zshrc.common` runs `source <(fzf --zsh)`; `--zsh` needs fzf ≥ 0.48 (older `fzf` will error). Also used by the `fj` / fuzzy-mark jump helpers and `FZF_DEFAULT_COMMAND`. **[startup]** |
| **git** | (see above) zsh_unplugged git-clones fzf-tab, zsh-vi-mode, fast-syntax-highlighting on first interactive shell. **[startup]** |

### 3. neovim — core

| Program | Why |
|---|---|
| **neovim** (≥ 0.10; 0.12 tested) | The editor. `:checkhealth nodar` hard-fails below 0.10-dev. **[essential]** |
| **git** | lazy.nvim bootstraps itself and clones all plugins on first launch. **[essential]** |
| **tree-sitter** (the CLI) | **Required** by nvim-treesitter's `main` branch to compile parsers (`TS.install(...)` shells out to `tree-sitter`). Without it: no syntax highlighting and a wall of build errors. NOT the `nvim-treesitter` plugin — the standalone `tree-sitter` CLI (`brew install tree-sitter`, `cargo install tree-sitter-cli`, `npm i -g tree-sitter-cli`, or the prebuilt release binary). **[startup]** |
| **C compiler + make** (`gcc`/`cc`, `make`) | Compiles treesitter parsers, and builds native bits of telescope-fzf-native and luasnip (jsregexp). `:checkhealth` checks for `make`. **[startup]** |
| **unzip** | Used by mason to unpack downloads; `:checkhealth` checks for it. **[startup]** |
| **curl** (and/or wget) | mason + some plugin build steps download over HTTP. **[startup]** |
| **ripgrep** (`rg`) | Telescope live-grep, and `:checkhealth` checks for it. **[startup]** |
| **fd** | Telescope file finding (and shared with zsh/yazi). **[feature]** |

### 4. neovim — mason toolchain

Mason **auto-installs** the LSPs / linters / formatters / debuggers on first launch
(lua_ls, pyright, ts_ls, clangd, just-lsp, stylua, eslint_d, fixjson, clang-format,
hadolint, jsonlint, shellcheck, ruff, luacheck, debugpy, js-debug-adapter). You do
NOT install those yourself — but mason needs these runtimes present to build/fetch them:

| Program | Why |
|---|---|
| **node + npm** | pyright, ts_ls, eslint_d, fixjson, jsonlint, js-debug-adapter are npm-based. **[feature]** |
| **python3 + pip** (+ venv) | debugpy (and general Python LSP tooling). **[feature]** |
| **luarocks** | mason builds **luacheck** (the lua linter) via luarocks. Missing ⇒ `Error running luacheck: ENOENT` on every lua buffer. **[feature]** |

> Until mason finishes on the first `nvim` launch, lint tools briefly report ENOENT;
> it self-heals within a minute or two. (No prereq action needed.)

### 5. CLI utilities used by zsh aliases / functions

Not needed for shell/nvim startup, but various aliases/functions break without them:

| Program | Why |
|---|---|
| **eza** | `l` / `ll` / `t` / `tt` … listing aliases; also `marks` in the jump plugin. **[feature]** |
| **bat** | `MANPAGER` (syntax-highlighted man pages) and fzf file previews. **[feature]** |
| **delta** | git pager — `core.pager` and `interactive.diffFilter` in `.gitconfig`. Missing ⇒ git diff/log paging falls back / errors. **[feature]** |
| **jq** | JSON wrangling; also a yazi preview dependency. **[feature]** |
| **hexyl** | `hex` alias (hex viewer). **[feature]** |

### 6. Optional / situational

Guarded in config (no error if absent) or tied to out-of-scope tooling:

| Program | Why |
|---|---|
| **yazi** | `y` function + `Y`/yazi.nvim file manager. Its own optional deps: ffmpeg, 7zip, poppler, imagemagick, exiftool, fd, rg, fzf, jq. **[feature]** |
| **kitty** | Terminal. Shell integration is guarded by `$KITTY_INSTALLATION_DIR`; kitty-scrollback.nvim only matters inside kitty. **[optional]** |
| **rlwrap** | `vnode` alias only; guarded by `command -v rlwrap`. **[optional]** |
| **ngrok** | `filengrok` function only. **[optional]** |
| **the_silver_searcher** (`ag`) | Referenced only in a legacy vim comment — not used by current zsh/nvim. Install only if you use old vim. **[optional]** |
| **pixi** | A package manager you sometimes use; not required by the dotfiles themselves. **[optional]** |

---

### Quick copy-paste baselines

**macOS (Homebrew):**
```sh
brew install yadm git zsh starship fzf neovim tree-sitter ripgrep fd \
  node python luarocks eza bat delta jq hexyl
# (git, ssh, make/clang come with macOS + Xcode CLT: xcode-select --install)
```

**Ubuntu/Debian (apt + manual):** apt lacks/underships some of these — `eza`,
`starship`, a recent `fzf` (≥0.48), a recent `neovim`, and the `tree-sitter` CLI
must come from upstream releases/installers (see `Containerfile` for exact steps).
apt covers: `git zsh openssh-client ripgrep fd-find bat jq build-essential
python3 python3-pip nodejs npm luarocks unzip curl` (note apt names `fd`→`fdfind`,
`bat`→`batcat` — symlink them to `fd`/`bat`).
