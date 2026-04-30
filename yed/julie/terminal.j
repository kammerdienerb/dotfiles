define-class Terminal
    'last-term : nil

    'save-term-buff :
        fn (&self)
            name = $BUFFNAME
            if (name != nil)
                if (startswith name "*term")
                    (&self 'last-term) = name

    'get-term-buffs :
        fn (&self)
            terms = (list)
            n     = 0
            name  = (fmt "*term%" n)
            while (@buffer-exists name)
                append terms name
                n += 1
                name = (fmt "*term%" n)
            terms

    'next-term-buff :
        fn (&self &current)
            terms = (&self @ ('get-term-buffs))
            count = (len terms)
            idx   = (index terms &current)
            select (idx == nil)
                select (count > 0) (terms 0) nil
                terms ((idx + 1) % count)

    'goto-term :
        fn (&self)
            name   = $BUFFNAME
            target =
                select ((name == nil) or (not (startswith name "*term")))
                    &self 'last-term
                    &self @ ('next-term-buff name)

            if (target == nil)
                terms = (&self @ ('get-term-buffs))
                if ((len terms) > 0)
                    @yexe "special-buffer-prepare-focus" (terms 0)
                    @yexe "buffer" (terms 0)
                else
                    @yexe "term-open"
            else
                @yexe "special-buffer-prepare-focus" target
                @yexe "buffer" target

    'goto-term-or-create :
        fn (&self)
            name = $BUFFNAME
            if ((name != nil) and (startswith name "*term"))
                @yexe "term-mode-on" name
                @yexe "term-open"
            else
                &self @ ('goto-term)


.terminal := (new-instance Terminal)

@command goto-term
goto-term = (fn () (.terminal @ ('goto-term)))

@command goto-term-or-create
goto-term-or-create = (fn () (.terminal @ ('goto-term-or-create)))

add-unique-event-handler @on-buffer-focused (' (.terminal @ ('save-term-buff)) )
