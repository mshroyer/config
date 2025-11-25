" Needed for true color to work in tmux-direct

if !has('gui_running') && &term =~ '\%(screen\|tmux\)'
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
set termguicolors
set background=dark

syntax on

" File type settings
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab autoindent

