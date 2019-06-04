function! crystalline#theme#nord#set_theme() abort
  call crystalline#generate_theme({
        \ 'NormalMode':  [[43, 135], ['#3b4251', '#a3be8b']],
        \ 'InsertMode':  [[43, 130],  ['#3b4251', '#81a1c1']],
        \ 'VisualMode':  [[43, 166], ['#3b4251', '#b48dac']],
        \ 'ReplaceMode': [[43, 158], ['#3b4251', '#bf6069']],
        \ '':            [[145, 236], ['#abb2bf', '#3e4452']],
        \ 'Inactive':    [[235, 145], ['#282c34', '#abb2bf']],
        \ 'Fill':        [[114, 236], ['#98c379', '#282c34']],
        \ 'Tab':         [[145, 236], ['#abb2bf', '#3e4452']],
        \ 'TabType':     [[43, 215], ['#abb2bf', '#3e4452']],
        \ 'TabSel':      [[235, 114], ['#282c34', '#98c379']],
        \ 'TabFill':     [[114, 236], ['#98c379', '#282c34']],
        \ })
endfunction

" vim:set et sw=2 ts=2 fdm=marker:
