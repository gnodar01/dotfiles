-- https://github.com/nvim-telescope/telescope-fzf-native.nvim

return {
  'nvim-telescope/telescope-fzf-native.nvim',
  -- extension name is "fzf"
  name = 'telescope-fzf-native',
  -- never tried this, but its another way to build on mac
  -- https://github.com/nvim-telescope/telescope-fzf-native.nvim?tab=readme-ov-file#cmake-windows-linux-macos
  -- build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release'
  -- https://github.com/nvim-telescope/telescope-fzf-native.nvim?tab=readme-ov-file#make-linux-macos-windows-with-mingw
  build = 'make',
  cond = function()
    return vim.fn.executable 'make' == 1
  end,
}
