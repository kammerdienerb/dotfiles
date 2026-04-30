define-class KammerdienerB-Frames
    'save-buff       : nil
    'save-frame      : nil
    'save-to-restore : (list "*builder-output" "*julie-output")
    'show-in-current : (list "*find-file-list" "*grep-list" "*ctags-find-list")

    'find-primary-frame :
        fn (&self)
            select ($NUMFRAMES == 0)
                nil
                select (@frame-is-root 0)
                    0
                    @tree-frame
                        @tree-prefer-left-or-topmost
                            @tree-child (@root-tree 0) 'right

    'find-right-frame :
        fn (&self)
            select ($NUMFRAMES == 0) nil
                select (@frame-is-root 0)
                    nil
                    do
                        root = (@root-tree 0)
                        select ((@tree-split-kind root) == 'vsplit)
                            @tree-frame (@tree-prefer-right-or-bottommost (@tree-child root 'left))
                            select (@tree-is-leaf (@tree-child root 'left))
                                nil
                                @tree-frame (@tree-prefer-right-or-bottommost (@tree-child root 'right))

    'make-right-frame :
        fn (&self)
            if ($NUMFRAMES == 0)
                @yexe "frame-new"
                @yexe "frame-vsplit"
            elif (@frame-is-root 0)
                @yexe "frame-vsplit"
            else
                root = (@root-tree 0)
                if ((@tree-split-kind root) == 'hsplit)
                    @activate-frame (@vsplit-tree (@tree-child root 'left))
            $FRAME

    'special-buffer-prepare-focus :
        fn (&self name)
            if ($FRAME == nil)
                @yexe "frame-new"

            if (name in (&self 'save-to-restore))
                (&self 'save-frame) = $FRAME

            if (not (name in (&self 'show-in-current)))
                go-to-right = 1

                if (name == "*go-menu")
                    # go-menu goes to the current frame unless the current frame already has the go-menu.
                    # In that case, we save and restore the buffer to the frame.

                    if ($BUFFNAME == "*go-menu")
                        @frame-set-buff $FRAME (&self 'save-buff)
                        (&self 'save-buff) = nil
                    else
                        (&self 'save-buff) = $BUFFNAME
                        go-to-right = 0

                if go-to-right
                    right = (&self @ ('find-right-frame))
                    @activate-frame
                        select (right != nil) right (&self @ ('make-right-frame))

    'special-buffer-prepare-jump-focus : (fn (&self name) nil)

    'special-buffer-prepare-unfocus :
        fn (&self name)
            if (name in (&self 'save-to-restore))
                if ((&self 'save-frame) != nil)
                    @activate-frame (&self 'save-frame)
            else
                @frame-set-buff $FRAME (&self 'save-buff)
            (&self 'save-buff)  = nil
            (&self 'save-frame) = nil

    'on-frame-delete :
        fn (&self &event)
            &save-frame = (&self 'save-frame)
            if (&save-frame != nil)
                if ((&event 'frame) == &save-frame)
                    &save-frame = nil
                elif ((&event 'frame) < &save-frame)
                    &save-frame -= 1

.kammerdienerb-frames := (new-instance KammerdienerB-Frames)

@command special-buffer-prepare-focus
special-buffer-prepare-focus =
    fn (name)
        .kammerdienerb-frames @ ('special-buffer-prepare-focus name)

@command special-buffer-prepare-jump-focus
special-buffer-prepare-jump-focus =
    fn (name)
        .kammerdienerb-frames @ ('special-buffer-prepare-jump-focus name)

@command special-buffer-prepare-unfocus
special-buffer-prepare-unfocus =
    fn (name)
        .kammerdienerb-frames @ ('special-buffer-prepare-unfocus name)

add-unique-event-handler @on-frame-delete (' (.kammerdienerb-frames @ ('on-frame-delete $EVENT)) )
