-- do `ln -s $HOME/superhome/config/nvim $HOME/.config/nvim`

-- https://dev.to/aphelionz/neovim-config-from-initvim-to-initlua-53n4
vim.cmd([[
  source $HOME/superhome/config/vim/nvim_init.vim
]])

require("config.lazy")
