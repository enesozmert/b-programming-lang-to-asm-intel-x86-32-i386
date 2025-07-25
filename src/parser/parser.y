%{
#include "../hdr/symtable.h"
#include "../hdr/codegen.h"
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);
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

%type <num> expr term factor argument_list argument_list_opt

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
    auto_list ',' IDENTIFIER {
        sym_add_auto($3);
    }
  | IDENTIFIER {
        sym_add_auto($1);
    }
;

func_decl:
    IDENTIFIER '(' ')'
    {
        sym_reset_locals();
        emit_function_start($1);
    }
    block
    {
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
  | expr ';'
  | AUTO auto_list ';'
  | EXTRN extrn_list ';'
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
    expr '+' term     { $$ = emit_add($1, $3); }
  | expr '-' term     { $$ = emit_sub($1, $3); }
  | term
  ;

term:
    term '*' factor   { $$ = emit_mul($1, $3); }
  | term '/' factor   { $$ = emit_div($1, $3); }
  | factor
  ;

factor:
      NUMBER              { $$ = $1; }
    | IDENTIFIER          { $$ = sym_lookup_offset($1); }
    | IDENTIFIER '(' argument_list_opt ')'  {
        emit_call($1, $3);
        $$ = 0; // return value placeholder (eax)
    }
    | STRING              { $$ = 0; }
    | '(' expr ')'        { $$ = $2; }
;

argument_list_opt:
      /* boş */           { $$ = 0; }
    | argument_list       { $$ = $1; }
;

argument_list:
      expr                { emit_push($1); $$ = 1; }
    | argument_list ',' expr {
          emit_push($3);
          $$ = $1 + 1;
      }
;


%%

void yyerror(const char *s) {
    fprintf(stderr, "Parser error: %s\n", s);
}
