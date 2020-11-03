set encoding=utf-8
set nu
set formatoptions+=o
set expandtab
set tabstop=4
set shiftwidth=4
set smartindent
set hlsearch
set incsearch
set ignorecase
set hidden
syntax enable
filetype plugin indent on
inoremap <silent> jj <ESC>
set clipboard=unnamed

call plug#begin('~/.local/share/nvim/plugged')
Plug 'rust-lang/rust.vim' 
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'vim-ruby/vim-ruby', {'branch': 'release'}
call plug#end()

let g:coc_global_extension = ['coc-solargraph']



