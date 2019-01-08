if exists('g:loaded_rfc') || &compatible
  finish
endif

command! -nargs=? -bar -bang RFC call rfc#query(<bang>0, '<args>')

let g:loaded_rfc = 1
