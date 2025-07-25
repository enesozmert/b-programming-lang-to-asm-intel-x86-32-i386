#ifndef CODEGEN_H
#define CODEGEN_H

void emit_header(void);
void emit_footer(void);

void emit_function_start(const char *name);
void emit_function_end(void);
void emit_assignment(const char *var, int value);
void emit_return(int value);

int emit_add(int lhs, int rhs);
int emit_sub(int lhs, int rhs);
int emit_mul(int lhs, int rhs);
int emit_div(int lhs, int rhs);

void emit_if(int condition);
void emit_while(int condition);


void emit_push(int value);
void emit_call(const char *func_name, int arg_count);
void emit_assignment_expr(const char *var);

int sym_lookup_offset(const char *name);

#endif
