#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hdr/symtable.h"
#include "hdr/codegen.h"
#include "hdr/parser.h"
#include "hdr/lexer.h"

static void usage(const char *progname) {
    fprintf(stderr, "Usage: %s [file.b]\n", progname);
    fprintf(stderr, "If no file is specified, reads from stdin.\n");
}

int main(int argc, char **argv) {
    FILE *input = stdin;

    if (argc > 2) {
        usage(argv[0]);
        return EXIT_FAILURE;
    } else if (argc == 2) {
        input = fopen(argv[1], "r");
        if (!input) {
            perror(argv[1]);
            return EXIT_FAILURE;
        }
    }

    yyin = input;

    emit_header();

    if (yyparse() != 0) {
        fprintf(stderr, "Compilation failed: syntax error.\n");
        fclose(input);
        return EXIT_FAILURE;
    }

    emit_footer();

    fclose(input);

    yylex_destroy();

    return EXIT_SUCCESS;
}
