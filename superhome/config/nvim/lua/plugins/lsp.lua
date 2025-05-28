-- `:help lsp-vs-treesitter`

return {
  -- https://github.com/neovim/nvim-lspconfig
  -- LSP setup and plugins
  {
    -- data only, providing basic config for various LSP servers
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
    -- install the language server (pyright, tsserver, etc.) somewhere else
    --
    -- Help
    --   `:help lspconfig-all`
    --
    -- `:checkhealth lsp`
    'neovim/nvim-lspconfig',
    name = 'lspconfig',
    --tag = 'v1.7.0',
    dependencies = {
      -- package manager
      'mason',
      -- https://github.com/mason-org/mason-lspconfig.nvim
      -- mason extension to use lspconfig
      -- setup hook
      -- `:LspInstall` command
      -- auto install and setup servers
      -- translate between `lspconfig` server names and `mason.nvim` package names (e.g. `lua_ls` <-> `lua-language-server`)
      --
      -- Help
      --   `:h mason-lspconfig-introduction`
      {
        'mason-org/mason-lspconfig.nvim',
        --tag = 'v1.32.0',
        -- v2 is rc at time of writing
        --tag = 'v2.0.0',
        name = 'mason-lspconfig',
      },
      -- https://github.com/j-hui/fidget.nvim
      -- UI for Neovim notifications and LSP progress messages
      -- hooks into [`$/pgrogress`](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#progress)
      -- NOTE: could be abstracted out into its own plugin config
      {
        'j-hui/fidget.nvim',
        name = 'fidget',
        --tag = 'v1.6.1',
        opts = {},
      },
      -- https://github.com/hrsh7th/cmp-nvim-lsp
      -- allows extra capabilities provided by nvim-cmp
      -- also a dependency of `nvim-cmp`
      {
        'hrsh7th/cmp-nvim-lsp',
        name = 'cmp-nvim-lsp',
      },
      {
        'SmiteshP/nvim-navic',
        name = 'nvim-navic',
        config = function()
          vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
        end,
      },
    },
    config = function()
      -- run whenever an LSP attaches to a particular buffer
      --   so everytime a file is opened that is associated with an LSP
      --   this function is executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('nodar-lsp-attach', { clear = true }),
        callback = function(event)
          -- mapping helper to attach key to correct buffer and remember "LSP: " prefix
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- mappings

          -- jump to the definition of the word under cursor
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- jump back, using native `<C-t>` (`<C-o>` uses jump history, `<C-t>` uses tag history)
          map('gb', '<C-t>', '[G]o [B]ack (prev tag)')

          -- find references for word under cursor
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- jump to implementation (e.g. type def)
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- jump to type under cursor
          map('<Leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- fuzzy find all the symbols in current document
          map('<Leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- fuzzy find all the symbols in your current workspace
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- rename the variable under your cursor
          -- most LSPs support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- execute a code action, usually cursor needs to be on top of an error
          -- or a suggestion from LSP for this to activate
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

          -- WARN: This is not Goto Definition, this is Goto Declaration
          --  e.g., in C this would take you to the header
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- following autocommands used to highlight references of word under cursor
          -- when cursor rests for a while
          --   See `:help CursorHold` for info on when this is executed
          -- on cursor move, highlight removed
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if
            client
            and client:supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
          then
            local highlight_augroup = vim.api.nvim_create_augroup('nodar-lsp-highlight', { clear = false })

            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('nodar-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = 'nodar-lsp-highlight', buffer = event2.buf })
              end,
            })
          end

          -- the following code creates a keymap to toggle inlay hints in code,
          -- if LSP supports them
          -- WARN: may be unwanted - displaces code
          if client and client:supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Diagnostic Config
      -- see `:help vim.diagnostic.Opts
      vim.diagnostic.config({
        severity_sort = true,
        float = {
          border = 'rounded',
          --source = 'if_many'
          source = true,
        },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          --source = 'if_many',
          source = true,
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      })

      -- LSP servers and clients communicate with each other their capabilities,
      -- i.e. the features they support. By default, Neovim doesn't support
      -- everything that is in the LSP specification. `nvim-cmp` adds *more*
      -- capabilities. So, we create new capabilities with `nvim-cmp`, and then
      -- broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local navic = require('nvim-navic')

      local on_attach = function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          navic.attach(client, bufnr)
        end
      end

      local servers = require('config/mason-pkgs').lsp_server_configs

      for server_name, server_cfg in pairs(servers) do
        -- This handles overriding only values explicitly passed
        -- by the server configuration above. Useful when disabling
        -- certain features of an LSP (for example, turning off formatting for ts_ls)
        server_cfg.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server_cfg.capabilities or {})
        vim.lsp.config(server_name, server_cfg)
      end

      -- TODO: consider removing this since nvim 0.11 transition
      -- not sure if there's any value left
      require('mason-lspconfig').setup({
        ensure_installed = {}, -- explicitly set to an empty table (installs populated via mason-tool-installer)
        automatic_enable = true,
      })
    end,
  },
  -- https://github.com/hrsh7th/nvim-cmp
  -- a completion engine plugin for neovim
  -- completion sources are installed from external repos and "sourced"
  -- TODO: update with blink: https://github.com/nvim-lua/kickstart.nvim/commit/d350db2449da40df003c40d440f909d74e2d4e70
  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    name = 'nvim-cmp',
    --tag = 'v0.0.2',
    event = 'InsertEnter',
    dependencies = {
      -- https://github.com/L3MON4D3/LuaSnip
      -- Snippet Engine & its associated nvim-cmp source
      -- keymaps:
      --   <C-K> - expand
      --   <C-L> - jump forward
      --   <C-J> - jump backward
      --   <C-E> - change active choice
      {
        'L3MON4D3/LuaSnip',
        name = 'luasnip',
        --tag = 'v2.4.*',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has('win32') == 1 or vim.fn.executable('make') == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          --  https://github.com/rafamadriz/friendly-snippets
          -- `friendly-snippets` contains a variety of premade snippets.
          --  See the README about individual language/framework/plugin snippets:
          {
            --'rafamadriz/friendly-snippets',
            'gnodar01/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load()
            end,
          },
        },
      },

      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.

      -- https://github.com/saadparwaiz1/cmp_luasnip
      -- `luasnip` completion source for `nvim-cmp`
      {
        'saadparwaiz1/cmp_luasnip',
        name = 'cmp_luasnip',
      },

      -- https://github.com/hrsh7th/cmp-nvim-lsp
      -- allows extra capabilities provided by nvim-cmp
      -- also a dependency of `nvim-lspconfig`
      {
        'hrsh7th/cmp-nvim-lsp',
        name = 'cmp-nvim-lsp',
      },
      -- https://github.com/hrsh7th/cmp-path
      -- `nvim-cmp` source for filesystem paths
      {
        'hrsh7th/cmp-path',
        name = 'cmp-path',
      },
      -- https://github.com/hrsh7th/cmp-nvim-lsp-signature-help
      -- `nvim-cmp` source for displaying function signatures with the current parameter emphasized
      {
        'hrsh7th/cmp-nvim-lsp-signature-help',
        name = 'cmp-nvim-lsp-signature-help',
      },
    },
    config = function()
      -- See `:help cmp`
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      luasnip.config.setup({})

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- For info on why these mappings, read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert({
          -- select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- accept ([y]es) the completion
          --  this will auto-import if the LSP supports it
          --  this will expand snippets if the LSP sent a snippet
          ['<C-y>'] = cmp.mapping.confirm({ select = true }),

          -- more traditional completion keymaps
          --['<CR>'] = cmp.mapping.confirm { select = true },
          --['<Tab>'] = cmp.mapping.select_next_item(),
          --['<S-Tab>'] = cmp.mapping.select_prev_item(),

          -- manually trigger a completion from nvim-cmp
          --  generally don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available
          ['<C-Space>'] = cmp.mapping.complete({}),

          -- think of <c-l> as moving to the right of the snippet expansion
          --  having a snippet like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move cursor to the right of each of the expansion locations
          -- <c-h> is similar, except moving backwards
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        }),
        sources = {
          {
            name = 'lazydev',
            -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            group_index = 0,
          },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
          { name = 'nvim_lsp_signature_help' },
        },
      })
    end,
  },
  {
    -- https://github.com/folke/lazydev.nvim
    -- configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    name = 'lazydev',
    --tag = 'v1.9.0',
    ft = 'lua',
    opts = {
      library = {
        -- load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        -- https://github.com/rcarriga/nvim-dap-ui?tab=readme-ov-file#installation
        'nvim-dap-ui',
      },
    },
  },
}
