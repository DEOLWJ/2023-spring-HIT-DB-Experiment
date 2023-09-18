%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "syntax.tab.h"
int yycolumn = 1;
#define YY_USER_ACTION \
	yylloc.first_line = yylloc.last_line = yylineno; \
	yylloc.first_column = yycolumn; \
	yylloc.last_column = yycolumn + yyleng - 1; \
	yycolumn += yyleng;
int lines = 0;
int flag = 0;
%}

%option yylineno

SELECT SELECT
PROJECTION PROJECTION
JOIN JOIN
ID [_0-9a-zA-Z][_0-9a-zA-Z]*
LP \(
RP \)
LB \[
RB \]
AND &
COMMA ,
APOS ’
ASSIGNOP =

%%
{SELECT} {yylval = CreateNode(5,0,yylloc.first_line);yylval -> name = "SELECT";return SELECT;}
{PROJECTION} {yylval = CreateNode(5,0,yylloc.first_line);yylval -> name = "PROJECTION";return PROJECTION;}
{JOIN} {yylval = CreateNode(5,0,yylloc.first_line);yylval -> name = "JOIN";return JOIN;}
{LP} {yylval = CreateNode(5,0,yylloc.first_line);yylval -> name = "LP";return LP;}
{RP} {yylval = CreateNode(5,0,yylloc.first_line);yylval -> name = "RP";return RP;}
{LB} {yylval = CreateNode(5,0,yylloc.first_line);yylval -> name = "LB";return LB;}
{RB} {yylval = CreateNode(5,0,yylloc.first_line);yylval -> name = "RB";return RB;}
{AND} {yylval = CreateNode(5,0,yylloc.first_line);yylval -> name = "AND";return AND;}
{COMMA} {yylval = CreateNode(5,0,yylloc.first_line);yylval -> name = "COMMA";return COMMA;}
{APOS} {yylval = CreateNode(5,0,yylloc.first_line);yylval -> name = "APOS";return APOS;}
{ASSIGNOP} {yylval = CreateNode(5,0,yylloc.first_line);yylval -> name = "ASSIGNOP";return ASSIGNOP;}
{ID} {
	yylval = CreateNode(0,0,yylloc.first_line);
	yylval -> name = strdup(yytext);
	
	return ID;
	}
" "
\n {yycolumn = 1;}
\t
. {printf("Error type A at Line %d: unexpected symbol!\n",yylloc.first_line);flag++;}

%%

