#include <yed/plugin.h>

int yed_plugin_boot(yed_plugin *self) {
    YEXE("plugin-load", "yedrc");
    YEXE("yedrc-load", "~/.yed/yedrc");
    return 0;
}
