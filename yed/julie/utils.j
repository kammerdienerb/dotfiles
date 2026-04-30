macro =
    fn (&template ...)
        recursive-replace =
            fn (&self &template &args)
                foreach &elem &template
                    if ((typeof &elem) == "symbol")
                        s = (string &elem)
                        if (startswith s "$")
                            num = (parse-int (substr s 1 ((len s) - 1)))
                            if (num != nil)
                                &elem = (&args num)
                    elif ((typeof &elem) == "list")
                        &self &self &elem &args
        recursive-replace recursive-replace &template ...
        &template

reloadable-actor =
    fn (sym code)
        apply
            macro
                '
                    do
                        if (is-bound $0)
                            actor-stop $0
                            unbind $0
                        $0 := (actor-spawn (' $1))
                        $0
                sym
                code

add-unique-event-handler =
    fn (&handler-list &handler)
        if (not (&handler in &handler-list))
            append &handler-list &handler

exists-in-PATH =
    fn (name)
        PATH  = (getenv "PATH")
        paths = (select (PATH == nil) (list) (split PATH ":"))
        any (lambda (path) (fexists (fmt "%/%" path name))) paths
