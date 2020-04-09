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
call plug#begin('~/.local/share/nvim/plugged')
Plug 'rust-lang/rust.vim' 
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()




