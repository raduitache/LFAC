%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "semantics.h"

extern FILE* yyin;
extern char* yytext;
extern int yylineno;

int yylex();
void yyerror(const char *s);

%}
%token ID TIP LOGICAL_OPERATOR ASSIGN INTEGER_NR NATURAL_NR REAL_NR CHAR STRING BOOL CLASS CONST OR AND IF ELSE WHILE
%start progr

%right ASSIGN
%left '+' '-'
%left '*' '/'
%left LOGICAL_OPERATOR
%left OR
%left AND
%left '!'

%union{
     int nr_i;
     char* string;
     char character;
     float nr_f;
}

%type <string> ID TIP LOGICAL_OPERATOR STRING CLASS CONST OR AND IF ELSE WHILE
%type <character> ASSIGN CHAR
%type <nr_i> INTEGER_NR NATURAL_NR BOOL
%type <nr_f> REAL_NR expresie
%%
progr: declaratii {printf("program corect sintactic\n");}
     ;

declaratii:  declaratie_var ';'
	     | declaratii declaratie_var ';'
          | declaratie_func
          | declaratii declaratie_func
          | declaratie_clasa ';'
          | declaratii declaratie_clasa ';'
	     ;

declaratie_var: TIP corp_declaratie
          | CONST TIP atribuire_in_declaratie
          | ID corp_declaratie  {printf("Data type not defined\n(Line %d)\n", yylineno); exit('0' - '1');} 
          | CONST ID atribuire_in_declaratie
          ;

declaratie_func: TIP ID '(' lista_semnatura ')' '{' bloc '}'
               | TIP ID '(' ')' '{' bloc '}'
               | TIP ID '(' ')' '{' '}'
               | CONST TIP ID '(' lista_semnatura ')' '{' bloc '}'
               | CONST TIP ID '(' ')' '{' bloc '}'
               | CONST TIP ID '(' ')' '{' '}'
               | ID ID '(' lista_semnatura ')' '{' bloc '}'
               | ID ID '(' ')' '{' bloc '}'
               | ID ID '(' ')' '{' '}'
               | CONST ID ID '(' lista_semnatura ')' '{' bloc '}'
               | CONST ID ID '(' ')' '{' bloc '}'
               | CONST ID ID '(' ')' '{' '}'
               ;

declaratie_clasa: CLASS ID '{' bloc_clasa '}'
               | CLASS ID '{' '}'
               ;

bloc: declaratie_var ';'
     | atribuire ';'
     | control
     | apel_functie ';'
     | bloc declaratie_var ';'
     | bloc atribuire ';'
     | bloc control
     | bloc apel_functie ';'
     ;

apel_functie: ID '(' lista_parametri ')'
          |   ID '(' ')'
          ;

lista_parametri: expresie
               | lista_parametri ',' expresie
               | atribuire
               | lista_parametri ',' atribuire
               | apel_functie
               | lista_parametri ',' apel_functie
               ;

control: if
     | while
     ;

if: IF '(' expresie ')' '{' bloc '}'
     | IF '(' expresie ')' '{' bloc '}' ELSE '{' bloc '}'
     ;

while: WHILE '(' expresie ')' '{' bloc '}'
     ;

bloc_clasa: declaratie_func
          | declaratie_var ';'
          | bloc_clasa declaratie_func
          | bloc_clasa declaratie_var ';'
          ;

lista_semnatura: membru_semnatura
               | lista_semnatura ',' membru_semnatura
               ;

membru_semnatura: TIP ID
               |  CONST TIP ID
               |  ID ID
               | CONST ID ID
               ;

corp_declaratie: ID
               | ID '[' NATURAL_NR ']'
               | atribuire_in_declaratie
               | corp_declaratie ',' ID
               | corp_declaratie ',' ID '[' NATURAL_NR ']'
               | corp_declaratie ',' atribuire_in_declaratie
               ;

expresie:  REAL_NR {$$ = $1;}
          | INTEGER_NR {$$ = (float)$1;}
          | NATURAL_NR {$$ = (float)$1;}
          | BOOL {$$ = (float)$1;}
          | CHAR {$$ = (float)$1;}
          | ID {$$ = 0.0f;}
          | expresie '+' expresie {$$ = $1 + $3; printf("%f + %f = %f\n", $1, $3, $$);}
          | expresie '-' expresie {$$ = $1 + $3; printf("%f - %f = %f\n", $1, $3, $$);}
          | expresie '*' expresie {$$ = $1 * $3; printf("%f * %f = %f\n", $1, $3, $$);}
          | expresie '/' expresie {$$ = $1 / $3; printf("%f / %f = %f\n", $1, $3, $$);}
          | '-' expresie {$$ = -$2;}
          | expresie AND expresie {$$ = $1 && $3;}
          | expresie OR expresie {$$ = $1 || $3;}
          | expresie LOGICAL_OPERATOR expresie {logical_operations(&$$, &$1, &$3, $2);}
          | '(' expresie ')' {$$ = $2;}
          | '!' expresie {$$ = !$2;}
          ;


atribuire_in_declaratie:   ID ASSIGN expresie {printf("%s = %f\n", $1, $3);}
                         | ID ASSIGN STRING {printf("%s = %s\n", $1, $3);}
                         ;

atribuire:  ID ASSIGN expresie {printf("%s = %f\n", $1, $3);}
          | ID ASSIGN STRING {printf("%s = %s\n", $1, $3);}
          | ID '[' NATURAL_NR ']' ASSIGN expresie {printf("%s[%i] = %f\n", $1, $3, $6);}
          | ID '[' NATURAL_NR ']' ASSIGN STRING {printf("%s[%i] = %s\n", $1, $3, $6);}
          ;
%%
void yyerror(const char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
yyin=fopen(argv[1],"r");
yyparse();
} 