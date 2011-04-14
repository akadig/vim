" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

if has('win32')
    language messages en
    let vimfiles_dir=expand("$HOME/vimfiles/")
else
    language messages en_US.UTF-8
    let vimfiles_dir=expand("$HOME/.vim/")
endif

" from http://stevelosh.com/blog/2010/09/coming-home-to-vim/

filetype off
if filereadable(vimfiles_dir."autoload/pathogen.vim")
    call pathogen#helptags()
    call pathogen#runtime_append_all_bundles()
endif
filetype plugin indent on

" bit prevents some security exploits 
"set modelines=0
set modeline
set modelines=3

set ttyfast
set gdefault

if version >= 703
    set undofile
endif

set formatoptions=croql
set cinoptions=l1,g0,p0,t0,c0,(s,U1,m1

" save all at focus lost
au FocusLost * :wa

" end stevelosh

if has("vms")
    set nobackup    " do not keep a backup file, use versions instead
else
    set backup      " keep a backup file
endif
set history=250     " keep 250 lines of command line history
set ruler           " show the cursor position all the time

" Don't use Ex mode, use Q for formatting
map Q gq

set number
"set relativenumber

if has('win32') || has('gui')
    set t_Co=256    " использовать больше цветов в терминале
endif
if &t_Co > 2
    syntax enable
    set hlsearch
endif

if !(has('gui') || has('win32')) && filereadable(vimfiles_dir.'bundle/robokai/colors/robokai.vim')
    colorscheme robokai
    highlight Normal  ctermfg=gray   ctermbg=black guifg=#c0c0c0 guibg=#000040          
    if &term == "xterm"
        highlight StatusLine ctermfg=black ctermbg=white term=bold
    else
        highlight StatusLine ctermfg=black term=bold
    endif
    " from darkblue
    hi Visual		guifg=#8080ff guibg=fg		gui=reverse				ctermfg=lightblue ctermbg=fg cterm=reverse
    hi VisualNOS	guifg=#8080ff guibg=fg		gui=reverse,underline	ctermfg=lightblue ctermbg=fg cterm=reverse,underline
    "
    highlight Class ctermfg=DarkYellow
    highlight LocalVariable ctermfg=DarkGrey
    
elseif has('gui') && filereadable(vimfiles_dir.'bundle/darkz/colors/darkz.vim')
    colorscheme darkz
elseif has('gui') && filereadable(vimfiles_dir.'bundle/lucius/colors/lucius.vim')
    colorscheme lucius
elseif filereadable(expand("$VIMRUNTIME/colors/darkblue.vim"))
    colorscheme darkblue
    " немного "доведем до ума" схему
    if has('gui')
        highlight StatusLine ctermfg=black ctermbg=blue term=bold guifg=darkblue guibg=darkgrey gui=bold
    else
        if !has('win32')
            if &term == "xterm"
                highlight StatusLine ctermfg=blue term=bold
            else
                highlight StatusLine ctermfg=black term=bold
            endif
        endif
        highlight Comment term=bold ctermfg=3 gui=italic guifg=gray50 
    endif
    highlight lCursor ctermfg=yellow ctermbg=red   guifg=NONE    guibg=cyan
endif

" Показываем табы в начале строки точками
"set listchars=tab:··i
"set listchars=tab:»\ ,trail:·,eol:¶
"set list

" change rus-las with Ctrl-^
if filereadable(expand("$VIMRUNTIME/keymap/russian-jcukenwin.vim"))
    set keymap=russian-jcukenwin
endif
"setlocal spell spelllang=ru_yo,en_us
" циклическое переключение спелл-чекера (взято с www.opennet.ru/base/X/vim_orfo.txt.html)
if version >= 700 && has("spell")
"   По умолчанию проверка орфографии выключена.
    setlocal spell spelllang=
    setlocal nospell
    "
    function ChangeSpellLang()
        if &spelllang =~ "en_us"
            setlocal spell spelllang=ru
            echo "spelllang: ru"
        elseif &spelllang =~ "ru"
            setlocal spell spelllang=
            setlocal nospell
            echo "spelllang: off"
        else
            setlocal spell spelllang=en_us
            echo "spelllang: en"
        endif
    endfunc

    " map spell on/off for English/Russian
    map <F11> <Esc>:call ChangeSpiellLang()<CR>
    " limit it to just the top 10 items
    set sps=best,10 
endif
" по умолчанию латинская раскладка
set iminsert=0
" по умолчанию поиск латиницей
set imsearch=0
set tabstop=4
set shiftwidth=4
set autoindent smartindent
set smarttab
set expandtab
" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" граница переноса
set wrapmargin=5
" подсветим 85ю колонку
if version >= 703
    set colorcolumn=85
endif
" автоматический перенос после 128 колонки
set textwidth=128
" сколько строк повторять при скроллинге
set scrolloff=4
" подсветка строки и колонки курсора
if version >= 700
    set cursorline
endif
"set cursorcolumn
set visualbell
" миннимальная высота окна
set winminheight=1
" делать активное окон максимального размера
set noequalalways
set winheight=999

set incsearch        " do incremental searching
set ignorecase
set smartcase

" http://dimio-blog.livejournal.com/16376.html

set hidden          " не выгружать буфер когда переключаешься на другой
if has("mouse")
    set mouse=a         " включает поддержку мыши при работе в терминале (без GUI)
    set mousehide       " скрывать мышь в режиме ввода текста
endif
set showcmd         " показывать незавершенные команды в статусбаре (автодополнение ввода)
set matchpairs+=<:> " показывать совпадающие скобки для HTML-тегов
set showmatch       " показывать первую парную скобку после ввода второй
set autoread        " перечитывать изменённые файлы автоматически
set confirm         " использовать диалоги вместо сообщений об ошибках

" Автоматически перечитывать конфигурацию VIM после сохранения
autocmd! BufWritePost $MYVIMRC source $MYVIMRC

" Прыгать на последнюю позицию при открытии буфера
autocmd! BufReadPost * call LastPosition()
autocmd! BufReadPost * call UpdateFileInfo()
"
function! LastPosition()
    " не меняем позицию при коммите 
    if expand("<afile>:s? \d+??") != '.git\COMMIT_EDITMSG'
        if expand("<afile>:t") != ".git" && line("'\"")<=line('$')
            normal! `"
        endif
    endif
endfunction

function! UpdateFileInfo()
    if exists("g:loaded_ctags_highlighting")
        UpdateTypesFile
    endif
endfunction

if version >= 700
    " опции сессий - перейти в текущию директорию, использовать буферы и табы
    set sessionoptions=curdir,buffers,help,options,resize,slash,tabpages,winpos,winsize 
else
    set sessionoptions=curdir,buffers,help,options,resize,slash,winpos,winsize
endif

" При вставке фрагмента сохраняет отступы
"set pastetoggle=

"Настройки сворачивания блоков кода (фолдинг)
set foldenable " включить фолдинг
set foldmethod=syntax " определять блоки на основе синтаксиса файла
set foldcolumn=3 " показать полосу для управления сворачиванием
set foldlevel=7 " Первый уровень вложенности открыт, остальные закрыты
let perl_folding=1 " правильное сворачивание классов и функций Perl
"let php_folding=1 " правильное сворачивание классов и функций PHP
"set foldopen=all " автоматическое открытие сверток при заходе в них

nnoremap    -   zc
nnoremap    +   zo

" Для указанных типов файлов отключает замену табов пробелами и меняет ширину отступа
au FileType crontab,fstab,make set noexpandtab tabstop=8 shiftwidth=8

"" Применять типы файлов
filetype on
filetype plugin on
filetype indent on
"" Если сохраняемый файл является файлом скрипта - сделать его исполняемым
"" au BufWritePost * if getline(1) =~ "^#!.*/bin/"|silent !chmod a+x %|endif
"" При открытии файла задавать для него соответствующий 'компилятор'
autocmd! BufEnter *.pl compiler perl

"" Переключение кодировок файла
set wildmenu
set wcm=<Tab>
menu Encoding.CP1251   :e ++enc=cp1251<CR>
menu Encoding.CP866    :e ++enc=cp866<CR>
menu Encoding.KOI8-U   :e ++enc=koi8-u<CR>
menu Encoding.UTF-8    :e ++enc=utf-8<CR>
map <F8> :emenu Encoding.<TAB>

" end dimio-blog

set lazyredraw

"set encoding=cp1251
"set termencoding=utf-8
set fileencodings=utf-8,cp1251,koi8-r,cp866
set fileformats=unix,dos,mac " формат файла по умолчанию (влияет на окончания строк) - будет перебираться в указанном порядке

" Ловля имени редактируемого файла из vim'а. (^[ вводится как Ctrl+V Esc)
set title
"set titlestring=%t-dsd
"set titleold=&titlestring
" screen:
"set titlestring=%t
"set titleold=bash
let &titlestring = "vim (" . expand("%:t") . ")"
if &term == "screen"
    set t_ts=k
    set t_fs=\
endif
if &term == "screen" || &term == "xterm"
    set title
endif

autocmd! BufEnter * call NextTabOpened()
"
function! NextTabOpened()
    let &titlestring = "vim (" . expand("%:t") . ")"
endfunction

if !has("gui_running")
    set mouse=a
endif

if has('gui')
    " For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
    if has('win32')
        let &guioptions = substitute(&guioptions, "t", "", "g")
    endif
    set guioptions-=T " отключить тулбар в GUI
    "set guioptions-=m " отключить меню  
    au GUIEnter * :set lines=99999 columns=99999
endif
" В разных графических системах используем разные шрифты:
if has('win32')
    set guifont=Lucida_Console:h11:cRUSSIAN::
    behave xterm
else
    set guifont=Terminus\ 14
endif

" сохраняемся по F2
nmap <F2> <ESC>:w<CR>
imap <F2> <ESC>:w<CR>i<Right>
" F6/F7 - предыдущая/следующая ошибка
nmap <F6> <ESC>:cp<CR>
imap <F6> <ESC>:cp<CR>
nmap <F7> <ESC>:cn<CR>
imap <F7> <ESC>:cn<CR>
" ?
inoremap <silent> <C-u> <ESC>u:set paste<CR>.:set nopaste<CR>gi

function! SyntaxItem()
    return synIDattr(synID(line("."),col("."),1),"name")
endfunction

if has('statusline')
    set statusline=%f\                  " filename
    set statusline+=%L                  " lines in buffer
    set statusline+=%y                  " type of file 
    set statusline+=%r\                 " read-only flag
    set statusline+=[%{&ff}]            " file type - unix/win e.t.c.
    set statusline+=[%{&fenc}]\         " file encoding
    set statusline+=%{SyntaxItem()}     " syntax item
    set statusline+=%=%m\               " modified flag
    set statusline+=%-15(0x%02B\ (%b)%) " byte under cursor, hex+decimal
    set statusline+=%-15(%l,%c%V%)      " line number + column/virtual column 
    set statusline+=%P                  " percentage
endif
" %{GitBranch()}\ 
set laststatus=2

" tab navigation like firefox
if version >= 700
    nmap <C-S-Tab> :tabprevious<cr>
    nmap <C-Tab> :tabnext<cr>
    map <C-S-Tab> :tabprevious<cr>
    map <C-Tab> :tabnext<cr>
    imap <C-S-Tab> <ESC>:tabprevious<cr>i
    imap <C-Tab> <ESC>:tabnext<cr>i
    nnoremap <C-n> :tabnew<cr>
    inoremap <C-t> <ESC>:tabnew<cr>
"    nnoremap <C-S-w> :tabclose<cr>
    inoremap <C-w> <ESC>:tabclose<cr>
    nmap Z :tabprev<cr>
    nmap X :tabnext<cr>
endif

"ino <tab> <c-r>=TriggerSnippet()<cr>
"snor <tab> <esc>i<right><c-r>=TriggerSnippet()<cr>

" хранить swap-файлы будем в одном месте, чтобы не мешались
let swap_dir=vimfiles_dir.'swapfiles/'

if !isdirectory(swap_dir) && exists('*mkdir')
    call mkdir(swap_dir)
endif

if isdirectory(swap_dir)
    let &directory=swap_dir.'/'
endif

" dvg - end
" vim: ts=4 sw=4
" end of file
