%{
#include "../hdr/symtable.h"
#include "y.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

%%

"extrn"             { return EXTRN; }
"auto"              { return AUTO; }
"if"                { return IF; }
"while"             { return WHILE; }
"return"            { return RETURN; }

[0-9]+              { yylval.num = atoi(yytext); return NUMBER; }
\"([^"\n]|\\.)*\"   { yylval.str = strdup(yytext); return STRING; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.id = strdup(yytext); return IDENTIFIER; }

"=="|"!="|"<="|">="|"<"|">" { return RELOP; }
"="                 { return '='; }
"+"|"-"|"*"|"/"|"%" { return yytext[0]; }
[{}();,]            { return yytext[0]; }

[ \t\n]+            ;   // Ignore whitespace
.                   { fprintf(stderr, "Unexpected character: %s\n", yytext); exit(1); }

%%

int yywrap(void) { return 1; }
