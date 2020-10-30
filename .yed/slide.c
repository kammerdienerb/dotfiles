#include <yed/plugin.h>
#include <yed/highlight.h>

#define ARRAY_LOOP(a) for (__typeof((a)[0]) *it = (a); it < (a) + (sizeof(a) / sizeof((a)[0])); ++it)

highlight_info hinfo1;
highlight_info hinfo2;

void unload(yed_plugin *self) {
    highlight_info_free(&hinfo2);
    highlight_info_free(&hinfo1);
    ys->redraw = 1;
}

void syntax_slide_line_handler(yed_event *event) {
    yed_frame  *frame;
    yed_buffer *buff;
    char       *ext;
    yed_line   *line;
    yed_glyph  *g;
    int         is_cmd;
    yed_attrs   str_attr;
    int         col;

    frame = event->frame;


    if (!frame) { return; }

    buff = frame->buffer;

    if (!buff
    ||  buff->kind != BUFF_KIND_FILE
    ||  buff->flags & BUFF_SPECIAL
    ||  !buff->path) {
        return;
    }

    ext = get_path_ext(buff->path);

    if (!ext || strcmp(ext, "slide") != 0) {
        return;
    }

    line = yed_buff_get_line(buff, event->row);

    if (!line) { return; }

    yed_line_glyph_traverse(*line, g) {
        if (!isspace(g->c)) {
            is_cmd = (g->c == ':');
            break;
        }
    }

    if (is_cmd) {
        str_attr = yed_active_style_get_code_string();

        for (col = 1; col <= line->visual_width; col += 1) {
            yed_combine_attrs(array_item(event->line_attrs, col - 1), &str_attr);
        }

        highlight_line(&hinfo1, event);
        highlight_line(&hinfo2, event);
    }
}

void do_slide_run(yed_buffer *buff) {
    int  err;
    char cmd_buff[256];

    sprintf(cmd_buff, "$SHELL -c 'slide \"%s\" 2>&1 > /dev/null' 2>&1 > /dev/null &", buff->path);
    err = system(cmd_buff);
    if (err) {
        yed_cerr("failed to run '%s'", cmd_buff);
    }
}

void do_slide_run_if_not_running(yed_buffer *buff) {
    int running;

    running = !system("pgrep slide 2>&1 > /dev/null");

    if (running) {
        yed_cerr("slide is already running!");
        return;
    }

    do_slide_run(buff);
}

void do_slide_update(yed_buffer *buff) {
    int  err, running;
    char cmd_buff[256];

    running = !system("pgrep slide 2>&1 > /dev/null");

    if (!running) {
        yed_cerr("slide is not running!\n");
        yed_cprint("have you run the command 'slide-run'?");
        return;
    }

    err = system("pkill -HUP slide 2>&1 > /dev/null");
    if (err) {
        yed_cerr("failed to run 'pkill -HUP slide'");
    }
}

void slide_run(int n_args, char **args) {
    yed_frame  *frame;
    yed_buffer *buff;
    char       *ext;

    frame = ys->active_frame;

    if (!frame) {
        yed_cerr("no active frame");
        return;
    }

    buff = frame->buffer;

    if (!buff) {
        yed_cerr("active frame has no buffer");
        return;
    }

    if (buff->kind != BUFF_KIND_FILE
    ||  buff->flags & BUFF_SPECIAL
    ||  !buff->path) {
        yed_cerr("buffer isn't a slide description file");
        return;
    }

    ext = get_path_ext(buff->path);

    if (!ext || strcmp(ext, "slide") != 0) {
        yed_cerr("buffer isn't a slide description file");
        return;
    }

    do_slide_run_if_not_running(buff);
}

void slide_update(int n_args, char **args) {
    yed_frame  *frame;
    yed_buffer *buff;
    char       *ext;

    frame = ys->active_frame;

    if (!frame) {
        yed_cerr("no active frame");
        return;
    }

    buff = frame->buffer;

    if (!buff) {
        yed_cerr("active frame has no buffer");
        return;
    }

    if (buff->kind != BUFF_KIND_FILE
    ||  buff->flags & BUFF_SPECIAL
    ||  !buff->path) {
        yed_cerr("buffer isn't a slide description file");
        return;
    }

    ext = get_path_ext(buff->path);

    if (!ext || strcmp(ext, "slide") != 0) {
        yed_cerr("buffer isn't a slide description file");
        return;
    }

    do_slide_update(buff);
}

void slide_post_write_handler(yed_event *event);

int yed_plugin_boot(yed_plugin *self) {
    yed_event_handler post_write;
    yed_event_handler line;
    char *commands[] = {
        "point",
        "speed",
        "resolution",
        "begin",
        "end",
        "use",
        "include",
        "font",
        "size",
        "bold",
        "italic",
        "underline",
        "bg",
        "bgx",
        "fg",
        "fgx",
        "margin",
        "lmargin",
        "rmargin",
        "ljust",
        "cjust",
        "rjust",
        "vspace",
        "vfill",
        "bullet",
        "image",
        "translate",
    };
    char *constants[] = {
        "inf",
        "infin",
        "infinity",
    };

    yed_plugin_set_unload_fn(self, unload);

    highlight_info_make(&hinfo1);

    /* Ew.. This is sooo goofy. */
    highlight_within(&hinfo1, "begin ", "foobarbaz", 0, -1, HL_CALL);
    highlight_within(&hinfo1, "use ", "foobarbaz", 0, -1, HL_CALL);


    highlight_info_make(&hinfo2);

    highlight_numbers(&hinfo2);
    highlight_to_eol_from(&hinfo2, "#", HL_COMMENT);
    highlight_within(&hinfo2, "\"", "\"", '\\', -1, HL_STR);
    highlight_within(&hinfo2, "'", "'", '\\', -1, HL_STR);

    ARRAY_LOOP(commands)
        highlight_add_kwd(&hinfo2, *it, HL_KEY);
    /* Ew.. This is sooo goofy. (part 2) */
    highlight_within(&hinfo2, "font-bold-itali", "c", 0, 0, HL_KEY);
    highlight_within(&hinfo2, "font-bol", "d",        0, 0, HL_KEY);
    highlight_within(&hinfo2, "font-itali", "c",      0, 0, HL_KEY);
    highlight_within(&hinfo2, "no-bol", "d",          0, 0, HL_KEY);
    highlight_within(&hinfo2, "no-itali", "c",        0, 0, HL_KEY);
    highlight_within(&hinfo2, "no-underlin", "e",     0, 0, HL_KEY);
    ARRAY_LOOP(constants)
        highlight_add_kwd(&hinfo2, *it, HL_CON);

    ys->redraw = 1;


    line.kind = EVENT_LINE_PRE_DRAW;
    line.fn   = syntax_slide_line_handler;
    yed_plugin_add_event_handler(self, line);

    post_write.kind = EVENT_BUFFER_POST_WRITE;
    post_write.fn   = slide_post_write_handler;
    yed_plugin_add_event_handler(self, post_write);

    yed_plugin_set_command(self, "slide-run",    slide_run);
    yed_plugin_set_command(self, "slide-update", slide_update);

    return 0;
}

void slide_post_write_handler(yed_event *event) {
    yed_buffer *buff;
    char       *ext;

    LOG_FN_ENTER();

    buff = event->buffer;

    if (!buff
    ||  buff->kind != BUFF_KIND_FILE
    ||  buff->flags & BUFF_SPECIAL
    ||  !buff->path) {
        goto out;
    }

    ext = get_path_ext(buff->path);

    if (!ext || strcmp(ext, "slide") != 0) {
        goto out;
    }

    do_slide_update(buff);

out:
    LOG_EXIT();
}
