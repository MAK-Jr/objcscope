" File: objcscope
" Author: Pitt Mak (Skeleton.MAK.Jr [at] gmail [dot] com)

function g:OCSCOPE_ListTags()
  let cur_line = line('.')
  let text = ''
  let line_text = getline(cur_line)
  let text = text.line_text." "
  while matchstr(line_text,';\|{') == ""
    let cur_line = cur_line + 1
    let line_text = getline(cur_line)
    let text = text.line_text." "
  endwhile

  "execute objcscope
  let stdout = system("objcscope -S ".g:ocTagFile." \"".text."\"")
  let list = split(stdout,"&&")
  if len(list) <= 0
    return
  endif
  let dict = {}
  for ele in list
    let l = split(ele,"|")
    if l != []
      let dict[l[1]] = l[0]
    endif
  endfor

  " if there is only one item, we don't want to show a menu but just jump
  " to definition
  ""let keys = keys(dict)
  ""if len(keys) == 1
  ""  exe 'e' escape(keys[0],' ')
  ""endif
  " go through all items
  let format = "[Objcscope Author: Pitt Mak eMail: Skeleton.MAK.Jr@gmail.com]\n"
  let format = format."    Index    FileName\n"
  let keys = keys(dict)
  let end = len(keys)
  for i in range(0, end - 1)
    let f = pathshorten(dict[keys[i]])
    let format = format."    ".i."        ".f."\n"
  endfor

  let idx = g:Dialog(format)
  let idx = str2nr(idx)

  " open file
  exe "e! ".escape(dict[keys[idx]],' ')
  exe "".keys[idx]

endfunction

function! g:Dialog(str)
  call inputsave()
  let idx = input(a:str.'Enter a index: ')
  call inputrestore()
  return idx
endfunction

function! g:test()
  echo "Testing."
endfunction

map <C-g> :call g:OCSCOPE_ListTags()<CR>

" set g:ocTagFile in vimrc or gvimrc
""let g:ocTagFile="/Users/Pitt/Desktop/Super-Weak-Boy/ocTags"

