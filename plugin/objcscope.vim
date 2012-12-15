" File: objcscope
" Author: Pitt Mak (Skeleton.MAK.Jr [at] gmail [dot] com)

function g:OCSCOPE_ListTags()
  let cur_line = line('.')
  let text = ''
  let line_text = getline(cur_line)
  let text = text.line_text." "

  let back_ward_line = cur_line
  let fore_ward_line = cur_line
  " add lines foreward
  while matchstr(line_text,';\|{') == ""
    let fore_ward_line = fore_ward_line + 1
    let line_text = getline(fore_ward_line)
    let text = text.line_text." "
  endwhile

  if matchstr(text, '\[\|\]') != ""
    let cur_col = col(".")
    let text = GetCloseBrackets(text, cur_col)
  endif

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

function! ReverseString(s)
  let len = strlen(a:s)
  let ret = ""
  for i in range(0, len)
    let idx = len - i
    let ret = ret.(a:s[idx])
  endfor
  return ret
endfunction


" Parse for closely selector
function! GetCloseBrackets(s, idx)
  let index = a:idx - 1
  let len = strlen(a:s)
  let resStr = ""
  let str = ""
  let i = index
  let ignoreChar = 0

  " search backward
  while i >= 0
    if a:s[i] == ']'
      let ignoreChar = ignoreChar + 1
    elseif a:s[i] == '[' && ignoreChar != 0
      let ignoreChar = ignoreChar - 1
    endif

    " stop searching
    if a:s[i] == '[' && ignoreChar == 0
      break
    endif

    if ignoreChar == 0
      let str = str.a:s[i]
    endif

    let i = i - 1
  endwhile

  " reverse string and append it to result
  let str = ReverseString(str)
  let resStr = resStr.str

  let str = ""
  let i = index + 1
  let ignoreChar = 0
  " search foreward
  while i <= len - 1
    if a:s[i] == '['
      let ignoreChar = ignoreChar + 1
    elseif a:s[i] == ']' && ignoreChar != 0
      let ignoreChar = ignoreChar - 1
    endif

    if a:s[i] == ']' && ignoreChar == 0
      break
    endif

    if ignoreChar == 0
      let str = str.a:s[i]
    endif
    let i = i + 1
  endwhile
  " apeend it to result
  let resStr = resStr.str

  " add brackets
  let resStr = "[".resStr."];"
  return resStr
endfunction

map <C-g> :call g:OCSCOPE_ListTags()<CR>

" set g:ocTagFile in vimrc or gvimrc
""let g:ocTagFile="/Users/Pitt/Desktop/Super-Weak-Boy/ocTags"

