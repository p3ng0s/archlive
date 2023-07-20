" .vimrc
" Created on: Mon, 20 March 2017
"  ____   __  ____  __
" (  _ \ /. |(  _ \/  )
"  )___/(_  _))___/ )(
" (__)    (_)(__)  (__)
"
" Description
"  Config for my vim
"  It set tabs colorscheme and much more
"
" Leader key:
"  space
"
" Important bindins:
"  No arrows only h, j, k, l
"  <Leader><Tab>   -> go to next instance of <..>
"  <F2>            -> copy file to clip board
"  <F3>            -> show the current working directory and list files
"  <F5>            -> run current file (if supported)
"  <C-w>t          -> open a terminal in vertical split
"  <C-u>           -> source vimrc
"  <Up>            -> resize split
"  <Down>          -> resize split
"  <Left>          -> resize split
"  <Right>         -> resize split
"  <Leader>tn      -> New tab
"  <Leader>nt      -> Next tab
"  <Leader>pt      -> Previous tab
"  <Leader>i       -> open Codi to interpret the code
"  <Leader>e       -> open FZF Files
"  <Leader>f       -> open FZF ripgrep
"  <Leader>C       -> open FZF colorschemes
"  <Leader>v       -> open netrw
"  <Leader>gb      -> open git blame
"  <Leader>s       -> set spell
"  <Leader>l       -> open latex previewer
"  <Leader>hd      -> Go in hexdump mode (using xxd)
"  <Leader>hb      -> Revert from hexdump mode (using xxd)
"  <Leader>e64     -> encode selected to b64
"  <Leader>d64     -> deconde selected to 64
"  <Leader>y       -> cut selection to clip board
"  <Leader>?       -> Open ALEDetail to help for syntax
"  <Enter>         -> Open Goyo with spell and Limelight
"  J               -> move current line up
"  K               -> move current line down
"
" Custom arguments:
"  vim term        -> launches vim in terminal mode
"  vim xss         -> launches vim in xss bomb mode
"

let mapleader = " "
colorscheme quantum
filetype plugin on
syntax on

" miscs :
set nocompatible
set wildmenu

set background=dark
set colorcolumn=80
set cursorline
set ruler
set relativenumber

set noexpandtab
set autoindent
set incsearch

set nowrap

set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<
set encoding=UTF-8
set list

" which key
nnoremap <silent> <leader> :<c-u>WhichKey ' '<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual ' '<CR>
" Color and tabs :
" Allow transparent background
hi Normal ctermbg=NONE guibg=NONE

" True colors
if (has("termguicolors"))
	set t_8f=[38;2;%lu;%lu;%lum
	set t_8b=[48;2;%lu;%lu;%lum
	set termguicolors
endif

" set transparent bg for onedark
if (has("autocmd") && !has("gui_running"))
	augroup colorset
		autocmd!
		let s:white = { "gui": "#ABB2BF", "cterm": "145", "cterm16" : "7" }
		autocmd ColorScheme * call onedark#set_highlight("Normal", { "fg": s:white })
	augroup END
endif

" Theme state
let g:forest_night_disable_italic_comment = 1
let g:forest_night_transparent_background = 1

let g:miramare_disable_italic_comment = 1
let g:miramare_transparent_background = 1

let g:onedark_transparent_background = 1
let g:dracula_transparent_background = 1

let g:quantum_black=1

let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme = "quantum"

let g:limelight_conceal_ctermfg = 100
let g:limelight_conceal_guifg = '#83a598'
let g:goyo_width = 90

let g:netrw_liststyle=3
let g:netrw_altv=1
let g:netrw_banner=0
let g:netrw_browse_split=4
let g:netrw_winsize=25

let g:blog_author = "p4p1"
let g:blog_url = "https://leosmith.xyz/blog/"

let g:xss_bomb_url = "https:/localhost:8000"
"let g:xss_bomb_url = "https:/leosmith.xyz:8000"

let g:livepreview_previewer = 'zathura'

let g:ale_sign_error = '✘'
let g:ale_sign_warning = '⚠'
highlight ALEErrorSign ctermbg=NONE ctermfg=red
highlight ALEWarningSign ctermbg=NONE ctermfg=yellow


" line number for inside of insert mode or not
autocmd InsertEnter * :set nornu nolist nu
autocmd InsertLeave * :set relativenumber list

" Set Limelight with Goyo
autocmd User GoyoEnter Limelight
autocmd User GoyoEnter set spell
autocmd User GoyoLeave Limelight!
autocmd User GoyoLeave set spell!

" Buffers
nnoremap <Leader>nn <C-^>

" display on the left a netrw page
vnoremap <Leader>v <Esc>:Vexplore<CR>lv
nnoremap <Leader>v <Esc>:Vexplore<CR>

" Git fugitive
nnoremap <Leader>gs <Esc>:G<CR>
vnoremap <Leader>gs <Esc>:G<CR>
nnoremap <Leader>go <Esc>:Gcommit<CR>
vnoremap <Leader>go <Esc>:Gcommit<CR>
nnoremap <Leader>gc <Esc>:GCheckout<CR>
vnoremap <Leader>gc <Esc>:GCheckout<CR>
nnoremap <Leader>gl <Esc>:Gclog<CR>
vnoremap <Leader>gl <Esc>:Gclog<CR>
nnoremap <Leader>gp <Esc>:Gpush<CR>
vnoremap <Leader>gp <Esc>:Gpush<CR>
" display on the left git blame
vnoremap <Leader>gb <Esc>:Git blame<CR>
nnoremap <Leader>gb <Esc>:Git blame<CR>

" hexdump mode
nnoremap <Leader>hd <Esc>:%!xxd<CR>
vnoremap <Leader>hd <Esc>:%!xxd<CR>
nnoremap <Leader>hb <Esc>:%!xxd -r<CR>
vnoremap <Leader>hb <Esc>:%!xxd -r<CR>

" base64
vnoremap <Leader>e64 !base64<CR>
vnoremap <Leader>d64 !base64 --decode<CR>

" json web token
vnoremap <Leader>ejwt !base64 \| sed s/\+/-/g \| sed "s/\//_/g" \| sed -E s/=+$//<CR>

" yank to clip board
vnoremap <Leader>y !xclip -selection clipboard<CR>

" Commands based of pluggins
noremap  <Leader><Enter> :Goyo<CR>
noremap  <Leader>i :Codi<CR>
noremap  <Leader>? :ALEDetail<CR>
noremap  <Leader>e :Files<CR>
noremap  <Leader>f :Rg<CR>
noremap  <Leader>C :Colors<CR>
noremap  <Leader>l :LLPStartPreview<CR>

" disable arrow keys
inoremap <Up> <NOP>
inoremap <Down> <NOP>
inoremap <Left> <NOP>
inoremap <Right> <NOP>
vnoremap <Up> <NOP>
vnoremap <Down> <NOP>
vnoremap <Left> <NOP>
vnoremap <Right> <NOP>
noremap  <Up> <NOP>
noremap  <Down> <NOP>
noremap  <Left> <NOP>
noremap  <Right> <NOP>

" Buggy vim send help
inoremap ^? <C-H>
set noerrorbells
set novisualbell

" default tabs
set shiftwidth=4
set tabstop=4

" undo dir folder and backup folder:
if !isdirectory("/tmp/undodir/")
	call mkdir("/tmp/undodir/", "p")
endif
if !isdirectory("/home/p4p1/.vim_backup/")
	call mkdir("/home/p4p1/.vim_backup/", "p")
endif
set undodir=/tmp/undodir
set backupdir=~/.vim_backup
set undofile

" General commands :
nnoremap <Leader><Tab> <Esc>/<..><CR>"_c4l
nnoremap J :m+1<CR>
nnoremap K :m-2<CR>
map <F3> :!pwd&&ls<CR>
map <F2> :! cat % \| xclip -selection clipboard<CR>
map <C-w>t <Esc>:vs<Esc>:terminal<CR><C-W>k:q<CR>
map <Leader>s <Esc>:set spell!<CR>
map <C-u> :source ~/.vimrc<CR>

" Tab control
map <Leader>tn :tabnew<CR>
map <Leader>nt :tabnext<CR>
map <Leader>pt :tabprevious<CR>

" undo and redo
noremap u :undo<CR>

" splits
set splitbelow splitright
noremap <Left> :vertical resize -3<CR>
noremap <Right> :vertical resize +3<CR>
noremap <Up> :resize +3<CR>
noremap <Down> :resize -3<CR>

" <============= Execute =====================>
autocmd FileType lisp map <F5> :!clisp %<CR>
autocmd FileType python map <F5> :!python %<CR>
autocmd FileType sh map <F5> :!bash %<CR>
autocmd FileType html map <F5> :!$($BROWSER %)<CR>
autocmd FileType c map <F5> :!make<CR>

" <============= Vim custom arguments ========>
autocmd BufNewFile term terminal++curwin

" <============= Vim custom arguments ========>
autocmd BufNewFile xss call xss_bomb#main()

" <============= File type rules =============>
" C file commands :
autocmd FileType c set noexpandtab
autocmd FileType c set shiftwidth=0
autocmd FileType c set tabstop=4
if expand('%') =~ "tests"
	autocmd BufNewFile tests_*.c so ~/.vim/template/test_c.header
else
	autocmd BufNewFile *.c so ~/.vim/template/dot_c.header
endif
autocmd bufnewfile *.c exe "g/current-file-name.*/s//" .expand("%")

" CPP file commands :
autocmd FileType cpp set noexpandtab
autocmd FileType cpp set shiftwidth=0
autocmd FileType cpp set tabstop=4
if expand('%') =~ "tests"
	autocmd BufNewFile tests_*.cpp so ~/.vim/template/test_c.header
else
	autocmd BufNewFile *.cpp so ~/.vim/template/dot_c.header
endif
autocmd bufnewfile *.cpp exe "g/current-file-name.*/s//" .expand("%")

" Make file commands :
autocmd FileType make set noexpandtab
autocmd FileType make set tabstop=4
autocmd FileType make set shiftwidth=0
autocmd bufNewFile Makefile so ~/.vim/template/makefile.template
autocmd bufnewfile Makefile exe "g/current-file-name.*/s//" .expand("%")

" Assembly files
autocmd FileType asm set noexpandtab
autocmd FileType asm set tabstop=8
autocmd FileType asm set shiftwidth=0

" Header file:
autocmd BufNewFile *.h so ~/.vim/template/dot_h.header
autocmd bufnewfile *.h exe "g/current-file-name.*/s//" .expand("%")
autocmd BufNewFile *.hpp so ~/.vim/template/dot_h.header
autocmd bufnewfile *.hpp exe "g/current-file-name.*/s//" .expand("%")

" Python file commands :
autocmd BufNewFile *.py so ~/.vim/template/dot_py.header
autocmd bufnewfile *.py exe "g/current-file-name.*/s//" .expand("%")
autocmd FileType python set expandtab
autocmd FileType python set shiftwidth=4
autocmd FileType python set tabstop=4

" Shell file commands :
autocmd BufNewFile *.sh so ~/.vim/template/dot_sh.header
autocmd bufnewfile *.sh exe "g/current-file-name.*/s//" .expand("%")

" Javascript
autocmd FileType javascript set expandtab
autocmd FileType javascript set shiftwidth=2
autocmd FileType javascript set tabstop=2

" html
autocmd FileType html set expandtab
autocmd FileType html set shiftwidth=2
autocmd FileType html set tabstop=2
autocmd BufNewFile *.html call Blog_update_rss_html()

" haskell :
autocmd FileType haskell set expandtab
autocmd FileType haskell set shiftwidth=4
autocmd FileType haskell set tabstop=4

" php
autocmd FileType php set expandtab
autocmd FileType php set shiftwidth=4
autocmd FileType php set tabstop=4

" md
autocmd BufNewFile *.md so ~/.vim/template/dot_md.header
autocmd bufnewfile *.md exe "g/current-file-name.*/s//" .expand("%")
autocmd FileType markdown set noexpandtab
autocmd FileType markdown set shiftwidth=0
autocmd FileType markdown set tabstop=4

" latex files
autocmd Filetype tex setl updatetime=1

" <============= Plug pluggins =============>
call plug#begin('~/.vim/plugged')

" Colors and syntax"
Plug 'ap/vim-css-color'
Plug 'sheerun/vim-polyglot'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'arzg/vim-colors-xcode'
Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
Plug 'mhinz/vim-startify'

" Programming
Plug 'vim-scripts/timestamp.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'w0rp/ale'
Plug 'xuhdev/vim-latex-live-preview', { 'for': 'tex' }
Plug 'junegunn/fzf',{'do':{->fzf#install()}}
Plug 'junegunn/fzf.vim'
Plug 'airblade/vim-rooter'
Plug 'metakirby5/codi.vim'
Plug 'stsewd/fzf-checkout.vim'

" Color / Theme
Plug 'ryanoasis/vim-devicons'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-airline/vim-airline'
Plug 'sainnhe/forest-night'
Plug 'franbach/miramare'
Plug 'tyrannicaltoucan/vim-quantum'
Plug 'dracula/vim',{'as':'dracula'}
Plug 'joshdick/onedark.vim'
Plug 'arcticicestudio/nord-vim'
Plug 'drewtempelmeyer/palenight.vim'

" Movement
Plug 'justinmk/vim-sneak'
Plug 'unblevable/quick-scope'

" Personal pluggin
Plug 'p4p1/vim-blog'
Plug 'p4p1/xss_bomb',{'rtp': 'vim'}

call plug#end()
