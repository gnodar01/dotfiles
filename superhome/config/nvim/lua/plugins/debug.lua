-- https://github.com/mfussenegger/nvim-dap
-- DAP plugins
-- `:h dap-configuration`

return {
  'mfussenegger/nvim-dap',
  -- extension name is "dap"
  name = 'dap',
  --tag = '0.9.0',
  dependencies = {
    -- https://github.com/rcarriga/nvim-dap-ui
    -- creates a beautiful debugger UI
    -- extension name is "dapui"
    {
      'rcarriga/nvim-dap-ui',
      name = 'dap-ui',
      --tag = 'v4.0.0',
    },

    -- https://github.com/nvim-neotest/nvim-nio
    -- async i/o in neovim; required for nvim-dap-ui
    {
      'nvim-neotest/nvim-nio',
      name = 'nio',
      --tag = 'v1.10.1',
    },
  },
  keys = {
    {
      '<Leader>dp',
      function()
        require('dap').continue()
      end,
      desc = '[D]ebug: [P]lay (Start/Continue)',
    },
    {
      '<Leader>d]',
      function()
        require('dap').step_into()
      end,
      desc = '[D]ebug: Step Into []]',
    },
    {
      '<Leader>d\\',
      function()
        require('dap').step_over()
      end,
      desc = '[D]ebug: Step Over [\\]',
    },
    {
      '<Leader>d[',
      function()
        require('dap').step_out()
      end,
      desc = '[D]ebug: Step Out [[]',
    },
    {
      '<Leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = '[D]ebug: Toggle [shft-B]reakpoint',
    },
    {
      '<Leader>dB',
      function()
        require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
      end,
      desc = '[D]ebug: Set [B]reakpoint',
    },
    -- toggle to see last session result. without this, can't see session output in case of unhandled exception.
    {
      '<Leader>dl',
      function()
        require('dapui').toggle()
      end,
      desc = '[D]ebug: See [L]ast (previous) Session Result.',
    },
  },
  config = function()
    local dap = require('dap')
    local dapui = require('dapui')

    -- dap UI setup
    -- for more information, see |:help nvim-dap-ui|
    dapui.setup({
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    })

    -- change breakpoint icons
    -- vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    -- vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    -- local breakpoint_icons = vim.g.have_nerd_font
    --     and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
    --   or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    -- for type, icon in pairs(breakpoint_icons) do
    --   local tp = 'Dap' .. type
    --   local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
    --   vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    -- end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close
  end,
}
