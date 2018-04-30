" A simple wiki plugin for Vim
"
" Maintainer: Karl Yngve Lervåg
" Email:      karl.yngve@gmail.com
" License:    MIT license
"

function! wiki#url#file#parse(url) abort " {{{1
  let l:url = {}

  function! l:url.open(...) abort dict
    try
      if call(get(g:, 'wiki_file_open', ''), a:000, self)
        return
      endif
    catch 'E117: Unknown function'
      " Pass
    endtry

    execute 'edit' fnameescape(self.path)
  endfunction

  if a:url.stripped[0] ==# '/'
    let l:url.path = a:url.stripped
  elseif a:url.stripped =~# '\~\w*\/'
    let l:url.path = simplify(fnamemodify(a:url.stripped, ':p'))
  else
    let l:url.path = simplify(
          \ fnamemodify(a:url.origin, ':p:h') . '/' . a:url.stripped)
  endif

  return l:url
endfunction

" }}}1
