#include <yed/plugin.h>
#include <yed/menu_frame.h>

int has(char *prg);

int yed_plugin_boot(yed_plugin *self) {
    char *term;
    char *env_style;

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
    if (!yed_term_says_it_supports_truecolor()) {
        yed_cerr("init.c: WARNING: terminal does not report that it supports truecolor\n"
                 "using truecolor anyways");
    }

    YEXE("set", "truecolor", "yes");

    if (file_exists_in_PATH("rg")) {
        yed_log("init.c: found an rg executable");
        YEXE("set", "grep-prg",      "rg --ignore-file='.grepignore' --vimgrep \"%\"");
        YEXE("set", "find-file-prg", "rg --ignore-file='.grepignore' --files -g \"*%*\"");
    } else if (file_exists_in_PATH("fzf")) {
        yed_log("init.c: found a fzf executable");
        YEXE("set", "find-file-prg", "fzf --filter=\"%\"");
    }

    if (getenv("DISPLAY") && file_exists_in_PATH("notify-send")) {
        yed_log("init.c: using desktop notifications for builder");
        YEXE("set", "builder-notify-command", "notify-send -i utilities-terminal yed %");
    }

    /* Load my yedrc file. */
    YEXE("yedrc-load", "~/.yed/yedrc");

    /* Load style via environment var if set. */
    if ((term = getenv("TERM"))
    &&  strcmp(term, "linux") == 0) {
        yed_log("init.c: TERM = linux -- activating vt style\n");
        YEXE("style", "vt");
    } else if ((env_style = getenv("YED_STYLE"))) {
        yed_log("init.c: envirnoment variable YED_STYLE = %s -- activating\n", env_style);
        YEXE("style", env_style);
    }

    LOG_EXIT();
    return 0;
}