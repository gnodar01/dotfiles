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

  "Plug '<repo>/<plugin>'
  Plug 'preservim/nerdtree'
  Plug 'itchyny/lightline.vim'
  "Plug 'ctrlpvim/ctrlp.vim'
  "Plug 'junegunn/vim-easy-align'
  "Plug 'tpope/vim-commentary'
  "Plug 'tpope/vim-eunuch'
  "Plug 'tpope/vim-fugitive'
  "Plug 'tpope/vim-repeat'
  Plug 'tpope/vim-surround'
  "Plug 'tpope/vim-unimpaired'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'

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

" NERDTree ---------------------------------------------------------------- {{{

" https://github.com/preservim/nerdtree

" quick toggle NERDTree
nmap <leader>n :NERDTreeToggle<CR>
" show hidden files by default
let NERDTreeShowHidden=1

" }}}

" light line -------------------------------------------------------------- {{{

"  https://github.com/itchyny/lightline.vim

" fixes status line not showing up
set laststatus=2

" -- insert -- not needed anymore since it's in the satus line
set noshowmode

" colorscheme
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ }

" }}}

" fzf --------------------------------------------------------------------- {{{
" https://github.com/junegunn/fzf.vim

" :Files [PATH] - $FZF_DEFAULT_COMMAND
" :GFiles [OPTS] - git files (git ls-files)
" :GFiles? = git files (git status)
" :Buffers - open buffers
" :Colors - color schemes
" :Ag [PATTERN] - ag (aka the_silver_search, ack alt); ALT-A to select all, ALT-D to deselect all
" :Rg [PATTERN] - rg (aka ripgrep, grep alt); ALT-A to select all, ALT-D to deselect all
" :RG [PATTERN] - rg; but relaunch ripgrep on every keystroke
" :Lines [QUERY] - lines in loaded buffers
" :Blines [QUERY] - lines in current buffer
" :Marks - marks
" :Jumps - jumps
" :Windows - windows
" :History: - command history
" :History/ - search history
" :Maps - normal mode mappings
" :Helptags - help tags
" :Filetypes - file types
"
" CTRL-T / CTRL-X / CTRL-V to open in new tab, (horizontal) split, vertical split

" overwrite the default Files command - using 'opener' as preview
" https://github.com/junegunn/fzf.vim?tab=readme-ov-file#example-customizing-files-command
command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, {'options': ['--layout=reverse', '--preview', 'opener {}']}, <bang>0)
nnoremap <C-o> :Files<CR>
nnoremap <leader>o :Files 
nnoremap <leader>O :Files! 
nnoremap <C-p> :GFiles<CR>
nnoremap <leader>p :GFiles 
nnoremap <leader>P :GFiles! 
nnoremap <C-b> :Buffers<CR>
nnoremap <leader>r :Rg 

" }}}
