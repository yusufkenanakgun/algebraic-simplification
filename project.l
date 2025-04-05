digit	[0-9]
letter	[A-Za-z]
%{
  #include <stdio.h>
  #include <string.h>
  #include "y.tab.h"
  #include <iostream>
  using namespace std;
  
  int linenum=1;
%}
%%
"="   return ASSIGN; 
";"   return SEMICOLON; 
[+\-*/^] { yylval.op = yytext[0]; return OP; }
{letter}({letter}|{digit})*	{yylval.str=strdup(yytext); return IDENTIFIER;}
{digit}+ { yylval.ival = atoi(yytext); return INTEGER; }
\n	{linenum++;}
[ \t]+
%%
