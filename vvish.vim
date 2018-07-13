let g:vvish_prompt='>>> '
let g:vvish_guard=0
let g:vvish_history=[]
let g:vvish_history_idx = 0
let g:vvish_cmd_input=''

function! Vvish_chomp(string)
    return substitute(a:string, '\n\+$', '', '')
endfunction

function! Vvish_Prompt()
    if exists('g:vvish_use_custom_prompt') && exists('g:vvish_custom_prompt') && g:vvish_use_custom_prompt
        let g:vvish_prompt=g:vvish_custom_prompt 
    else
        let g:vvish_prompt=strftime('%H:%M').' >>> '
    endif

    call setline('.', g:vvish_prompt)
    let g:vvish_guard=1
    call feedkeys("A")
endfunction

function! Vvish_HistoryUp()
    if g:vvish_history_idx == 0
        let l:line=Vvish_chomp(getline('.'))
        let g:vvish_history[0]=strpart(l:line, len(g:vvish_prompt))
    endif

    if g:vvish_history_idx < len(g:vvish_history) - 1
        let g:vvish_history_idx += 1
    endif

    call setline('.', g:vvish_prompt.g:vvish_history[-1 * g:vvish_history_idx])
    let g:vvish_guard=1
    call feedkeys("A")
endfunction

function! Vvish_HistoryDown()
    if g:vvish_history_idx > 0
        let g:vvish_history_idx -= 1
    endif
        
    call setline('.', g:vvish_prompt.g:vvish_history[-1 * g:vvish_history_idx])

    let g:vvish_guard=1
    call feedkeys("A")
endfunction

function! Vvish_ovr_clear()
    normal! zt
endfunction

function! Vvish_ovr_cd(line)
    let l:dir=substitute(a:line, 'cd\s\+', '', '')
    execute "cd ".l:dir
endfunction

function! Vvish_Init()
    setlocal buftype=nofile noswapfile
    setlocal syntax=sh
    setlocal omnifunc=syntaxcomplete#Complete

    nnoremap <buffer> c <nop>
    inoremap <buffer> <expr> <cr> pumvisible() ? '<cr>' : '<esc>:call Vvish_Call()<cr>'
    nnoremap <buffer> <cr> <esc>:call Vvish_Call()<cr>
    inoremap <buffer> <expr> <bs> line('.') == line('$') && col('.') > len(g:vvish_prompt) + 1 ? '<bs>' : ''
    inoremap <buffer> <expr> <up> pumvisible() ? '<up>' : '<esc>:call Vvish_HistoryUp()<cr>'
    inoremap <buffer> <expr> <down> pumvisible() ? '<down>' : '<esc>:call Vvish_HistoryDown()<cr>'
    nnoremap <buffer> <expr> <up> pumvisible() ? '<up>' : '<esc>:call Vvish_HistoryUp()<cr>'
    nnoremap <buffer> <expr> <down> pumvisible() ? '<down>' : '<esc>:call Vvish_HistoryDown()<cr>'
    vnoremap <buffer> <cr> :call Vvish_VisualCall()<cr>

    let g:vvish_guard=1
    call feedkeys("\<esc>G") 

    call Vvish_Prompt()
endfunction

function! Vvish_Insert()
    if !g:vvish_guard 
        let g:vvish_guard=1 
        if line('.') != line('$') || col('.') <= len(g:vvish_prompt)
            call feedkeys("\<esc>GA") 
        endif
    endif
    let g:vvish_guard=0
endfunction

augroup vvish_au
    autocmd!
    autocmd InsertEnter *.vvish call Vvish_Insert()
    autocmd BufNewFile *.vvish call Vvish_Init()
    autocmd BufRead *.vvish call Vvish_Init()
    autocmd BufEnter *.vvish let g:vvish_guard=1 | call feedkeys("\<esc>GA")
augroup end

function! Vvish_Call()
    let l:cmd=Vvish_chomp(getline('.'))
    let l:cmd=strpart(l:cmd, len(g:vvish_prompt))
    let l:vim_cmd=''
    if !empty(l:cmd)
        let g:vvish_history_idx=0

        if empty(g:vvish_history)
            call add(g:vvish_history, l:cmd)
        endif

        call add(g:vvish_history, l:cmd)

        if l:cmd == 'clear'
            call Vvish_ovr_clear()
        elseif matchend(l:cmd, 'cd ') == 3
            call Vvish_ovr_cd(strpart(l:cmd, 3))
        elseif matchend(l:cmd, ':') == 1
            let l:vim_cmd = strpart(l:cmd, 1)
        else
            let l:output = system(l:cmd, g:vvish_cmd_input)
            put =l:output
        endif

        let g:vvish_cmd_input=''

        put =''
        put =''
        call Vvish_Prompt()

        if !empty(l:vim_cmd)
            execute l:vim_cmd
        endif
    else
        put =''
        call Vvish_Prompt()
    endif
endfunction

" https://stackoverflow.com/questions/1533565/how-to-get-visually-selected-text-in-vimscript
function! s:get_visual_selection()
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction

function! Vvish_VisualCall() range
    let g:vvish_cmd_input=s:get_visual_selection()
    let g:vvish_guard=1
    call feedkeys("\<esc>G\<cr>")
endfunction
