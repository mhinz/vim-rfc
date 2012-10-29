ruby load 'vim-rfc.rb'

function! RFCQuery(query)
ruby << EOF
    VimRFC::Handling.new.search(VIM::evaluate('a:query'))
EOF
endfunction
