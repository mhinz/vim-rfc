" RFC Query
com! -nargs=1 -bar RQ call librfc#rfc_query('<args>')

" RFC Get
com! -nargs=? -bar -count RG e http://www.ietf.org/rfc/rfc<count>.txt | setl ro noma

" RFC Get Standard
com! -nargs=? -bar -count RGS e http://www.ietf.org/rfc/std/std<count>.txt | setl ro noma
