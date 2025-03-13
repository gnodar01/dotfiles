" plugin installation, management, and configuration

" `zo` to open a single fold under the cursor
" `zc` to close the fold under the cursor
" `zR` to open all folds
" `zM` to close all folds
" `:help folding` for more info

" vim-plug setup ---------------------------------------------------------- {{{

"  https://github.com/junegunn/vim-plug

" download vim-plug if missing
" https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
endif

" run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

" declare plugins
silent! if plug#begin()

  " manually install with :PlugInstall
  " (but automation above should handle it)
  " update with :PlugUPdate
  " clean unused with :PlugClean

  "Plug 'preservim/nerdtree'
  "Plug 'itchyny/lightline.vim'
  "Plug 'tpope/vim-surround'
  "Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  "Plug 'junegunn/fzf.vim'
  "Plug 'neoclide/coc.nvim', {'branch': 'release'}
  "Plug 'puremourning/vimspector'

  "Plug '<repo>/<plugin>'
  "Plug 'ctrlpvim/ctrlp.vim'
  "Plug 'junegunn/vim-easy-align'
  "Plug 'tpope/vim-commentary'
  "Plug 'tpope/vim-eunuch'
  "Plug 'tpope/vim-fugitive'
  "Plug 'tpope/vim-repeat'
  "Plug 'tpope/vim-unimpaired'
  
  " do :echo v:version to see your version
  " vim and nvim will be different
  "
  " ignore these on older versions of vim
  "if v:version >= 703
    "Plug '<repo>/<plugin>'
  "endif

  call plug#end()
endif

" }}}

" plugin 1 ---------------------------------------------------------- {{{
" }}}

