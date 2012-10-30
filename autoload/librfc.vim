ruby load VIM::evaluate("expand('<sfile>:p:h') . '/../plugin/rfc/rfc.rb'")

function! librfc#rfc_query(query) abort
    ruby << EOF
        ret = VimRFC::Handling.new.search(VIM::evaluate('a:query'))
        Hash[ret.sort].each_pair do |k,v|
            puts "#{k}: #{v}"
        end
EOF
endfunction
