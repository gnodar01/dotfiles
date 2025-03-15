-- https://github.com/folke/which-key.nvim
-- show pending keybinds

return {
  'folke/which-key.nvim',
  name = 'which-key',
  tag = 'v3.17.0',
  event = 'VimEnter',
  opts = {
    -- delay between pressing a key and opening which-key (milliseconds)
    delay = 0,
    icons = {
      -- set icon mappings to true if nerd fonts
      mappings = vim.g.have_nerd_font,
      -- if using nerd font: set icons.keys to an empty table which will use the
      -- default which-key.nvim defined nerd font icons, otherwise define a string table
      keys = vim.g.have_nerd_font and {} or {
        Up = '<Up> ',
        Down = '<Down> ',
        Left = '<Left> ',
        Right = '<Right> ',
        C = '<C-…> ',
        M = '<M-…> ',
        D = '<D-…> ',
        S = '<S-…> ',
        CR = '<CR> ',
        Esc = '<Esc> ',
        ScrollWheelDown = '<ScrollWheelDown> ',
        ScrollWheelUp = '<ScrollWheelUp> ',
        NL = '<NL> ',
        BS = '<BS> ',
        Space = '<Space> ',
        Tab = '<Tab> ',
        F1 = '<F1>',
        F2 = '<F2>',
        F3 = '<F3>',
        F4 = '<F4>',
        F5 = '<F5>',
        F6 = '<F6>',
        F7 = '<F7>',
        F8 = '<F8>',
        F9 = '<F9>',
        F10 = '<F10>',
        F11 = '<F11>',
        F12 = '<F12>',
      },
    },

    -- document existing key chains
    spec = {
      { '<Leader>f', group = '[F]uzzy Search' },
      -- { '<Leader>c', group = '[C]ode', mode = { 'n', 'x' } },
      -- { '<Leader>d', group = '[D]ocument' },
      -- { '<Leader>r', group = '[R]ename' },
      -- { '<Leader>w', group = '[W]orkspace' },
      -- { '<Leader>t', group = '[T]oggle' },
      -- { '<Leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    },
  },
}
