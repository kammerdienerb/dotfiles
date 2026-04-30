#include <yed/plugin.h>

#if 0
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
#endif

int yed_plugin_boot(yed_plugin *self) {
    char *path;
    char  buff[1024];

    YED_PLUG_VERSION_CHECK();

    LOG_FN_ENTER();

    yed_add_plugin_dir("~/projects/yed-julie");
    YEXE("plugin-load", "julie");

    path = get_config_item_path("julie/main.j");
    snprintf(buff, sizeof(buff), "eval-file \"%s\"", path);
    free(path);
    YEXE("julie-eval", buff);

    LOG_EXIT();
    return 0;
}
