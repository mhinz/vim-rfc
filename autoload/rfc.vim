let s:has_python3 = 1

function! rfc#query(create_cache_file, query) abort
  if !s:has_python3 
    echomsg 'vim-rfc: This plugin requires +python3 support for :python3 and py3eval().'
    if has('nvim')
      echomsg 'Run ":checkhealth provider" for further diagnosis.'
    endif
    return
  endif

  if bufexists('vim-rfc')
    if bufname('') == 'vim-rfc'
      close
    else
      silent bdelete vim-rfc
    endif
  endif

  if a:create_cache_file || !filereadable($HOME.'/.vim-rfc.txt')
    echo 'Fetching RFC index... (takes a few seconds)' | redraw
    if !py3eval('create_cache_file()')
      return
    endif
    echo
  endif

  belowright 12new
  silent read ~/.vim-rfc.txt
  silent 1delete _
  call s:setup_window()

  if !empty(a:query)
    call search(a:query)
  endif
endfunction

function! s:setup_window()
  silent $delete _
  silent file vim-rfc
  setlocal nomodifiable nomodified winfixheight
  setlocal buftype=nofile bufhidden=wipe nowrap
  setlocal nonumber norelativenumber foldcolumn=0 signcolumn=no
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
  highlight link RFCTitle Normal
  highlight link RFCType  Identifier
  highlight link RFCID    Number
  highlight link RFCDelim Delimiter
  0
endfunction

" Check only now for Python3 support, so that rfc#query() is guaranteed to exist.
if !has('python3')
  let s:has_python3 = 0
  finish
endif

function! s:open_entry_by_cr()
  let [type, id] = matchlist(getline('.'), '^\v(...)0*(\d+)')[1:2]
  silent close
  let url = 'https://www.ietf.org/rfc/'.(type == 'RFC' ? 'rfc' : 'std/std').id.'.txt'
  if bufloaded(url)
    execute 'silent edit' url
  else
    echo 'Fetching RFC...' | redraw
    if !py3eval('fetch_rfc("'.url.'")')
      return
    endif
    echo
    0
    setlocal filetype=rfc nomodified nomodifiable
    execute 'silent file' url
  endif
endfunction

python3 << EOF
def fetch_rfc(url):
  import urllib.request
  try:
    rfc = urllib.request.urlopen(url).read().decode('utf-8').splitlines()
  except urllib.request.URLError as e:
    print(f'{e}\nFetching RFC failed. Connected to the internet? Behind proxy?')
    return False
  vim.command('enew')
  vim.current.buffer[:] = rfc
  return True

def create_cache_file():
  import sys
  import os
  import urllib.request
  import xml.etree.ElementTree as ET

  try:
    xml = urllib.request.urlopen('https://www.rfc-editor.org/in-notes/rfc-index.xml').read()
  except urllib.error.URLError as e:
    print(f'{e}\nFetching RFC index failed. Connected to the internet? Behind proxy?')
    return False

  root = ET.fromstring(xml)

  # 3.8 introduced the any-ns syntax: '{*}tag',
  # but let's go the old way for compatability.
  ns = {'ns': 'http://www.rfc-editor.org/rfc-index'}

  with open(os.path.expanduser('~/.vim-rfc.txt'), 'w') as f:
    for entry in root.findall('ns:rfc-entry', ns):
      id = entry.find('ns:doc-id', ns).text
      title = entry.find('ns:title', ns).text
      f.write(f"{id}: {title}\n")

    for entry in root.findall('ns:std-entry', ns):
      id = entry.find('ns:doc-id', ns).text
      title = entry.find('ns:title', ns).text
      f.write(f"{id}: {title}\n")

  return True
EOF
