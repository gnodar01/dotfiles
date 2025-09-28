return {
  -- https://github.com/sudo-tee/opencode.nvim
  -- neovim alt frontend for opencode:
  --   https://github.com/sst/opencode
  --   https://opencode.ai
  -- to use opencode's own fronend directly in nvim, see alternative:
  --   https://github.com/NickvanDyke/opencode.nvim?tab=readme-ov-file
  {
    'sudo-tee/opencode.nvim',
    name = 'opencode',
    --
    -- https://github.com/sudo-tee/opencode.nvim?tab=readme-ov-file#%EF%B8%8F-configuration
    config = function()
      require('opencode').setup({
        default_global_keymaps = false, -- disable default keymaps
        preferred_picker = 'telescope',
        preferred_completion = 'nvim-cmp',
        default_mode = 'build',
      })
      local oc = require('opencode.api')
      local map = function(key, func, desc)
        vim.keymap.set('n', key, func, { desc = desc })
      end

      map('<Leader>og', oc.toggle, '[o]pen opencode else close')
      map('<Leader>oi', oc.open_input, 'open [i]nput window (curr sesh)')
      map('<Leader>oI', oc.open_input_new_session, 'open [I]nput window (new sesh)')
      map('<Leader>oo', oc.open_output, 'open [o]utput window')
      map('<Leader>ot', oc.toggle_focus, '[t]oggle focus between opencode and last window')
      map('<Leader>oq', oc.close, '[q]uit - close UI windows')
      map('<Leader>os', oc.select_session, '[s]elect and load session')
      map('<Leader>oS', oc.select_child_session, '[s]elect and load child session')
      map('<Leader>op', oc.configure_provider, 'configure [p]rovider and model')
      map('<Leader>od', oc.diff_open, 'open [d]iff view of changes')
      map('<Leader>o]', oc.diff_next, 'navigate to next []] file diff')
      map('<Leader>o[', oc.diff_prev, 'navigate to previous [[] file diff')
      map('<Leader>oc', oc.diff_close, '[c]lose diff view tab')
      map('<Leader>ora', oc.diff_revert_all_last_prompt, '[r]evert [a]ll file changes since last prompt')
      map('<Leader>ort', oc.diff_revert_this_last_prompt, '[r]evert curren[t] file changes since last prompt')
      map('<Leader>ox', oc.swap_position, '[x]-swap opencode pane left/right')
      map('<Leader>oz', oc.initialize, 'initiali[z]e/update AGENTS.md file')
      map('<Leader>omb', oc.agent_build, 'set [m]ode to [b]uild')
      map('<Leader>omp', oc.agent_plan, 'set [m]ode to [p]lan')
      map('<Leader>omm', oc.select_agent, 'select and switch [m][m]ode/agent')
      -- @: insert mention (file/agent)
      -- ~: pick a file and add to context
      -- ]]: navigate to next message
      -- [[: navigate to previous message
      -- <up>: navigate to previous prompt in history
      -- <down>: navigate to next prompt in history
      -- <tab>: toggle input/output panes
      --
      -- :OpencodeRun <prompt> <opts>
      -- :OpencodeRunNewSession <prompt> <opts>
      --
      -- <opts>:
      --   * agent=<agent_name> - specify the agent to use for this prompt (overrides current agent)
      --   * model=<provider/model_name> - specify the model to use for this prompt (overrides current model) e.g. model=github-copilot/gpt-4.1
      --   * context.<context_type>.enabled=<true|false>: enable/disable specific context types for this prompt only; available:
      --     * current_file
      --     * selection
      --     * diagnostics.info
      --     * diagnostics.warn
      --     * diagnostics.error
      --     * cursor_data
      --
      -- Example:
      -- :OpencodeRunNewSession "Please help me plan a new feature" agent=plan context.current_file.enabled=false
      -- :OpencodeRun "Fix the bug in the current file" model=github-copilot/claude-sonnet-4
    end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          anti_conceal = { enabled = false },
          file_types = { 'markdown', 'opencode_output' },
        },
        ft = { 'markdown', 'Avante', 'copilot-chat', 'opencode_output' },
      },
      -- Optional, for file mentions and commands completion
      'nvim-cmp',

      -- Optional, for file mentions picker
      'telescope',
    },
  },
}
