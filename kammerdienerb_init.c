#include <yed/plugin.h>
#include <yed/menu_frame.h>

int has(char *prg);

int yed_plugin_boot(yed_plugin *self) {
    YEXE("plugin-load", "yedrc");

    /*
     * Set things that need to be dynamic,
     * but allow yedrc to override.
     */
    if (yed_term_says_it_supports_truecolor()) {
        yed_set_var("truecolor", "yes");
    }
    if (has("rg")) {
        yed_set_var("grep-prg",      "rg --vimgrep \"%\"");
    }
    if (has("fzf")) {
        yed_set_var("find-file-prg", "fzf --filter=\"%\"");
    }

    /* Load my yedrc file. */
    YEXE("yedrc-load", "~/.yed/yedrc");

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
