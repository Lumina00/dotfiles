set encoding=utf-8
set nocompatible
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
Plug 'preservim/nerdtree'
Plug 'majutsushi/tagbar'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'Yggdroot/indentLine'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'ryanoasis/vim-devicons'

Plug 'rust-lang/rust.vim' 
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'vim-ruby/vim-ruby', {'branch': 'release'}
call plug#end()

let g:coc_global_extension = ['coc-solargraph']

let NERDTreeShowHidden=1
let g:NERDTreeDirArrowExpandable = '↠'
let g:NERDTreeDirArrowCollapsible = '↡'

let g:tagbar_width = 30
let g:tagbar_iconchars = ['↠', '↡']

let mapleader="\<Space>"
nmap <leader>q :NERDTreeToggle<CR>
nmap <leader>w :TagbarToggle<CR>

let g:airline_powerline_fonts = 1
let g:airline_section_z = ' %{strftime("%-I:%M %p")}'
let g:airline_section_warning = ''

let g:indentLine_char ='▏'
let g:indentLine_color_gui = '#363949'
let g:indentLine_enabled = 0
