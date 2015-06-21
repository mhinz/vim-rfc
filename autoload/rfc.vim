ruby load VIM::evaluate("expand('<sfile>:p:h') . '/../lib/rfc.rb'")

function! rfc#query(rebuild_cache, query) abort
  if !has('ruby')
    echomsg 'vim-rfc: This plugin needs +Ruby support.'
    return
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
    VIM::command('setlocal buftype=nofile bufhidden=wipe statusline=RFC/STD\ documents')

    lnum = 0
    cur = VIM::Buffer.current
    Hash[matches.sort].each_pair do |tag,title|
      cur.append(lnum, "#{tag}: #{title}")
      lnum += 1
    end
    VIM::command('silent $delete _')
    VIM::command('0')
    VIM::command('setlocal buftype=nofile nomodifiable nomodified')
    VIM::command('nnoremap <buffer> <cr> :call <sid>open_entry_by_cr()<cr>')
    VIM::command('nnoremap <buffer> q :close<cr>')
  end
EOF
endfunction

function! s:open_entry_by_cr()
  let [type, id] = matchlist(getline('.'), '^\v(...)0*(\d+)')[1:2]
  silent close
  execute 'silent edit http://www.ietf.org/rfc/'. (type == 'RFC' ? 'rfc' : 'std/std') . id .'.txt'
  setlocal filetype=rfc nomodifiable
  redraw!
endfunction
