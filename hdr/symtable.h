#ifndef SYMTABLE_H
#define SYMTABLE_H

void sym_add_auto(const char *name);
int sym_lookup_offset(const char *name);
void sym_reset_locals(void);

#endif
