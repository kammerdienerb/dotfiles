#include <yed/plugin.h>
#include <yed/menu_frame.h>

int has(char *prg);

int yed_plugin_boot(yed_plugin *self) {
    LOG_FN_ENTER();

    yed_log("init.c");
    yed_log("\n# ********************************************************");
    yed_log("\n# **  This is Brandon Kammerdiener's yed configuration  **");
    yed_log("\n# ********************************************************");

    YEXE("plugin-load", "yedrc");

    /*
     * Set things that need to be dynamic,
     * but allow yedrc to override.
     */
    if (yed_term_says_it_supports_truecolor()) {
        yed_log("init.c: terminal says it supports truecolor");
        YEXE("set", "truecolor", "yes");
    }
    if (has("rg")) {
        yed_log("init.c: found an rg executable");
        YEXE("set", "grep-prg", "rg --vimgrep \"%\"");
    }
    if (has("fzf")) {
        yed_log("init.c: found a fzf executable");
        YEXE("set", "find-file-prg", "fzf --filter=\"%\"");
    }

    /* Load my yedrc file. */
    YEXE("yedrc-load", "~/.yed/yedrc");

    LOG_EXIT();
    return 0;
}

/*
 * @bad @performance
 * Amazingly, this is actually the bottleneck for startup time.
 * We're pretty fast about everything else.
 * But it would be nice to have a faster method to get this
 * information.
 */
int has(char *prg) {
    char *path;

    path = exe_path(prg);

    if (path) {
        free(path);
        return 1;
    }

    return 0;
}
