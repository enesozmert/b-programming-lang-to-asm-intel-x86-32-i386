%{
#include "../hdr/symtable.h"
#include "../hdr/codegen.h"
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
%}

%union {
    int num;
    char *id;
    char *str;
}

%token <id> IDENTIFIER
%token <num> NUMBER
%token <str> STRING
%token EXTRN AUTO IF WHILE RETURN RELOP

%type <num> expr term factor

%%

program:
    decl_list
;

decl_list:
    decl_list decl
  | decl
;

decl:
    EXTRN extrn_list ';'
  | AUTO auto_list ';'
  | func_decl
;

extrn_list:
    extrn_list ',' IDENTIFIER
  | IDENTIFIER
;

auto_list:
    auto_list ',' IDENTIFIER
  | IDENTIFIER
;

func_decl:
    IDENTIFIER '(' ')' block
    {
        emit_function_start($1);
        emit_function_end();
    }
;

block:
    '{' stmt_list '}'
;

stmt_list:
    stmt_list stmt
  | stmt
;

stmt:
    assignment
  | if_stmt
  | while_stmt
  | return_stmt
;

assignment:
    IDENTIFIER '=' expr ';'
    {
        emit_assignment($1, $3);
    }
;

if_stmt:
    IF '(' expr ')' block
    {
        emit_if($3);
    }
;

while_stmt:
    WHILE '(' expr ')' block
    {
        emit_while($3);
    }
;

return_stmt:
    RETURN expr ';'
    {
        emit_return($2);
    }
;

expr:
    expr '+' term
    {
        $$ = emit_add($1, $3);
    }
  | expr '-' term
    {
        $$ = emit_sub($1, $3);
    }
  | term
;

term:
    term '*' factor
    {
        $$ = emit_mul($1, $3);
    }
  | term '/' factor
    {
        $$ = emit_div($1, $3);
    }
  | factor
;

factor:
      NUMBER              { $$ = $1; }
    | IDENTIFIER          { $$ = sym_lookup_offset($1); }
    | STRING               { $$ = 0; /* string için placeholder */ }
    | '(' expr ')'         { $$ = $2; }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parser error: %s\n", s);
}
