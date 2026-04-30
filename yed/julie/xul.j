define-class Xul
    'mode : nil
    'vsel : 0

    'map :
        object
            'normal :
                object
                    "h" :
                        '
                            do
                                if (not (&xul 'vsel))
                                    @yexe "select-off"
                                    @yexe "select"
                                @yexe "cursor-left"
                    "H" :
                        '
                            @yexe "cursor-left"
                    "j" :
                        '
                            do
                                if (&xul 'vsel)
                                    @yexe "cursor-down"
                                else
                                    @yexe "select-off"
                                    @yexe "cursor-down"
                                    @yexe "select-lines"
                    "J" :
                        '
                            @yexe "cursor-down"
                    "k" :
                        '
                            do
                                if (&xul 'vsel)
                                    @yexe "cursor-up"
                                else
                                    @yexe "select-off"
                                    @yexe "cursor-up"
                                    @yexe "select-lines"
                    "K" :
                        '
                            @yexe "cursor-up"
                    "l" :
                        '
                            do
                                if (not (&xul 'vsel))
                                    @yexe "select-off"
                                    @yexe "select"
                                @yexe "cursor-right"
                    "L" :
                        '
                            @yexe "cursor-right"
                    "pageup" :
                        '
                            do
                                if (&xul 'vsel)
                                    @yexe "cursor-page-up"
                                else
                                    @yexe "select-off"
                                    @yexe "cursor-page-up"
                                    @yexe "select-lines"
                    "pagedown" :
                        '
                            do
                                if (&xul 'vsel)
                                    @yexe "cursor-page-down"
                                else
                                    @yexe "select-off"
                                    @yexe "cursor-page-down"
                                    @yexe "select-lines"
                    "w" :
                        '
                            do
                                if (not (&xul 'vsel))
                                    @yexe "select-off"
                                    @yexe "select"
                                @yexe "cursor-next-word"
                    "W" :
                        '
                            do
                                if ((not (&xul 'vsel)) and ((@buffer-selection-kind $BUFFNAME) == 'line))
                                    @yexe "select-off"
                                    @yexe "select"
                                @yexe "cursor-next-word"
                    "b" :
                        '
                            do
                                if (not (&xul 'vsel))
                                    @yexe "select-off"
                                    @yexe "select"
                                @yexe "cursor-prev-word"
                    "B" :
                        '
                            do
                                if ((not (&xul 'vsel)) and ((@buffer-selection-kind $BUFFNAME) == 'line))
                                    @yexe "select-off"
                                    @yexe "select"
                                @yexe "cursor-prev-word"
                    "0" :
                        '
                            do
                                if (not (&xul 'vsel))
                                    @yexe "select-off"
                                    @yexe "select"
                                @yexe "cursor-line-begin"
                    "$" :
                        '
                            do
                                if (not (&xul 'vsel))
                                    @yexe "select-off"
                                    @yexe "select"
                                @yexe "cursor-line-end"
                    "g" :
                        '
                            do
                                @yexe "cursor-buffer-begin"
                                if (not (&xul 'vsel))
                                    @yexe "select-off"
                                    @yexe "select-lines"
                    "G" :
                        '
                            do
                                @yexe "cursor-buffer-end"
                                if (not (&xul 'vsel))
                                    @yexe "select-off"
                                    @yexe "select-lines"
                    "/" :
                        '
                            do
                                if (not (&xul 'vsel))
                                    @yexe "select-off"
                                    @yexe "select"
                                l = $LINENO
                                @yexe "find-in-buffer"
                                if ($LINENO != l)
                                    @yexe "select-off"
                    "?" :
                        '
                            @yexe "replace-current-search"
                    "n" :
                        '
                            do
                                if (not (&xul 'vsel))
                                    @yexe "select-off"
                                    @yexe "select"
                                l = $LINENO
                                @yexe "find-next-in-buffer"
                                if ($LINENO != l)
                                    @yexe "select-off"
                                    @yexe "select-lines"
                    "N" :
                        '
                            do
                                if (not (&xul 'vsel))
                                    @yexe "select-off"
                                    @yexe "select"
                                l = $LINENO
                                @yexe "find-prev-in-buffer"
                                if ($LINENO != l)
                                    @yexe "select-off"
                                    @yexe "select-lines"
                    ":" :
                        '
                            @yexe "command-prompt"
                    "v" :
                        '
                            do
                                (&xul 'vsel) = (not (&xul 'vsel))
                                @yexe "select-off"
                                @yexe "select"
                    "V" :
                        '
                            do
                                (&xul 'vsel) = (not (&xul 'vsel))
                                @yexe "select-off"
                                @yexe "select-lines"
                    "ctrl-v" :
                        '
                            do
                                (&xul 'vsel) = (not (&xul 'vsel))
                                @yexe "select-off"
                                @yexe "select-rect"
                    "y" :
                        '
                            do
                                (&xul 'vsel) = 0
                                @yexe "yank-selection"
                                @yexe "select-off"
                                @yexe "select-lines"
                    "p" :
                        '
                            do
                                (&xul 'vsel) = 0
                                @yexe "paste-yank-buffer"
                                @yexe "select-off"
                                @yexe "select-lines"
                    "d" :
                        '
                            do
                                (&xul 'vsel) = 0
                                @yexe "yank-selection" 1
                                @yexe "delete-back"
                                @yexe "select-off"
                                @yexe "select-lines"
                    "c" :
                        '
                            do
                                (&xul 'vsel) = 0
                                @yexe "yank-selection" 1
                                @yexe "delete-back"
                                @yexe "select-off"
                                &xul @ ('set-mode 'insert)
                    "u" :
                        '
                            do
                                (&xul 'vsel) = 0
                                @yexe "undo"
                                @yexe "select-off"
                                @yexe "select-lines"
                    "ctrl-r" :
                        '
                            do
                                (&xul 'vsel) = 0
                                @yexe "redo"
                                @yexe "select-off"
                                @yexe "select-lines"
                    "esc" :
                        '
                            do
                                (&xul 'vsel) = 0
                                @yexe "select-off"
                                @yexe "select-lines"
                    "ctrl-c" :
                        '
                            do
                                (&xul 'vsel) = 0
                                @yexe "select-off"
                                @yexe "select-lines"
                    "i" :
                        '
                            do
                                &xul @ ('set-mode 'insert)
                    "a" :
                        '
                            do
                                @yexe "cursor-right"
                                &xul @ ('set-mode 'insert)
                    "A" :
                        '
                            do
                                @yexe "cursor-line-end"
                                &xul @ ('set-mode 'insert)

            'insert :
                object
                    "esc"      : (' (&xul @ ('set-mode 'normal)) )
                    "ctrl-c"   : (' (&xul @ ('set-mode 'normal)) )
                    "left"     : (' (@yexe "cursor-left")        )
                    "down"     : (' (@yexe "cursor-down")        )
                    "up"       : (' (@yexe "cursor-up")          )
                    "right"    : (' (@yexe "cursor-right")       )
                    "pageup"   : (' (@yexe "cursor-page-up")     )
                    "pagedown" : (' (@yexe "cursor-page-down")   )
                    "home"     : (' (@yexe "cursor-line-begin")  )
                    "end"      : (' (@yexe "cursor-line-end")    )
                    "bsp"      : (' (@yexe "delete-back")        )
                    "delete"   : (' (@yexe "delete-forward")     )

    'init :
        fn (&self)
            @set-var "cursor-line" "off"

            foreach key (@map-get-bindings "global")
                @map-unbind-key "global" key
            foreach key (@sequence-keys)
                @delete-key-sequence key
            @disable-key-map "global"

            @add-key-map "xul"
            foreach key (@real-keys)
                @map-bind-key "xul" key "xul-take-key" (string (@key-code key))

            &self @ ('set-mode 'normal)

    'mode-status-string :
        fn (&self &mode)
            match &mode
                'normal "NORMAL"
                'insert "INSERT"

    'set-mode :
        fn (&self &mode)
            if ((&self 'mode) != &mode)
                if ((&self 'mode) != nil)
                    foreach key ((&self 'map) (&self 'mode))
                        @disable-key-sequence key

                (&self 'mode) = &mode

                foreach key ((&self 'map) (&self 'mode))
                    @enable-key-sequence key

                @set-var "xul-mode" (&self @ ('mode-status-string (&self 'mode)))

                match &mode
                    'normal (@yexe "select-lines")
                    'insert (@yexe "select-off")

    'get-sel-kind :
        fn (&self)
            bname = $BUFFNAME
            select (bname == nil) nil (@buffer-selection-kind bname)


    'key-exec-wrapper : (fn (&xul &code) (&code))

    'take-key :
        fn (&self &key)
            &map = ((&self 'map) (&self 'mode))

            if (&key in &map)
                &self @ ('key-exec-wrapper (&map &key))
            elif (((&self 'mode) == 'insert) and (not (startswith &key "ctrl-")))
                @yexe "insert" (string (@key-code &key))

    'on-pre-buffer-focus :
        fn (&self &event)
            bname = $BUFFNAME
            if
                and
                    bname != nil
                    not (@buffer-is-special bname)
                    (@buffer-selection-kind bname) != nil
                (&self 'vsel) = 0
                @yexe "select-off"

    'on-pre-draw-everything :
        fn (&self &event)
            bname = $BUFFNAME
            if
                and
                    bname != nil
                    not (@buffer-is-special bname)
                    (@buffer-selection-kind bname) == nil
                    (&self 'mode) == 'normal
                (&self 'vsel) = 0
                @yexe "select-lines"

    'bind :
        fn (&self &mode &key &code)
            if ((@key-code &key) == nil)
                @add-key-sequence &key
                @map-bind-key "xul" &key "xul-take-key" (string (@key-code &key))
                if (&mode != (&self 'mode))
                    @disable-key-sequence &key
            ((&self 'map) &mode) <- (&key : &code)

.xul := (new-instance Xul)

.xul @ ('init)

@command xul-take-key
xul-take-key =
    fn (key-code-string)
        .xul @ ('take-key (@key-code-to-string (parse-int key-code-string)))

add-unique-event-handler @on-pre-buffer-focus (' (.xul @ ('on-pre-buffer-focus $EVENT)) )
add-unique-event-handler @on-pre-draw-everything (' (.xul @ ('on-pre-draw-everything $EVENT)) )
