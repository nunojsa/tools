set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'vim-syntastic/syntastic'
Plugin 'rdnetto/YCM-Generator'
" Plugin 'craigemery/vim-autotag'
Plugin 'ludovicchabant/vim-gutentags'
" Track the engine.
Plugin 'SirVer/ultisnips'
" Snippets are separated from the engine. Add this if you want them:
Plugin 'honza/vim-snippets'
Plugin 'mileszs/ack.vim'
Plugin 'kien/ctrlp.vim'
Plugin 'zefei/vim-wintabs'
Plugin 'Valloric/YouCompleteMe'
" Dependeny for vim-session
Plugin 'xolox/vim-misc'
" Session manager
Plugin 'xolox/vim-session'
" provides code outline (with f2 shortcut)
Plugin 'yegappan/taglist'
" provides neater statusline
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'godlygeek/tabular'
Plugin 'preservim/vim-markdown'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.$
" plugin on GitHub repo
" Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
"Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line


" Automatically save the current session whenever vim is closed
" autocmd VimLeave * mksession! ~/.vim/shutdown_session.vim
" <F7> restores that 'shutdown session'
 "noremap <F8> :source ~/.vim/shutdown_session.vim<CR>

map <C-l> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

set encoding=utf-8
syntax on

nnoremap <C-A-v> <c-v>

"for tabs
map <S-Right> :tabnext<CR>
map <S-Left> :tabprev<CR>
map <S-k> :tabclose<CR>
nnoremap <F3> :NERDTreeToggle<CR>
" locwindow
nnoremap <S-c> :lclose<CR>
" quickfix window
nnoremap <S-q> :ccl<CR>
" YCM options
"" turn on completion in comments
let g:ycm_complete_in_comments=1
"" load ycm conf by default
let g:ycm_confirm_extra_conf=0
"" turn on tag completion
let g:ycm_collect_identifiers_from_tags_files=1
"" only show completion as a list instead of a sub-window
set completeopt-=preview
"" start completion from the first character
let g:ycm_min_num_of_chars_for_completion=1
"" don't cache completion items
let g:ycm_cache_omnifunc=0
"" complete syntax keywords
let g:ycm_seed_identifiers_with_syntax=1
"" dont interfere with syntastic
let g:ycm_show_diagnostics_ui = 0
"" default location
let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/ycmd/examples/.ycm_extra_conf.py'
let g:ycm_server_python_interpreter = '/usr/bin/python3'

"" syntastic
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0 
let g:syntastic_check_on_wq = 0
let g:syntastic_c_checkers = ['gcc', 'make', 'cppcheck']
let g:syntastic_cpp_checkers = ['gcc', 'make', 'cppcheck']

map <F4> :SyntasticToggleMode<CR>
map <F5> :SyntasticCheck<CR>
"" ultisnips
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<c-a>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

nnoremap <silent> <F2> :TlistToggle<CR>

" nmap <leader>a :tab split<CR>:Ack ""<Left>
" kind of giving a go to reference feeling
nmap <C-g> :tab split<CR>:Ack --type cc --type cpp <cword><CR>
" wintabs
"for buffers
map <C-Left> <Plug>(wintabs_previous)
map <C-Right> <Plug>(wintabs_next)
map <C-k> <Plug>(wintabs_close)
noremap <F9> :WintabsAllBuffers<CR>

" to open the search view - Ctrlp
nnoremap <F6> :CtrlP<CR>
let g:ctrlp_max_depth = 40
let g:ctrlp_mruf_max = 250
let g:ctrlp_max_files = 1000000

" Session manager
let g:session_default_to_last = 1
let g:session_autosave = 'yes'

set number
set numberwidth=2
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE

" Airline theme
let g:airline_theme='dark_minimal'

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" air-line
let g:airline_powerline_fonts = 1

" airline symbols
let g:airline_symbols.linenr = ' ☰ '
let g:airline_symbols.colnr = ' :'
let g:airline_symbols.maxlinenr = ' ln '

" GutenTags
let g:gutentags_generate_on_missing = 0
let g:gutentags_generate_on_new = 0
let g:gutentags_generate_on_write = 0

set conceallevel=2
let g:vim_markdown_borderless_table = 0

" get rid of some strange escape sequence whem airline is present
set t_RV=
