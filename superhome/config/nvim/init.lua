-- do `ln -s $HOME/superhome/config/nvim $HOME/.config/nvim`

-- https://dev.to/aphelionz/neovim-config-from-initvim-to-initlua-53n4
vim.cmd([[
  source $HOME/superhome/config/vim/nvim_init.vim
]])

function Dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then
        k = '"' .. k .. '"'
      end
      s = s .. '[' .. k .. '] = ' .. Dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end
function Dumpp(o)
  print(Dump(o))
end

require('config.settings')
require('config.lazy')
