eval-file (fmt "%/julie/utils.j" $CONFIG-PATH)

vars =
    object
        "truecolor"                        : "yes"
        "screen-fake-opacity"              : 0.75
        "tab-width"                        : 4
        "fill-string"                      : "▒"
        "border-style"                     : "thin"
        "cursor-line"                      : "yes"
        "macro-instant-playback"           : "yes"
        "go-menu-persistent-items"         : ".yedrc .yed.j build.sh"
        "completer-sources"                : "word tags"
        "completer-auto"                   : "yes"
        "builder-popup-rg"                 : "yes"
        "builder-build-command"            : "./build.sh"
        "universal-copy-on-yank"           : "yes"
        "universal-clipboard-trim-nl"      : "yes"
        "terminal-scrollback"              : 10000
        "lsp-info-popup-idle-threshold-ms" : -1
        "xul-normal-attrs"                 : "bg @17 fg @253"
        "xul-insert-attrs"                 : "bg @22 fg @253"
        "status-line-buffer-attrs"         : "&selection.bg &code-string.fg swap"
        "status-line-location-attrs"       : "&selection.bg &code-number.fg swap"
        "status-line-ft-attrs"             : "&selection.bg &code-typename.fg swap"
        "status-line-left"                 : "%{xul-mode-attrs} %=6(xul-mode) %{status-line-buffer-attrs} %b "
        "status-line-center"               : "%n %f"
        "status-line-right"                : "%(builder-status)  %{status-line-location-attrs} (%3p%%)  %5l :: %-3c  %{status-line-ft-attrs} %=5F "

if (exists-in-PATH "rg")
    vars <- ("grep-prg"      : "rg --vimgrep '%' | sort")
    vars <- ("find-file-prg" : "rg --files | rg '(^[^/]*%)|(/[^/]*%[^/]*$)' | sort")

foreach name vars (@set-var name (vars name))


@command kammerdienerb-find-cursor-word
kammerdienerb-find-cursor-word =
    fn ()
        word = $CURSOR-WORD
        if (word != nil)
            @yexe "find-in-buffer" word
            @yexe "find-prev-in-buffer"
        else
            @cerr "cursor is not on a word"

@yexe "plugin-load" "ypm"


if ((getenv "TERM") == "linux")
    @yexe "style" "vt"
else
    @yexe "fstyle" "~/.config/yed/styles/next-dark.fstyle"
    @yexe "style-use-term-bg"



@yexe "lsp-define-server" "CLANGD" "clangd --background-index" "C" "C++"


eval-file (fmt "%/julie/terminal.j" $CONFIG-PATH)
eval-file (fmt "%/julie/frames.j"   $CONFIG-PATH)

@yexe "plugin-unload" "ypm/plugins/xul"
eval-file (fmt "%/julie/xul.j"      $CONFIG-PATH)

.xul @ ('bind 'normal "spc c o"       (' (@yexe "comment-toggle")                                                                               ))
.xul @ ('bind 'normal "spc b d"       (' (@yexe "buffer-delete")                                                                                ))
.xul @ ('bind 'normal "M M"           (' (@yexe "man-word")                                                                                     ))
.xul @ ('bind 'normal "ctrl-l"        (' (@yexe "frame-next")                                                                                   ))
.xul @ ('bind 'normal ">"             (' (@yexe "indent")                                                                                       ))
.xul @ ('bind 'normal "<"             (' (@yexe "unindent")                                                                                     ))
.xul @ ('bind 'normal "spc l"         (' (@yexe "command-prompt" "cursor-line ")                                                                ))
.xul @ ('bind 'normal "spc g"         (' (@yexe "grep")                                                                                         ))
.xul @ ('bind 'normal "spc f"         (' (@yexe "find-file")                                                                                    ))
.xul @ ('bind 'normal "spc a l"       (' (@yexe "command-prompt" "align ")                                                                      ))
.xul @ ('bind 'normal "ctrl-y"        (' (@yexe "multi" "builder-view-output" "builder-start" "special-buffer-prepare-unfocus *builder-output") ))
.xul @ ('bind 'normal "E E"           (' (@yexe "builder-jump-to-error")                                                                        ))
.xul @ ('bind 'normal "spc t"         (' (@yexe "ctags-find")                                                                                   ))
.xul @ ('bind 'normal "T T"           (' (@yexe "multi" "forward-cursor-word ctags-find")                                                       ))
.xul @ ('bind 'normal "R G"           (' (@yexe "multi" "forward-cursor-word grep")                                                             ))
.xul @ ('bind 'normal "tab"           (' (@yexe "go-menu")                                                                                      ))
.xul @ ('bind 'normal "ctrl-/"        (' (@yexe "kammerdienerb-find-cursor-word")                                                               ))
.xul @ ('bind 'normal "pagedown"      (' (@yexe "scroll-buffer" 20)                                                                             ))
.xul @ ('bind 'normal "pageup"        (' (@yexe "scroll-buffer" -20)                                                                            ))
.xul @ ('bind 'normal "ctrl-x"        (' (@yexe "go-menu")                                                                                      ))
.xul @ ('bind 'normal "ctrl-k"        (' (@yexe "whence-you-came")                                                                              ))
.xul @ ('bind 'normal "ctrl-n"        (' (@yexe "goto-term-or-create")                                                                          ))
.xul @ ('bind 'normal "ctrl-t"        (' (@yexe "toggle-term-mode")                                                                             ))
.xul @ ('bind 'normal "ctrl-j ctrl-j" (' (@yexe "multi" "julie-view-output" "special-buffer-prepare-unfocus *julie-output" "julie-eval-buffer") ))

.xul @ ('bind 'insert "j j"    (' (.xul @ ('set-mode 'normal)) ))

term-keys =
    object
        "ctrl-x"   : (list "go-menu")
        "ctrl-l"   : (list "frame-next")
        "ctrl-k"   : (list "whence-you-came")
        "ctrl-n"   : (list "goto-term")

foreach binding term-keys
    apply (concat (' (@yexe "term-bind" binding) ) (term-keys binding))

@command w
w = (fn () (@yexe "write-buffer"))

@command W
W = w

@command q
q =
    fn ()
        if ($FRAME == (.kammerdienerb-frames @ ('find-primary-frame)))
            @yexe "quit"
        else
            @yexe "frame-delete"

@command Q
Q = q

@command wq
wq = (fn () (w) (q))

@command Wq
Wq = wq

if (fexists ".yed.j") (eval-file ".yed.j")
