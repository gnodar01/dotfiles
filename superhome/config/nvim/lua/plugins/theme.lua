-- colorscheme(s)
-- some plugins need to be configured separately in their own file
-- e.g. LazyVim (`config/lazy`; opts.colorscheme), lualine (options.theme)

--return {
--  -- to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
--  'folke/tokyonight.nvim',
--  --tag = 'v4.11.0',
--  name = 'colorscheme',
--  lazy = false,
--  priority = 1000, -- make sure to load this before all the other start plugins
--  config = function()
--    ---@diagnostic disable-next-line: missing-fields
--    require('tokyonight').setup {
--      styles = {
--        comments = { italic = false }, -- disable italics in comments
--      },
--    }
--    -- many themes have a collection of styles
--    -- e.g. tokyonight-night, tokyonight-storm, toykonight-moon, tokyonight-day
--    vim.cmd.colorscheme 'tokyonight-storm'
--  end,
--}

return {
  -- to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
  'Mofiqul/dracula.nvim',
  name = 'colorscheme',
  lazy = false,
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require('dracula').setup({
      show_end_of_buffer = true, -- (default false)
      transparent_bg = true, -- (default false)
      --lualine_bg_color = '#rrggbb', -- (default nil)
      italic_comment = false, -- (default false)
      colors = {
        selection = '#33343f',
      },
    })
    -- many themes have a collection of styles
    -- e.g. dracula, dracula-soft
    vim.cmd.colorscheme('dracula-soft')
  end,
}
