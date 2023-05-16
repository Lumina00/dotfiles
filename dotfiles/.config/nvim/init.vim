set encoding=utf-8
set fileencoding=utf-8
set nocompatible
set nu
set formatoptions+=o
"set expandtab
set tabstop=4
set shiftwidth=4
set smartindent
set hlsearch
set incsearch
set ignorecase
set hidden
syntax enable
filetype plugin indent on
set clipboard+=unnamed,unnamedplus
packadd termdebug
call plug#begin('~/.local/share/nvim/plugged')
Plug 'preservim/nerdtree'
Plug 'majutsushi/tagbar'
Plug 'Yggdroot/indentLine'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'ryanoasis/vim-devicons'
Plug 'nvim-lua/plenary.nvim' "Need diffview
Plug 'sindrets/diffview.nvim'
"Plug 'neoclide/coc.nvim', {'branch': 'release'}
"Plug 'autozimu/LanguageClient-neovim', {
"    \ 'branch': 'next',
"    \ 'do': 'bash install.sh',
"    \ }

call plug#end()

"let g:coc_global_extension = ['coc-solargraph']
"let g:LanguageClient_serverCommands = {
"    \ 'rust': ['/usr/bin/rust-analyzer'],
"    \ 'ruby': ['~/.rbenv/shims/solargraph', 'stdio'],
"    \ 'cpp' : ['/usr/bin/clangd','--background-index','-std=c++20'],
"}

let NERDTreeShowHidden=1
let g:NERDTreeDirArrowExpandable = '↠'
let g:NERDTreeDirArrowCollapsible = '↡'

let g:tagbar_width = 30
let g:tagbar_iconchars = ['↠', '↡']

let mapleader="\<Space>"
nmap <leader>q :NERDTreeToggle<CR>
nmap <leader>w :TagbarToggle<CR>
nmap <leader>h <C-w>h
nmap <leader>j <C-w>j
nmap <leader>k <C-w>k
nmap <leader>l <C-w>l
nmap <leader>n <C-w>n

"inoremap <expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
inoremap <silent> jj <ESC>
tnoremap <ESC><ESC> <C-\><C-N>

let g:airline_powerline_fonts = 1
let g:airline_section_z = ' %{strftime("%-I:%M %p")}'
let g:airline_section_warning = ''

let g:indentLine_char ='▏'
let g:indentLine_color_gui = '#363949'
let g:indentLine_enabled = 0
