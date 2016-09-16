" wiki
"
" Maintainer: Karl Yngve Lervåg
" Email:      karl.yngve@gmail.com
"

function! wiki#template#weekly_summary(year, week) " {{{1
  let l:parser = s:summary.new()

  call append(0,
        \ ['# Samandrag veke ' . a:week . ', ' . a:year]
        \ + l:parser.parse(wiki#date#get_week_dates(a:week, a:year)))

  call setpos('.', [0, 3, 0, 0])
endfunction

" }}}1
function! wiki#template#monthly_summary(year, month) " {{{1
  let l:parser = s:summary.new()

  let l:links = wiki#date#get_month_decomposed(a:month, a:year)

  call append(0,
        \ ['# Samandrag frå ' . wiki#date#get_month_name(a:month) . ' ' . a:year]
        \ + l:parser.parse(l:links))

  call setpos('.', [0, 3, 0, 0])
endfunction

" }}}1

" {{{1 Summary parser

function! s:sort_by_strlen(str1, str2) " {{{2
  return strlen(a:str1) > strlen(a:str2)
        \ ? -1
        \ : strlen(a:str1) == strlen(a:str2)
        \   ? 0
        \   : 1
endfunction

" }}}2

let s:summary = {}
let s:summary.projects = [
      \ 'Diverse',
      \ 'Leiested',
      \ 'Tekna',
      \ 'Sommerjobb-administrasjon',
      \ '3dmf',
      \ 'NanoHX',
      \ 'FerroCool',
      \ 'FerroCool 2',
      \ 'RPT',
      \]
let s:summary.regex_title = join(
      \ sort(copy(s:summary.projects), function('s:sort_by_strlen')), '\|')

function! s:summary.new() dict " {{{2
  return deepcopy(self)
endfunction

" }}}2
function! s:summary.parse(links) dict " {{{2
  let self.links = map(filter(copy(a:links),
        \   'filereadable(v:val . ''.wiki'')'),
        \ '''journal:'' . v:val')

  let self.entries = map(copy(self.links), 'self.parse_link(v:val)')
  let self.lines = self.combine_entries()

  return [''] + self.links + self.lines
endfunction

" }}}2
function! s:summary.parse_link(link) dict " {{{2
  let l:link = wiki#url#parse(a:link)

  let l:entries = {}
  let l:new_entry = 1
  let l:title = ''
  let l:lines = []
  let l:lnum = 0
  for l:line in readfile(l:link.path)
    let l:lnum += 1

    "
    " Ignore everything after title lines (except in weekly summaries)
    "
    if l:line =~# '^\#'
      if l:lnum > 1 | break | endif
      continue
    endif

    "
    " Empty lines separate entries
    "
    if l:line =~# '^\s*$'
      if !empty(l:lines)
        let l:entries[l:title] = l:lines
      endif
      let l:ignore = 0
      let l:new_entry = 1
      let l:title = ''
      let l:lines = []
      continue
    endif

    "
    " Ignore time tables
    "
    if l:line =~# '^\*Timeoversikt\|^\s*|-\+'
      let l:ignore = 1
    endif

    if l:ignore | continue | endif

    "
    " Detect header of entries
    "
    if l:new_entry
      if l:line =~# self.regex_title
        let l:new_entry = 0
        let l:title = matchstr(l:line, self.regex_title)
        call add(l:lines, l:line)
      endif
      continue
    endif

    if !empty(l:title)
      " Fix pure-anchor links
      if l:link.stripped =~# '\d\{4}-\d\d-\d\d'
        let l:line = substitute(l:line, '\(\[\[\|\](\)\zs\ze\#',
              \ fnamemodify(l:link.path, ':t:r'), 'g')
      endif
      call add(l:lines, l:line)
    endif
  endfor

  return l:entries
endfunction

" }}}2
function! s:summary.combine_entries() dict " {{{2
  let l:lines = []
  for l:project in self.projects
    let l:first = 1
    for l:entry in self.entries
      if has_key(l:entry, l:project)
        if l:first
          let l:lines += ['']
          let l:lines += l:entry[l:project]
        else
          let l:lines += l:entry[l:project][1:]
        endif
        let l:first = 0
      endif
    endfor
  endfor
  return l:lines
endfunction

" }}}2

" }}}1

" vim: fdm=marker sw=2