" RFC Query
command! -nargs=1 -bar RQ call librfc#rfc_query('<args>')

" RFC Get
command! -nargs=? -bar -count RG e http://www.ietf.org/rfc/rfc<count>.txt | setlocal readonly nomodifiable

" RFC Get Standard
command! -nargs=? -bar -count RGS e http://www.ietf.org/rfc/std/std<count>.txt | setlocal readonly nomodifiable
