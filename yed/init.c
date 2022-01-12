#include <yed/plugin.h>

static yed_plugin        *Self;
static yed_frame         *last_frame;
static yed_event_handler  epump_anim;
static yed_event_handler  eframe_act;
static yed_event_handler  eframe_del;
static int                animating;
static int                want_tray_size;
static int                save_hz;
static char              *save_buff;
static yed_frame         *save_frame;


#define GO_MENU_SPLIT_RATIO (2.5)
#define TRAY_BIG            (16)
#define TRAY_SMALL          (5)
#define ANIMATIONS_PER_SEC  (100)


void kammerdienerb_special_buffer_prepare_focus(int n_args, char **args);
void kammerdienerb_special_buffer_prepare_jump_focus(int n_args, char **args);
void kammerdienerb_special_buffer_prepare_unfocus(int n_args, char **args);
void kammerdienerb_quit(int n_args, char **args);
void kammerdienerb_write_quit(int n_args, char **args);
void kammerdienerb_find_cursor_word(int n_args, char **args);
void kammerdienerb_frame_next_skip_tray(int n_args, char **args);

#define ARGS_SCRATCH_BUFF "*scratch", (BUFF_SPECIAL)

yed_buffer *get_or_make_buffer(char *name, int flags) {
    yed_buffer *buff;
LOG_FN_ENTER();

    if ((buff = yed_get_buffer(name)) == NULL) {
        buff = yed_create_buffer(name);
        yed_log("\ninit.c: created %s buffer", name);
    }
    buff->flags |= flags;

LOG_EXIT();
    return buff;
}

static yed_frame *find_main_frame(void) {
    yed_frame      *frame;
    yed_frame_tree *tree;

    if (array_len(ys->frames) == 0) { return NULL; }

    frame = *(yed_frame**)array_item(ys->frames, 0);
    if (yed_frame_is_tree_root(frame)) { return frame; }

    tree = yed_frame_tree_get_root(frame->tree);

    tree = yed_frame_tree_get_split_leaf_prefer_left_or_topmost(tree->child_trees[1]);

    return tree->frame;
}

static yed_frame *find_right_frame(void) {
    yed_frame      *frame;
    yed_frame_tree *tree;

    if (array_len(ys->frames) == 0) { return NULL; }

    frame = *(yed_frame**)array_item(ys->frames, 0);
    if (yed_frame_is_tree_root(frame)) { return NULL; }

    tree = yed_frame_tree_get_root(frame->tree);

    if (tree->split_kind == FTREE_VSPLIT) {
        tree = yed_frame_tree_get_split_leaf_prefer_right_or_bottommost(tree->child_trees[0]);
    } else {
        if (tree->child_trees[0]->is_leaf) { return NULL; }
        tree = yed_frame_tree_get_split_leaf_prefer_right_or_bottommost(tree->child_trees[1]);
    }

    return tree->frame;
}

static yed_frame * make_right_frame(void) {
    yed_frame      *frame;
    yed_frame_tree *tree;

    if (array_len(ys->frames) == 0) {
        YEXE("frame-new"); YEXE("frame-vsplit");
        goto resize;
    }

    frame = *(yed_frame**)array_item(ys->frames, 0);

    if (yed_frame_is_tree_root(frame)) {
        YEXE("frame-vsplit");
        goto resize;
    }

    tree = yed_frame_tree_get_root(frame->tree);

    if (tree->split_kind == FTREE_HSPLIT) {
        frame = yed_vsplit_frame_tree(tree->child_trees[0]);
        yed_activate_frame(frame);
    }

resize:;
    yed_resize_frame(ys->active_frame, 0, (int)((0.4 - ys->active_frame->width_f) * ys->term_cols));

    return ys->active_frame;
}

static yed_frame *find_tray_frame(void) {
    yed_frame      *frame;
    yed_frame_tree *tree;

    if (array_len(ys->frames) == 0) { return NULL; }

    frame = *(yed_frame**)array_item(ys->frames, 0);
    tree  = yed_frame_tree_get_root(frame->tree);

    if (tree->is_leaf) { return NULL; }

    if (tree->split_kind == FTREE_VSPLIT) {
        if (!tree->child_trees[0]->is_leaf && tree->child_trees[0]->split_kind == FTREE_HSPLIT) {
            tree = yed_frame_tree_get_split_leaf_prefer_right_or_bottommost(tree->child_trees[0]);
            return tree->frame;
        }
    } else {
        if (tree->child_trees[1]->is_leaf) {
            return tree->child_trees[1]->frame;
        }
    }

    return NULL;
}

static yed_frame * make_tray_frame(void) {
    yed_frame      *frame;
    yed_frame_tree *tree;

    if (array_len(ys->frames) == 0) { YEXE("frame-new"); }

    frame = *(yed_frame**)array_item(ys->frames, 0);
    tree  = yed_frame_tree_get_root(frame->tree);
    frame = yed_hsplit_frame_tree(tree);

    while (frame->height > 1) {
        yed_resize_frame(frame, -1, 0);
    }

    return frame;
}

static void tray_animate(yed_event *event) {
    yed_frame *tray;

    tray = find_tray_frame();

    if (tray == NULL || tray->height == want_tray_size) {
done:;
        yed_set_update_hz(save_hz);
        yed_delete_event_handler(epump_anim);
        animating = 0;
    } else {
        yed_resize_frame(tray, (want_tray_size - tray->height) < 0 ? -1 : 1, 0);
    }
}

static void start_tray_anim(int rows) {
    yed_frame *tray;

    tray = find_tray_frame();

    want_tray_size = rows;

    if (tray != NULL && !animating) {
        epump_anim.kind = EVENT_PRE_PUMP;
        epump_anim.fn   = tray_animate;
        yed_plugin_add_event_handler(Self, epump_anim);
        save_hz = yed_get_update_hz();
        yed_set_update_hz(ANIMATIONS_PER_SEC);
        animating = 1;
    }
}

static void act_tray(yed_event *event) {
    yed_frame *tray;

    tray = find_tray_frame();

    if (tray == NULL) { return; }

    if (event->frame == tray) {
        start_tray_anim(TRAY_BIG);
    } else if (last_frame == tray) {
        start_tray_anim(TRAY_SMALL);
    }

    last_frame = event->frame;
}

static void frame_del(yed_event *event) {
    if (event->frame == last_frame) { last_frame = NULL; }
    if (event->frame == save_frame) { save_frame = NULL; }
}

int yed_plugin_boot(yed_plugin *self) {
    char *path;
    char *term;
    char *env_style;

    YED_PLUG_VERSION_CHECK();

    Self = self;

    LOG_FN_ENTER();

    yed_log("init.c");
    yed_log("\n# ********************************************************");
    yed_log("\n# **  This is Brandon Kammerdiener's yed configuration  **");
    yed_log("\n# ********************************************************");

    yed_plugin_set_command(self, "special-buffer-prepare-focus",      kammerdienerb_special_buffer_prepare_focus);
    yed_plugin_set_command(self, "special-buffer-prepare-jump-focus", kammerdienerb_special_buffer_prepare_jump_focus);
    yed_plugin_set_command(self, "special-buffer-prepare-unfocus",    kammerdienerb_special_buffer_prepare_unfocus);
    eframe_act.kind = EVENT_FRAME_ACTIVATED;
    eframe_act.fn   = act_tray;
    yed_plugin_add_event_handler(Self, eframe_act);
    eframe_del.kind = EVENT_FRAME_PRE_DELETE;
    eframe_del.fn   = frame_del;
    yed_plugin_add_event_handler(Self, eframe_del);
    yed_log("\ninit.c: added overrides for 'special-buffer-prepare-*' commands");

    get_or_make_buffer(ARGS_SCRATCH_BUFF);

    yed_plugin_set_command(self, "kammerdienerb-find-cursor-word",     kammerdienerb_find_cursor_word);
    yed_plugin_set_command(self, "kammerdienerb-frame-next-skip-tray", kammerdienerb_frame_next_skip_tray);

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
        YEXE("set", "grep-prg",      "rg --vimgrep '%' | sort");
        YEXE("set", "find-file-prg", "rg --files | rg '(^[^/]*%)|(/[^/]*%[^/]*$)' | sort");
    } else if (file_exists_in_PATH("fzf")) {
        yed_log("init.c: found a fzf executable");
        YEXE("set", "find-file-prg", "fzf --filter='%'");
    }

    if (getenv("DISPLAY") && file_exists_in_PATH("notify-send")) {
        yed_log("init.c: using desktop notifications for builder");
        YEXE("set", "builder-notify-command", "notify-send -i utilities-terminal yed %");
    }

    /* Load my yedrc file. */
    path = get_config_item_path("yedrc");
    YEXE("yedrc-load", path);
    free(path);

    /* Load style via environment var if set. */
    if ((term = getenv("TERM"))
    &&  strcmp(term, "linux") == 0) {
        yed_log("init.c: TERM = linux -- activating vt style\n");
        YEXE("style", "vt");
    } else if ((env_style = getenv("YED_STYLE"))) {
        yed_log("init.c: envirnoment variable YED_STYLE = %s -- activating\n", env_style);
        YEXE("style", env_style);
    }

    yed_plugin_set_command(self, "q",  kammerdienerb_quit);
    yed_plugin_set_command(self, "Q",  kammerdienerb_quit);
    yed_plugin_set_command(self, "wq", kammerdienerb_write_quit);
    yed_plugin_set_command(self, "Wq", kammerdienerb_write_quit);
    yed_log("\ninit.c: added overrides for 'q'/'Q' and 'wq'/'Wq' commands");

    LOG_EXIT();
    return 0;
}

void kammerdienerb_special_buffer_prepare_focus(int n_args, char **args) {
    yed_command     default_cmd;
    yed_frame_tree *tree;
    yed_frame      *f;


    if (n_args != 1) {
        yed_cerr("expected 1 argument, but got %d", n_args);
        return;
    }

    if (ys->active_frame == NULL) {
        YEXE("frame-new"); if (ys->active_frame == NULL) { return; }
    }

    if (strcmp(args[0], "*builder-output") == 0
    ||  strcmp(args[0], "*shell-output")   == 0
    ||  strcmp(args[0], "*calc")           == 0) {

        /* These go to the tray. */

        f = find_tray_frame();
        if (f == NULL) { f = make_tray_frame(); }

        save_frame = ys->active_frame;

        yed_activate_frame(f);

    } else if (strcmp(args[0], "*find-file-list")  == 0
    ||         strcmp(args[0], "*grep-list")       == 0
    ||         strcmp(args[0], "*ctags-find-list") == 0) {

        /* These go wherever you already are. */

    } else {
        /*
         * Every other special buffer should go in the right split.
         * _EXCEPT_ for the go-menu special case. See below.
         */

        if (ys->term_cols < (GO_MENU_SPLIT_RATIO * ys->term_rows) && !yed_var_is_truthy("my-frames-force-split")) {
            default_cmd = yed_get_default_command("special-buffer-prepare-focus");
            if (default_cmd) {
                default_cmd(n_args, args);
                return;
            }
        }

        if (strcmp(args[0], "*go-menu") == 0) {
            /*
             * go-menu goes to the current frame unless the current frame already has the go-menu.
             * In that case, we save and restore the buffer to the frame.
             */


            if (ys->active_frame->buffer != NULL
            &&  strcmp(ys->active_frame->buffer->name, "*go-menu") == 0) {

                /* Restore the old buffer, then go to the right split. */
                yed_frame_set_buff(ys->active_frame, yed_get_buffer(save_buff));
                if (save_buff != NULL) {
                    free(save_buff); save_buff = NULL;
                }
            } else {
                /*
                 * Store the current buffer so that we can restore it later in the case where we put the go-menu
                 * in the right frame.
                 * Remain in the current frame.
                 */

                if (save_buff != NULL) { free(save_buff); save_buff = NULL; }
                if (ys->active_frame->buffer != NULL) { save_buff = strdup(ys->active_frame->buffer->name); }

                return;
            }
        }

        f = find_right_frame();
        if (f == NULL) { f = make_right_frame(); }

        yed_activate_frame(f);
    }
}

void kammerdienerb_special_buffer_prepare_jump_focus(int n_args, char **args) {
    /* We'll just stay in the same frame. */
}

void kammerdienerb_special_buffer_prepare_unfocus(int n_args, char **args) {
    if (n_args != 1) {
        yed_cerr("expected 1 argument, but got %d", n_args);
        return;
    }

    if (strcmp(args[0], "*builder-output") == 0
    ||  strcmp(args[0], "*shell-output")   == 0
    ||  strcmp(args[0], "*calc")           == 0) {
        if (save_frame != NULL) {
            yed_activate_frame(save_frame);
        }
    } else {
        yed_frame_set_buff(ys->active_frame, yed_get_buffer(save_buff));
    }

    if (save_buff != NULL) {
        free(save_buff);
        save_buff = NULL;
    }
    save_frame = NULL;
}

void kammerdienerb_quit(int n_args, char **args) {
    if (ys->active_frame == find_main_frame()) {
        YEXE("quit");
        return;
    }

    YEXE("frame-delete");
}

void kammerdienerb_write_quit(int n_args, char **args) {
    YEXE("w");
    YEXE("q");
}

void kammerdienerb_find_cursor_word(int n_args, char **args) {
    char *word;

    if (n_args != 0) {
        yed_cerr("expected 0 arguments, but got %d", n_args);
        return;
    }

    word = yed_word_under_cursor();

    if (word == NULL) {
        yed_cerr("cursor is not on a word");
        return;
    }

    YEXE("find-in-buffer", word);
    YEXE("find-prev-in-buffer");

    free(word);
}

void kammerdienerb_frame_next_skip_tray(int n_args, char **args) {
    yed_frame *tray;
    yed_frame *cur_frame, *frame, **frame_it;
    int        idx;

    if (n_args != 0) {
        yed_cerr("expected 0 arguments, but got %d", n_args);
        return;
    }

    if (!ys->active_frame) {
        yed_cerr("no active frame");
        return;
    }

    if (array_len(ys->frames) == 1) { return; }

    cur_frame = ys->active_frame;
    tray      = find_tray_frame();

    idx = 0;
    array_traverse(ys->frames, frame_it) {
        if (*frame_it == cur_frame) { break; }
        idx += 1;
    }

    do {
        if (idx == array_len(ys->frames) - 1) {
            idx = 0;
        } else {
            idx += 1;
        }

        frame = *(yed_frame**)array_item(ys->frames, idx);

        if (frame != tray) { break; }
    } while (frame != cur_frame);

    yed_activate_frame(frame);
}
