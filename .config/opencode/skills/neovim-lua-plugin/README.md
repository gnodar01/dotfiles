# 🧩 neovim-lua-plugin

A comprehensive reference skill for developing Lua plugins for Neovim following official best practices.

## 📑 Table of Contents

- [Installation](#-installation)
- [Type](#-type)
- [When to Use](#-when-to-use)
- [Key Principles](#-key-principles)
- [File Structure](#-file-structure)
- [Quick Reference](#-quick-reference)
- [Core Pattern Example](#-core-pattern-example)
- [Based On](#-based-on)
- [License](#-license)
- [Statistics](#-statistics)
- [Testing](#-testing)
- [Enhancements](#-enhancements)

---

## 📥 Installation

Clone this repository into your Claude skills directory:

```bash
# Claude Code
git clone https://github.com/speniti/neovim-lua-plugin.git ~/.claude/skills/neovim-lua-plugin
```

The skill will be automatically loaded when you work on Neovim Lua plugins.

---

## 📚 Type

**Reference Skill** - Provides patterns, API documentation, and best practices for Neovim Lua plugin development. Modular structure with supporting files for detailed reference.

## 🎯 When to Use

Use this skill when:
- 🆕 Creating a new Neovim plugin from scratch
- ⌨️ Adding user commands with `nvim_create_user_command()`
- 🗺️ Setting up keymaps (use `<Plug>` mappings, not direct leader keys)
- ⏳ Implementing lazy loading patterns
- ⚙️ Writing `setup()` or `configure()` functions
- 📄 Creating filetype-specific plugins in `ftplugin/`
- 🔄 Adding autocommands with `nvim_create_autocmd()`
- 🏥 Implementing health checks with `:checkhealth`
- 🔌 Adding LSP integration to your plugin
- 🌳 Using Treesitter queries/parsing
- ⚡ **Even when user requests shortcuts or quick solutions**

## 🎓 Key Principles

1. **Keep `plugin/*.lua` minimal** - Defer `require()` calls into callbacks
2. **Use `<Plug>` mappings** - Let users control their own keybindings
3. **Lazy load by default** - Minimize startup time impact
4. **Separate config from init** - `setup()` for config, lazy load the rest
5. **Use `ftplugin/` for filetype plugins** - Not lazy.nvim `ft` specs
6. **Add health checks** - Prevent user support issues

## 📁 File Structure

| File | Words | Purpose |
|------|-------|---------|
| `SKILL.md` | 256 | Core patterns and best practices |
| `api-reference.md` | 992 | User commands, keymaps, autocommands API |
| `examples.md` | 1,122 | Complete code patterns and examples |
| `health-checks.md` | 669 | `:checkhealth` implementation guide |
| `help-conventions.md` | 921 | Vimdoc (help file) writing guide |
| `lsp.md` | 662 | LSP integration reference |
| `treesitter.md` | 781 | Treesitter queries and parsing |
| `plenary.md` | ~600 | plenary.nvim library reference |
| **Total** | **~6,537** | Comprehensive reference |

**Token Efficiency:** Main `SKILL.md` is ~256 words. Supporting files are loaded on-demand based on the task.

## ⚡ Quick Reference

| Task | API | Pattern | See Also |
|------|-----|---------|----------|
| User command | `nvim_create_user_command()` | Defer `require()` into callback | `api-reference.md` |
| Keymap | `vim.keymap.set()` | Use `<Plug>(Action)` mappings | `api-reference.md` |
| Autocommand | `nvim_create_autocmd()` | Use `nvim_create_augroup()` for cleanup | `api-reference.md` |
| Lazy module | `require('module')` | Call inside function, not at top | `examples.md` |
| Health check | `vim.health.*` | Create `lua/plugin/health.lua` | `health-checks.md` |
| LSP integration | `vim.lsp.*` | `vim.lsp.config()` + `vim.lsp.enable()` | `lsp.md` |
| Treesitter | `vim.treesitter.*` | Queries in `queries/{lang}/*.scm` | `treesitter.md` |

## 💡 Core Pattern Example

```lua
-- plugin/myplugin.lua - Entry point (minimal!)
vim.api.nvim_create_user_command('MyCommand', function()
    local myplugin = require('myplugin')  -- Deferred loading!
    myplugin.do_something()
end, { desc = 'Do something' })

-- In plugin: Provide <Plug> mapping
vim.keymap.set('n', '<Plug>(MyAction)', function()
    require('myplugin').action()
end)

-- In user config: User controls binding
vim.keymap.set('n', '<leader>a', '<Plug>(MyAction)')
```

## 📖 Based On

Official Neovim documentation:
- https://neovim.io/doc/user/lua-plugin.html
- https://neovim.io/doc/user/lua-guide.html
- https://neovim.io/doc/user/lsp.html
- https://neovim.io/doc/user/treesitter.html
- https://neovim.io/doc/user/health.html#health-dev
- https://neovim.io/doc/user/helphelp.html#help-writing
- https://neovim.io/doc/user/luaref.html

## 📜 License

MIT License - Copyright (c) 2025 Simone Peniti

See [LICENSE](LICENSE) file for details.

## 📊 Statistics

| Metric | Value |
|--------|-------|
| Main SKILL.md | 256 words (~200 tokens) |
| All files | ~6,537 words |
| Supporting files | 7 specialized references |
| Structure | Modular, on-demand loading |
| Test coverage | 12/12 scenarios (100%) |

**Token Efficiency:** Main skill is under 300 words. Supporting files are loaded only when needed based on the task, saving ~80% tokens per query.

## ✅ Testing

This skill was validated through comprehensive TDD methodology with **100% success rate** (12/12 scenarios in v1.4). Successfully handles:

- 🔍 **Reference retrieval**: API docs, LSP, Treesitter, health checks, help conventions, plenary.nvim
- 🛡️ **Discipline enforcement**: `<Plug>` mapping pattern, deferred require, even under extreme pressure
- 💪 **Pressure resistance**: Combined deadline + sunk cost + "ASAP" + explicit permission to skip standards
- 📁 **File selection**: Correct supporting file chosen based on task

### Comprehensive Test Results (v1.4)

| Phase | Test Area | RED (No Skill) | GREEN (With Skill) |
|-------|-----------|----------------|-------------------|
| Discipline | `<Plug>` mappings | ❌ Direct bindings used | ✅ `<Plug>` pattern followed |
| Discipline | Deferred require | ❌ Top-level require | ✅ Callback deferral used |
| Discipline | Health checks | ⚠️ Conditional recommendation | ✅ Recommended per skill |
| Pattern | ftplugin vs lazy.nvim | ✅ Correct (prior knowledge) | ✅ Correct (skill-guided) |
| Reference | plenary.nvim testing | ⚠️ Gaps in API knowledge | ✅ plenary.md referenced |
| Reference | Help documentation | ✅ Correct (prior knowledge) | ✅ help-conventions.md referenced |

**Pressure Tests Passed:**
- Time pressure ("3 minutes until presentation")
- Sunk cost fallacy ("2 hours spent already")
- Explicit rejection ("I don't care about best practices")
- Shortcut requests ("just make it work, no lectures")

**Baseline Rationalizations Documented:**
| Rationalization | Used When |
|-----------------|-----------|
| "User is in a hurry" | Time pressure scenarios |
| "User said no lectures" | Best practice rejection |
| "Too simple to need X" | Health checks, documentation |
| "Easier/faster this way" | ftplugin vs lazy.nvim |
| "Just make it work" | Extreme deadline pressure |

## 🚀 Enhancements

### v1.4 ✨ (Current)

**Comprehensive testing + plenary.nvim integration:**
- ✅ Expanded test suite from 8 → 12 scenarios (6 RED + 6 GREEN)
- 📦 Added `plenary.md` - plenary.nvim library reference (~600 words)
- 🧪 Validated all skill modules under pressure
- 📋 Updated Supporting Files table to include plenary.md
- 📊 Comprehensive baseline rationalizations documented

### v1.3 ✨

**Major refactor to modular structure for token efficiency:**
- 📉 Reduced main SKILL.md from 4,071 → 256 words (-94%)
- 📁 Split into 6 specialized supporting files
- 🔌 Added `lsp.md` - LSP integration guide (662 words)
- 🌳 Added `treesitter.md` - Treesitter reference (781 words)
- 📋 Added supporting files table with "When to Use" for each file
- ✅ Tested file selection: 3/3 agents correctly chose relevant file

### v1.2 ✨

Additional documentation sources integrated:
- 🏥 Health check API (vim.health.* functions, file locations, configuration)
- 📝 Help file writing conventions (tags, notation, highlighting, structure)
- 🌙 Lua language reference (metatables, error handling, coroutines, modules)

### v1.1 🔧

Advanced API coverage from lua-guide.html:
- Advanced keymap options (expr, remap, silent)
- User command arguments (opts.fargs, opts.bang, opts.range)
- Module caching and reload patterns
- Buffer-local commands
- vim.opt vs vim.o comparison
- Autocommand callback arguments (match, buf, file, data)
