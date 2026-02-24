" =============================================================================
" vim.tiny ultra-minimal config
" =============================================================================

set nocompatible

" --- Basic behavior ---
set mouse=
set noswapfile
set nowrap
set ignorecase
set smartindent

" --- Line Numbers ---
set number
" Show absolute line number on current line

set relativenumber
" Show relative numbers on all other lines
" (great for motions like 5j, 3k, etc.)

set tabstop=2
set shiftwidth=2

" --- Keymaps (comma used as leader replacement) ---

" Tabs
nnoremap ,t :tabnew<CR>
nnoremap ,x :tabclose<CR>

nnoremap ,1 1gt
nnoremap ,2 2gt
nnoremap ,3 3gt
nnoremap ,4 4gt
nnoremap ,5 5gt
nnoremap ,6 6gt
nnoremap ,7 7gt
nnoremap ,8 8gt

" Edit vimrc
nnoremap ,v :edit ~/.vimrc<CR>

" Write / Quit
nnoremap ,w :update<CR>
nnoremap ,q :quit<CR>
nnoremap ,Q :wqa<CR>

" Center scrolling after movement
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap n nzzzv
nnoremap N Nzzzv

" Resize window
nnoremap <M-n> :resize +2<CR>
nnoremap <M-e> :resize -2<CR>

" Insert-mode date/time helpers
inoremap <C-r><C-d> <C-r>=strftime('%F')<CR>
inoremap <C-r><C-t> <C-r>=strftime('%T')<CR>
