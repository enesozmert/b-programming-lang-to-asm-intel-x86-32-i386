#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "../hdr/symtable.h"

#define MAX_SYMBOLS 1024

typedef struct {
    char *name;
    int offset;
} Symbol;

static Symbol symbols[MAX_SYMBOLS];
static int symbol_count = 0;
static int current_offset = 4; // starts at EBP - 4

void sym_add_auto(const char *name) {
    for (int i = 0; i < symbol_count; ++i) {
        if (strcmp(symbols[i].name, name) == 0)
            return; // already exists
    }

    if (symbol_count >= MAX_SYMBOLS) {
        fprintf(stderr, "Symbol table overflow\n");
        exit(1);
    }

    symbols[symbol_count].name = strdup(name);
    symbols[symbol_count].offset = current_offset;
    current_offset += 4;
    symbol_count++;
}

int sym_lookup_offset(const char *name) {
    for (int i = 0; i < symbol_count; ++i) {
        if (strcmp(symbols[i].name, name) == 0) {
            return symbols[i].offset;
        }
    }
    return -1; // not found
}

void sym_reset_locals(void) {
    for (int i = 0; i < symbol_count; ++i) {
        free(symbols[i].name);
    }
    symbol_count = 0;
    current_offset = 4;
}
