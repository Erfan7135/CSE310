%option noyywrap

%x STRING
%x SINGLECOMMENT
%x MULTICOMMENT

%{
#include<stdio.h>
#include<stdlib.h>
#include<string>
#include<iostream>
#include<fstream>
using namespace std;

//ifstream fin("in.txt",std::ifstream::in);
ofstream logout("1805080_log.txt",std::ofstream::out);
ofstream tokenout("1805080_token.txt",std::ofstream::out);


#include"symbolInfo.h"
#include"scopeTable.h"
#include"symbolTable.h"



int line_count=1;
int error_count=0;
int counter=0;

symbolTable table = symbolTable(7);

string tokenstr;
string logstr;

char* TOUPPER(char* str){
	char  *p=str;
	while(*str!='\0'){
		*str=toupper(*str);
		str++;
	}
	return p;
}

string GETOPERATOR(char* str){
	char *p=str;
	if(*p=='+'){
		p++;
		if(*p=='+')return "INCOP";
		return "ADDOP";
	}
	else if(*p=='-'){
		p++;
		if(*p=='-')return "INCOP";
		return "ADDOP";
	}
	else if(*p=='*' || *p=='/' || *p=='%'){
		return "MULOP";
	}
	else if(*p=='<' || *p=='>'){
		return "RELOP";
	}
	else if(*p=='&' || *p=='|'){
		return "LOGICOP";
	}
	else if(*p=='='){
		p++;
		if(*p=='=')return "RELOP";
		return "ASSIGNOP";
	}
	else if(*p=='!'){
		p++;
		if(*p=='=')return "RELOP";
		return "NOT";
	}
	else if(*p==';'){
		return "SEMICOLON";
	}
	else if(*p==','){
		return "COMMA";
	}
	return NULL;
}



%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n
IDENTIFIER [_a-zA-Z][_a-zA-Z0-9]*

KEYWORD "if"|"else"|"for"|"while"|"do"|"break"|"int"|"char"|"float"|"double"|"void"|"return"|"switch"|"case"|"default"|"continue"

OPERATOR "+"|"-"|"*"|"/"|"%"|"++"|"--"|"="|"<"|">"|"<="|">="|"=="|"!="|"&&"|"||"|"!"|","|";"

FLOAT [0-9]+(\.[0-9]+)?(E[+-]?[0-9]+)?

SPECIAL "\n"|"\t"|"\f"|"\r"|"\v"|"\\"|"\0"

CONSTCHAR {SPECIAL}|([\'][a-zA-Z][\'])


%%

{NEWLINE} {line_count++;}

{KEYWORD} 	{
			string text = string(yytext); 
			tokenout<<"<"<<TOUPPER(yytext)<<">";
			logout<<"Line no "<<line_count<<": TOKEN <"<<TOUPPER(yytext)<<"> Lexeme "<<text<<" found\n\n";
		}

{WHITESPACE} {;}

{OPERATOR}	{
			string op = GETOPERATOR(yytext);
			tokenout<<"<"<<op<<">";
			logout<<"Line no "<<line_count<<": TOKEN <"<<op<<"> Lexeme "<<yytext<<" found\n\n";
}

		
{DIGIT}+ 	{
				tokenout<<"<CONST_INT,"<<yytext<<">";
				logout<<"Line no "<<line_count<<": TOKEN <CONST_INT> Lexeme "<<yytext<<" found\n\n";
				//insert in symbol table and print symbol table content(only non empty buckets);
				if(table.Insert(string(yytext),"CONST_INT")==true){
					table.printAll();
				}
			}

[0-9]*[.]([0-9]*[.][0-9]*)+	{
			logout<<"Line no "<<line_count<<": ERROR: Too many decimal point in "<<yytext<<"\n\n";
			error_count++;
}

[0-9]+(\.[0-9]+)?(E[+-]?[0-9]+)([0-9]*[.][0-9]*)+	{
			logout<<"ERROR in line no "<<line_count<<": Ill formed number "<<yytext<<"\n\n";
			error_count++;
}


{FLOAT}		{
				tokenout<<"<CONST_FLOAT,"<<yytext<<">";
				logout<<"Line no "<<line_count<<": TOKEN <CONST_FLOAT> Lexeme "<<yytext<<" found\n\n";
				//insert in symbol table and print symbol table content(only non empty buckets);
				if(table.Insert(string(yytext),"CONST_FLOAT")==true){
					table.printAll();
				}
			}



\'\'	{
		logout<<"Error in Line no "<<line_count<<": Empty character constant error "<<yytext<<"\n\n";
		error_count++;
	}

\'{WHITESPACE}*	{
		logout<<"Error in Line no "<<line_count<<": Unterminated character "<<yytext<<"\n\n";
		error_count++;
	}

\'{NEWLINE}*	{
		logout<<"Error in Line no "<<line_count<<": Unterminated character "<<yytext<<"\n\n";
		error_count++;
		line_count++;
	}

\'{SPECIAL}	{
				//logout<<"Error in Line no "<<line_count<<": Unterminated special character "<<yytext<<"\n\n";
				//error_count++;	
			}

\'{LETTER}	{
		tokenout<<"<IDENTIFIER,"<<yytext<<">";
		logout<<"Error in Line no "<<line_count<<": Unterminated character "<<yytext<<"\n\n";
		error_count++;
	}






{CONSTCHAR}	{
				tokenout<<"<CONST_CHAR,"<<yytext<<">";
				logout<<"Line no "<<line_count<<": TOKEN <CONST_CHAR> Lexeme "<<yytext<<" found\n\n";
				//insert in symbol table and print symbol table content(only non empty buckets);
				
				if(table.Insert(string(yytext),"CONST_CHAR")==true){
					table.printAll();
				}
			}

\'{LETTER}{LETTER}+{WHITESPACE}*{LETTER}*\'	{
			logout<<"ERROR in Line no "<<line_count<<": Multi character constant error for character sequence "<<yytext<<"\n\n";
			error_count++;

}



{DIGIT}+({IDENTIFIER}+{DIGIT}*)+	{
			logout<<"ERROR in line no "<<line_count<<": Invalid Suffix on numeric constant or invalid prefix on identifier for character sequence "<<yytext<<"\n\n";
			error_count++;
}



{IDENTIFIER}	{
				tokenout<<"<ID,"<<yytext<<">";
				logout<<"Line no "<<line_count<<": TOKEN <ID> Lexeme "<<yytext<<" found\n\n";
				//insert in symbol table and print symbol table content(only non empty buckets);
				if(table.Insert(string(yytext),"ID")==true){
					table.printAll();
				}
			}

"("		{
				tokenout<<"<LPAREN>";
				logout<<"Line no "<<line_count<<": TOKEN <LPAREN> Lexeme "<<yytext<<" found\n\n";
		}

")"		{
				tokenout<<"<RPAREN>";
				logout<<"Line no "<<line_count<<": TOKEN <RPAREN> Lexeme "<<yytext<<" found\n\n";
		}
"{"		{
				tokenout<<"<LCURL>";
				logout<<"Line no "<<line_count<<": TOKEN <LCURL> Lexeme "<<yytext<<" found\n\n";
				table.Enter();
		}
"}"		{
				tokenout<<"<RCURL>";
				logout<<"Line no "<<line_count<<": TOKEN <RCURL> Lexeme "<<yytext<<" found\n\n";
				table.Exit();
		}
"["		{
				tokenout<<"<LTHIRD>";
				logout<<"Line no "<<line_count<<": TOKEN <LTHIRD> Lexeme "<<yytext<<" found\n\n";
		}			
"]"		{
				tokenout<<"<RTHIRD>";
				logout<<"Line no "<<line_count<<": TOKEN <RTHIRD> Lexeme "<<yytext<<" found\n\n";

}

\"	{
			BEGIN STRING;
			counter = 0;
			tokenstr="";
			logstr="";
			tokenstr+=yytext;
			logstr+=yytext;
}

<STRING>\" {
			tokenstr+=yytext;
			logstr+=yytext;
			tokenout<<"<STRING,"<<tokenstr<<">";
			logout<<"Line no "<<line_count<<": TOKEN <STRING> Lexeme "<<logstr<<" found\n\n";
			counter=0;
			BEGIN INITIAL;
}

<STRING>\\\n	{
			tokenstr+="\\n";
			logstr+=yytext;
			counter++;			
	}



<STRING>\n	{
			tokenstr+=yytext;
			logout<<"ERROR in Line no :"<<line_count<<" : Unfinished String "<<logstr<<"\n\n";
			counter++;
			error_count++;
			line_count+=counter;
			counter=0;
			BEGIN INITIAL;			
	}




<STRING>.	{
			tokenstr+=string(yytext);
			logstr+=string(yytext);
}

<STRING><<EOF>>	{
			logstr+="\"";		
			logout<<"ERROR in Line no "<<line_count<<" : Unfinished String "<<logstr<<"\n";
			counter++;
			line_count+=counter;
			BEGIN INITIAL;	
			error_count++;		
	}




"//"	{
			BEGIN SINGLECOMMENT;

			logstr="//";
			tokenstr="//";

		}
<SINGLECOMMENT>\n {
			logout<<"Line no "<<line_count<<": Token <COMMENT> lexeme "<<logstr<<"fount : found\n\n";
			tokenout<<"<COMMENT,"<<tokenstr<<">";
			BEGIN INITIAL;
}
<SINGLECOMMENT>. {
			logstr+=string(yytext);
			tokenstr+=string(yytext);
}



"/**"	{
			BEGIN MULTICOMMENT;
			counter=0;
			logstr="";
			logstr+=yytext;
			tokenstr="";
			tokenstr+=yytext;
		}
<MULTICOMMENT>{NEWLINE} {
			counter++;
			logstr+=string(yytext);
			tokenstr+="\\n";
		}

<MULTICOMMENT>"*/" {
			logstr+="\"";
			logout<<"Line no "<<line_count<<": Token <COMMENT> lexeme : "<<logstr<<" found\n\n";
			tokenout<<"<COMMENT,"<<tokenstr<<">";
			BEGIN INITIAL;
			line_count+=counter;
			counter=0;
		}

<MULTICOMMENT>. {
			logstr+=string(yytext);
}
<MULTICOMMENT><<EOF>> {
			BEGIN INITIAL;
			logout<<"Line no "<<line_count<<": ERROR: Unfinished comment "<<logstr<<"\n\n";
			counter++;
			line_count+=counter;
			error_count++;
		}




.	{

		logout<<"Unrecognized character "<<yytext<<"\n\n";
}

<<EOF>>	{
		logout<<"Total Lines :"<<line_count-1<<"\n\n";
	
		logout<<"Total Errors :"<<error_count<<"\n\n";

		return 0;

	}

%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");

	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	

	yyin= fin;
	yylex();
	fclose(yyin);
	
	return 0;
}
