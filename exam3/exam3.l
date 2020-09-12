/* 把讨厌的注释去掉 */

%{

#include <stdio.h> 
#define LT					1
#define	LE					2
#define GT					3
#define	GE					4
#define	EQ					5
#define NE					6

#define WHILE				18
#define	DO					19
#define ID          20
#define RELOP       22

#define NEWLINE     23
#define ERRORCHAR   24

#define BRACKETS    25
#define SEMICOLON   26
#define ASSIGN      27
#define IF          28
#define ELSE        29
#define OPERATION   30
#define STRING      31

#define PROGRAM     32
#define BEGIN1      33
#define VAR         34
#define THEN        35
#define INTEGER     36
#define FLOAT       37
#define END         38
#define REAL        39
#define COMMA       40
#define COLON       41
#define INT         42
#define REA         43

union data{
  int inum;
  float fnum;
  char* c;
}yylval;


%}

 
delim		[ \t \n]
ws			{delim}+
letter	[A-Za-z]
digit		[0-9]
id			({letter}|_)({letter}|{digit}|_)*
int 		{digit}+(E[+-]?{digit}+)?
real		{digit}*(\.{digit}+)(E[+-]?{digit}+)?
allow   ((\\\\)|(\\\")|(\\\')|(\\{letter})|(\\{digit}))*
string  ({allow}|[^\"\'\n\\])*\"
end     END|END.

/* 状态（或条件）定义可以定义在这里 
 * INITIAL是一个默认的状态，不需要定义
 */
%s COMMENT SIMPLECOMMENT QUOTE

%%

<INITIAL>"/*"						{BEGIN COMMENT;}
<COMMENT>"*/"						{BEGIN INITIAL;}
<COMMENT>.|\n						{;}


 /* ECHO是一个宏，相当于 fprintf(yyout, "%s", yytext)*/

<INITIAL>{ws}	          {;}
<INITIAL>PROGRAM 				{return (PROGRAM);}
<INITIAL>INTEGER        {return (INTEGER);}
<INITIAL>REAL           {return (REAL);}
<INITIAL>BEGIN 					{return (BEGIN1);}
<INITIAL>{end} 					{return (END);}
<INITIAL>while					{return (WHILE);}
<INITIAL>do		          {return (DO);}
<INITIAL>if             {return (IF);}
<INITIAL>else           {return (ELSE);}
<INITIAL>THEN 					{return (THEN);}
<INITIAL>VAR 						{return (VAR);}
<INITIAL>{int} 					{yylval.inum=atoi(yytext); return (INT);}
<INITIAL>{real} 				{yylval.fnum=atof(yytext); return (REA);}
<INITIAL>{id}	          {yylval.c=yytext; return (ID);}
<INITIAL>"<"	          {yylval.c=yytext; return (RELOP);}
<INITIAL>"<="	          {yylval.c=yytext; return (RELOP);}
<INITIAL>"=="	          {yylval.c=yytext; return (RELOP);}
<INITIAL>"!="	          {yylval.c=yytext; return (RELOP);}
<INITIAL>">"	          {yylval.c=yytext; return (RELOP);}
<INITIAL>">="	          {yylval.c=yytext; return (RELOP);}
<INITIAL>"{"	          {return (BRACKETS);}
<INITIAL>"}"	          {return (BRACKETS);}
<INITIAL>"("	          {return (BRACKETS);}
<INITIAL>")"	          {return (BRACKETS);}
<INITIAL>";"            {return (SEMICOLON);}
<INITIAL>"="            {return (ASSIGN);}
<INITIAL>"//"           {BEGIN SIMPLECOMMENT;}
<SIMPLECOMMENT>\n       {BEGIN INITIAL;}
<SIMPLECOMMENT>.        {;}
<INITIAL>":="	          {return (ASSIGN);}
<INITIAL>":"	          {return (COLON);}
<INITIAL>"+"            {yylval.c=yytext; return (OPERATION);}
<INITIAL>"-"            {yylval.c=yytext; return (OPERATION);}
<INITIAL>"*"            {yylval.c=yytext; return (OPERATION);}
<INITIAL>"/"            {yylval.c=yytext; return (OPERATION);}
<INITIAL>","            {return (COMMA);}
<INITIAL>{string}       {return (STRING);}

<INITIAL>.							{return ERRORCHAR;}

 
%%

int yywrap (){
  return 1;
}

void writeout(int c){
  switch(c){
  	case ERRORCHAR: fprintf(yyout, "(ERRORCHAR, \"%s\") ", yytext);break;
  	
  	case PROGRAM: fprintf(yyout, "(PROGRAM, \"%s\") ", yytext);break;
    case BEGIN1: fprintf(yyout, "(BEGIN, \"%s\") ", yytext);break;
    case END: fprintf(yyout, "(END, \"%s\") ", yytext);break;
    case THEN: fprintf(yyout, "(THEN, \"%s\") ", yytext);break;
    case VAR: fprintf(yyout, "(VAR, \"%s\") ", yytext);break;
    case INTEGER: fprintf(yyout, "(INTEGER, \"%s\") ", yytext);break;
		case REAL: fprintf(yyout, "(REAL, \"%s\") ", yytext);break;
    case COMMA: fprintf(yyout, "(COMMA, \"%s\") ", yytext);break;
    case COLON: fprintf(yyout, "(COLON, \"%s\") ", yytext);break;
    case INT: fprintf(yyout, "(Integer, %d) ", yylval.inum);break;
    case REA: fprintf(yyout, "(Real, %f) ", yylval.fnum);break;
    
  	case RELOP: fprintf(yyout, "(RELOP, \"%s\") ", yylval.c);break;  	  
    case WHILE: fprintf(yyout, "(WHILE, \"%s\") ", yytext);break;
    case DO: fprintf(yyout, "(DO, \"%s\") ", yytext);break;
    case ID: fprintf(yyout, "(ID, \"%s\") ", yylval.c);break;
    case STRING: fprintf(yyout, "(STRING, \"%s\") ", yytext);break;
    case NEWLINE: fprintf(yyout, "\n");break;
    case BRACKETS: fprintf(yyout, "(BRACKETS, \"%s\") ", yytext);break;
    case SEMICOLON: fprintf(yyout, "(SEMICOLON, \"%s\") ", yytext);break;
    case ASSIGN: fprintf(yyout, "(ASSIGN, \"%s\") ", yytext);break;
    case IF: fprintf(yyout, "(IF, \"%s\") ", yytext);break;
    case ELSE: fprintf(yyout, "(ELSE, \"%s\") ", yytext);break;
    case OPERATION: fprintf(yyout, "(OPERATION, \"%s\") ", yylval.c);break;
    case SIMPLECOMMENT: fprintf(yyout, "(SIMPLECOMMENT, \"%s\") ", yytext);break;
    default:break;
  }
  return;
}


int main (int argc, char ** argv){
	int c,j=0;
	if (argc>=2){
	  if ((yyin = fopen(argv[1], "r")) == NULL){
	    printf("Can't open file %s\n", argv[1]);
	    return 1;
	  }
	  if (argc>=3){
	    yyout=fopen(argv[2], "w");
	  }
	}

	while (c = yylex()){
		writeout(c);
		j++;
		if (j%5 == 0) writeout(NEWLINE);
	}
	if(argc>=2){
	  fclose(yyin);
	  if (argc>=3) fclose(yyout);
	}
	return 0;
}
