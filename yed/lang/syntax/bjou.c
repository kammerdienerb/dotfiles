#include <yed/plugin.h>
#include <yed/syntax.h>

static yed_syntax syn;

#define ARRAY_LOOP(a) for (__typeof((a)[0]) *it = (a); it < (a) + (sizeof(a) / sizeof((a)[0])); ++it)

#define _CHECK(x, r)                                                      \
do {                                                                      \
    if (x) {                                                              \
        LOG_FN_ENTER();                                                   \
        yed_log("[!] " __FILE__ ":%d regex error for '%s': %s", __LINE__, \
                r,                                                        \
                yed_syntax_get_regex_err(&syn));                          \
        LOG_EXIT();                                                       \
    }                                                                     \
} while (0)

#define SYN()          yed_syntax_start(&syn)
#define ENDSYN()       yed_syntax_end(&syn)
#define APUSH(s)       yed_syntax_attr_push(&syn, s)
#define APOP(s)        yed_syntax_attr_pop(&syn)
#define RANGE(r)       _CHECK(yed_syntax_range_start(&syn, r), r)
#define ONELINE()      yed_syntax_range_one_line(&syn)
#define SKIP(r)        _CHECK(yed_syntax_range_skip(&syn, r), r)
#define ENDRANGE(r)    _CHECK(yed_syntax_range_end(&syn, r), r)
#define REGEX(r)       _CHECK(yed_syntax_regex(&syn, r), r)
#define REGEXSUB(r, g) _CHECK(yed_syntax_regex_sub(&syn, r, g), r)
#define KWD(k)         yed_syntax_kwd(&syn, k)

#ifdef __APPLE__
#define WB "[[:>:]]"
#else
#define WB "\\b"
#endif

void estyle(yed_event *event)   { yed_syntax_style_event(&syn, event);         }
void ebuffdel(yed_event *event) { yed_syntax_buffer_delete_event(&syn, event); }
void ebuffmod(yed_event *event) { yed_syntax_buffer_mod_event(&syn, event);    }
void eline(yed_event *event)  {
    yed_frame *frame;

    frame = event->frame;

    if (!frame
    ||  !frame->buffer
    ||  frame->buffer->kind != BUFF_KIND_FILE
    ||  frame->buffer->ft != yed_get_ft("bJou")) {
        return;
    }

    yed_syntax_line_event(&syn, event);
}
void ehigh(yed_event *event)  {
    if (event->ft == yed_get_ft("bJou")) {
        yed_syntax_highlight_request_event(&syn, event);
        event->cancel = 1;
    }
}


void unload(yed_plugin *self) {
    yed_syntax_free(&syn);
}

int yed_plugin_boot(yed_plugin *self) {
    yed_event_handler style;
    yed_event_handler buffdel;
    yed_event_handler buffmod;
    yed_event_handler line;
    yed_event_handler high;

    char              *kwds[] = {
        "as",            "or",
        "and",           "bor",      "new",     "not",     "ref",
        "Type",          "band",     "bneg",    "bshl",    "bshr",   "bxor",   "enum",   "proc", "some", "this", "type",
        "const",         "print",    "using",
        "delete",        "extern",   "import",  "module",  "sizeof",
        "extends",       "include",
        "abstract",
        "__inline__",
        "__no_mangle__",
    };

    char              *control_flow[] = {
        "do", "if", "in", "for", "else", "break", "while", "return", "foreach", "continue",
    };

    char              *typenames[] = {
        "i8", "u8", "f32", "f64", "i16", "i32", "i64", "int", "u16", "u32", "u64",
        "bool", "char", "f128", "long", "none", "void", "float", "short", "double",
    };
    char              *constants[] = {
        "NULL", "nothing", "true", "false",
    };

    YED_PLUG_VERSION_CHECK();

    yed_plugin_set_unload_fn(self, unload);

    style.kind = EVENT_STYLE_CHANGE;
    style.fn   = estyle;
    yed_plugin_add_event_handler(self, style);

    buffdel.kind = EVENT_BUFFER_PRE_DELETE;
    buffdel.fn   = ebuffdel;
    yed_plugin_add_event_handler(self, buffdel);

    buffmod.kind = EVENT_BUFFER_POST_MOD;
    buffmod.fn   = ebuffmod;
    yed_plugin_add_event_handler(self, buffmod);

    line.kind = EVENT_LINE_PRE_DRAW;
    line.fn   = eline;
    yed_plugin_add_event_handler(self, line);

    high.kind = EVENT_HIGHLIGHT_REQUEST;
    high.fn   = ehigh;
    yed_plugin_add_event_handler(self, high);


    SYN();
        APUSH("&code-comment");
            RANGE("#"); ONELINE(); ENDRANGE("$");
        APOP();

        APUSH("&code-string");
            REGEX("'(\\\\.|[^'\\\\])'");

            RANGE("\""); SKIP("\\\\\"");
                APUSH("&code-escape");
                    REGEX("\\\\.");
                APOP();
            ENDRANGE("\"");
        APOP();

        APUSH("&code-fn-call");
            REGEXSUB("([[:alpha:]_][[:alnum:]_]*)[[:space:]]*\\(", 1);
        APOP();

        APUSH("&code-number");
            REGEXSUB("(^|[^[:alnum:]_])(-?([[:digit:]]+\\.[[:digit:]]*)|(([[:digit:]]*\\.[[:digit:]]+)))"WB, 2);
            REGEXSUB("(^|[^[:alnum:]_])(-?[[:digit:]]+)"WB, 2);
            REGEXSUB("(^|[^[:alnum:]_])(0[xX][0-9a-fA-F]+)"WB, 2);
        APOP();

        APUSH("&code-keyword");
            ARRAY_LOOP(kwds) KWD(*it);
        APOP();

        APUSH("&code-control-flow");
            ARRAY_LOOP(control_flow) KWD(*it);
        APOP();

        APUSH("&code-typename");
            ARRAY_LOOP(typenames) KWD(*it);
        APOP();

        APUSH("&code-constant");
            ARRAY_LOOP(constants) KWD(*it);
        APOP();

        APUSH("&code-preprocessor");
            REGEX("\\\\[a-zA-Z_][0-9a-zA-Z_]*");
        APOP();


        APUSH("&code-field");
            REGEXSUB("\\.[[:space:]]*([[:alpha:]_][[:alnum:]_]*)", 1);
        APOP();
    ENDSYN();

    return 0;
}
