" A simple wiki plugin for Vim
"
" Maintainer: Karl Yngve Lervåg
" Email:      karl.yngve@gmail.com
"

function! wiki#rx#surrounded(word, chars) abort " {{{1
  return '\%(^\|\s\|[[:punct:]]\)\@<='
        \ . '\zs'
        \ . escape(a:chars, '*')
        \ . a:word
        \ . escape(join(reverse(split(a:chars, '')), ''), '*')
        \ . '\ze'
        \ . '\%([[:punct:]]\|\s\|$\)\@='
endfunction

" }}}1

let wiki#rx#word = '[^[:blank:]!"$%&''()*+,:;<=>?\[\]\\^`{}]\+'
let wiki#rx#pre_beg = '^\s*```'
let wiki#rx#pre_end = '^\s*```\s*$'
let wiki#rx#super = '\^[^^`]\+\^'
let wiki#rx#sub = ',,[^,`]\+,,'
let wiki#rx#list_define = '::\%(\s\|$\)'
let wiki#rx#comment = '^\s*%%.*$'
let wiki#rx#todo = '\C\<\%(TODO\|STARTED\|FIXME\)\>:\?'
let wiki#rx#done = '\C\<\%(OK\|DONE\|FIXED\)\>:\?'
let wiki#rx#header = '^#\{1,6}\s*[^#].*'
let wiki#rx#header_items = '^\(#\{1,6}\)\s*\([^#].*\)\s*$'
let wiki#rx#bold = wiki#rx#surrounded(
      \ '[^*`[:space:]]\%([^*`]*[^*`[:space:]]\)\?', '*')
let wiki#rx#italic = wiki#rx#surrounded(
      \ '[^_`[:space:]]\%([^_`]*[^_`[:space:]]\)\?', '_')
let wiki#rx#date = '\d\d\d\d-\d\d-\d\d'
let wiki#rx#url = '\<\l\+:\%(\/\/\)\?[^ \t()\[\]|]\+'
let wiki#rx#reftext = '[^\\\[\]]\{-}'
let wiki#rx#reftarget = '\%(\d\+\|\a[-_. [:alnum:]]\+\)'
let wiki#rx#link_md = '\[[^\\\[\]]\{-}\]([^\\]\{-})'
let wiki#rx#link_adoc = '<<[^#]\{-}#,[^>]\{-}>>'
let wiki#rx#link_md_fig = '!' . wiki#rx#link_md
let wiki#rx#link_ref_single = '[\]\[]\@<!\[' . wiki#rx#reftarget . '\][\]\[]\@!'
let wiki#rx#link_ref_double =
      \ '[\]\[]\@<!'
      \ . '\[' . wiki#rx#reftext   . '\]'
      \ . '\[' . wiki#rx#reftarget . '\]'
      \ . '[\]\[]\@!'
let wiki#rx#link_ref_target =
      \ '^\s*\[' . wiki#rx#reftarget . '\]:\s\+' . wiki#rx#url
let wiki#rx#link_shortcite = '\%(\s\|^\|\[\)\zs@[-_a-zA-Z0-9]\+\>'
let wiki#rx#link_wiki = '\[\[\/\?[^\\\]]\{-}\%(|[^\\\]]\{-}\)\?\]\]'
let wiki#rx#link = join([
      \ wiki#rx#link_wiki,
      \ wiki#rx#link_adoc,
      \ '!\?' . wiki#rx#link_md,
      \ wiki#rx#link_ref_target,
      \ wiki#rx#link_ref_single,
      \ wiki#rx#link_ref_double,
      \ wiki#rx#url,
      \ wiki#rx#link_shortcite,
      \], '\|')
