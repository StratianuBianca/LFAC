%{
#include <stdio.h>
#include "y.tab.h"
#include <string.h>


%}
%option noyywrap
%%
"int"|"float"|"char"|"string"|"bool" {yylval.string=strdup(yytext);return TIP;}
"create"  {return CREATE;}
"constanta" {return CONST;}
"if" {return IF;}
"else" {return ELSE;}
"while" {return WHILE;}
"for" {return FOR;}
"adevarat" {yylval.boolval=1;return TRUE;}
"fals" {yylval.boolval=0;return FALSE;}
"["[1-9][0-9]*"]" { 
    char mesaj[100]; 
    strcpy(mesaj, yytext + 1); 
    mesaj[strlen(mesaj) - 1] = 0; // eliminam [ ]
    strcpy(yylval.dim, mesaj); 
    return DIMENSIUNE; 
}
"main" {return MAIN;}
Eval {return EVAL;}
'\ ?[a-zA-Z]\ ?[a-zA-Z0-9]*\ ?' {  yylval.str = strdup(yytext); return SIR;}
"concatenare" { return CONCAT;}
"compara" {return COMPARE;}
"return" { return RETURN; }
[a-zA-Z][a-zA-Z0-9]* {yylval.string=strdup(yytext);return ID;}
">=" { return GEQ; }
"==" { return EQ; }
"<=" { return LEQ; }
"!=" { return NEQ; }
"=" {return ASSIGN;}
[0-9]+ {yylval.number=atoi(yytext);return NR;}
-?[0-9]+"."[0-9]+ {yylval.f_value = atof(yytext);return NR_R;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

 
