#include "yed/plugin.h"

void do_slide_update(yed_buffer *buff) {
    int  err;
    char cmd_buff[256];

    err = system("pgrep slide 2>&1 > /dev/null");

    if (err) {
        sprintf(cmd_buff, "$SHELL -c 'slide \"%s\" 2>&1 > /dev/null' 2>&1 > /dev/null &", buff->path);
        err = system(cmd_buff);
        if (err) {
            yed_cerr("failed to run '%s'", cmd_buff);
            return;
        }
    } else {
        err = system("pkill -HUP slide 2>&1 > /dev/null");
        if (err) {
            yed_cerr("failed to run 'pkill -HUP slide'");
            return;
        }
    }
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

    yed_plugin_set_command(self, "slide-update", slide_update);

    post_write.kind = EVENT_BUFFER_POST_WRITE;
    post_write.fn   = slide_post_write_handler;
    yed_plugin_add_event_handler(self, post_write);

    return 0;
}

void slide_post_write_handler(yed_event *event) {
    yed_buffer *buff;
    char       *ext;

    buff = event->buffer;

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

    do_slide_update(buff);
}
