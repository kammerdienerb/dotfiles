#include <yed/plugin.h>
#include <yed/menu_frame.h>

int has(char *prg);
void kammerdienerb_jump_to_tag_in_split(int n_args, char **args);

int yed_plugin_boot(yed_plugin *self) {
    char *term;
    char *env_style;

    LOG_FN_ENTER();

    yed_log("init.c");
    yed_log("\n# ********************************************************");
    yed_log("\n# **  This is Brandon Kammerdiener's yed configuration  **");
    yed_log("\n# ********************************************************");

    yed_log("init.c: added 'kammerdienerb-jump-to-tag-in-split' command");
    yed_plugin_set_command(self, "kammerdienerb-jump-to-tag-in-split", kammerdienerb_jump_to_tag_in_split);

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

void kammerdienerb_jump_to_tag_in_split(int n_args, char **args) {
    yed_frame      *f;
    yed_frame_tree *other_tree;
    yed_frame      *split;

    if (n_args != 0) {
        yed_cerr("expected 0 arguments, but got %d", n_args);
        return;
    }

    if ((f = ys->active_frame) == NULL) {
        yed_cerr("no active frame");
        return;
    }

    if (f->buffer == NULL) {
        yed_cerr("active frame has no buffer");
        return;
    }

    split = NULL;

    if (f->tree != NULL && f->tree->parent != NULL) {
        other_tree = yed_frame_tree_find_next_leaf(f->tree);
        if (other_tree != NULL) {
            split = other_tree->frame;
        }
    }

    if (split == NULL) {
        split = yed_vsplit_frame(f);
    }

    if (split == NULL) {
        yed_cerr("could not find/make a split frame");
        return;
    }

    yed_activate_frame(split);
    yed_frame_set_buff(split, f->buffer);
    yed_set_cursor_within_frame(split, f->cursor_col, f->cursor_line);
    YEXE("ctags-jump-to-definition");
}
