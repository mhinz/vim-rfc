let s:load_error = 0
try
  execute 'rubyfile' expand('<sfile>:p:h') . '/../lib/rfc.rb'
catch /LoadError/
  let s:load_error = 1
endtry

function! rfc#query(rebuild_cache, query) abort
  if !has('ruby')
    echomsg 'vim-rfc: This plugin needs +Ruby support.'
    return
  endif

  if s:load_error
    echomsg 'vim-rfc: Please install the "nokogiri" gem and restart Vim.'
    return
  endif

  if bufexists('vim-rfc')
    if bufname('') == 'vim-rfc'
      close
    else
      silent bdelete vim-rfc
    endif
  endif

  ruby << EOF
  matches = VimRFC::Handling.new(VIM::evaluate('a:rebuild_cache')).search(VIM::evaluate('a:query'))

  size = matches.length
  if size == 0
    VIM::command('redraw | echo "Nothing found."')
  else
    if size > 10
      size = 10
    end
    VIM::command("#{size}new")
    lnum = 0
    cur = VIM::Buffer.current
    Hash[matches.sort].each_pair do |tag,title|
      cur.append(lnum, "#{tag}: #{title}")
      lnum += 1
    end
    VIM::command('call <sid>setup_window()')
    VIM::command('call feedkeys("\<cr>", "t")') if size == 1
  end
EOF
endfunction

function! s:setup_window()
  silent $delete _
  silent file vim-rfc
  setlocal nomodifiable nomodified
  setlocal buftype=nofile bufhidden=wipe nowrap
  if empty(&statusline)
    setlocal statusline=\ RFC/STD\ documents
  endif
  nnoremap <silent><buffer> <cr> :call <sid>open_entry_by_cr()<cr>
  nnoremap <silent><buffer> q :close<cr>
  syntax match  RFCTitle /.*/                 contains=RFCStart
  syntax match  RFCStart /\v^\u{3}\d+:/       contains=RFCType,RFCID,RFCDelim contained
  syntax region RFCType  start=/^/ end=/^.../ contained
  syntax match  RFCID    /\d\+/               contained
  syntax match  RFCDelim /:/                  contained
  highlight link RFCTitle Title
  highlight link RFCType  Identifier
  highlight link RFCID    Number
  highlight link RFCDelim Delimiter
  0
endfunction

function! s:open_entry_by_cr()
  let [type, id] = matchlist(getline('.'), '^\v(...)0*(\d+)')[1:2]
  silent close
  let url = 'https://www.ietf.org/rfc/'.(type == 'RFC' ? 'rfc' : 'std/std').id.'.txt'
  ruby << EOF
  require 'open-uri'
  body = URI.parse(VIM::eval('url')).read
  VIM::command("enew | append #{body}")
  VIM::command('0')
EOF
  setlocal filetype=rfc nomodified nomodifiable
  let cmd = bufexists(url) ? 'edit' : 'file'
  execute 'silent' cmd url
endfunction
