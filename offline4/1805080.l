%option noyywrap

%x STRING
%x STRINGSPECIAL
%x SINGLECOMMENT
%x MULTICOMMENT
%x CHARACTER

%{
#include<stdio.h>
#include<stdlib.h>

#include<iostream>
#include<string>
#include<fstream>

#include"symbolTable.h"

#include "y.tab.h"

using namespace std;

extern YYSTYPE yylval;
extern ofstream logout;
extern ofstream errorout;

int line_count=1;
int error_count=0;
int counter=0;


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

char* toSpecial(char* str){
	char *p;
	if(str[2]=='t'){
		p[0]='\t';
	}
	else if(str[2]=='b'){
		p[0]='\b';
	}
	else if(str[2]=='n'){
		p[0]='\n';
	}
	p[1]='\0';
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
		if(*p=='-')return "DECOP";
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

SPECIAL \\[ntfvab\\\']

CONSTCHAR {DIGIT}|{LETTER}


%%

{NEWLINE} {line_count++;}

"println" { return PRINTLN;}


{KEYWORD} 	{
			//string text = string(yytext); 
			//tokenout<<"<"<<TOUPPER(yytext)<<"> ";
			//logout<<"\nLine no "<<line_count<<": Token <"<<TOUPPER(yytext)<<"> Lexeme "<<text<<" found\n";
			//return text;

			string text = string(yytext); 
			if(text=="if")return IF;
			else if(text=="else")return ELSE;
			else if(text=="for")return FOR;
			else if(text=="while")return WHILE;
			else if(text=="do")return DO;
			else if(text=="break")return BREAK;
			else if(text=="int")return INT;
			else if(text=="char")return CHAR;
			else if(text=="float")return FLOAT;
			else if(text=="double")return DOUBLE;
			else if(text=="void")return VOID;
			else if(text=="return")return RETURN;
			else if(text=="switch")return SWITCH;
			else if(text=="case")return CASE;
			else if(text=="default")return DEFAULT;
			else if(text=="continue")return CONTINUE;
			else{}
		}

{WHITESPACE} {;}

{OPERATOR}	{
			//string op = GETOPERATOR(yytext);
			//tokenout<<"<"<<op;
			//tokenout<<", "<<yytext;
			//tokenout<<"> ";
			//logout<<"\nLine no "<<line_count<<": Token <"<<op<<"> Lexeme "<<yytext<<" found\n";

			string op = GETOPERATOR(yytext);
			if(op=="INCOP")return INCOP;
			if(op=="DECOP")return DECOP;
			if(op=="ASSIGNOP")return ASSIGNOP;
			if(op=="NOT")return NOT;
			if(op=="COMMA")return COMMA;
			if(op=="SEMICOLON")return SEMICOLON;

			string temp(yytext);
				symbolInfo* sym = new symbolInfo(temp, "ID");

				yylval.symbolinfo = sym;

			if(op=="ADDOP")return ADDOP;
			if(op=="MULOP")return MULOP;
			if(op=="RELOP")return RELOP;
			if(op=="LOGICOP")return LOGICOP;

}

		
{DIGIT}+ 	{
				//tokenout<<"<CONST_INT, "<<yytext<<"> ";
				//logout<<"\nLine no "<<line_count<<": Token <CONST_INT> Lexeme "<<yytext<<" found\n";
				//insert in symbol table and print symbol table content(only non empty buckets);
				//if(table.Insert(string(yytext),"CONST_INT")==true){
				//	table.printAll();
				//}
				string temp(yytext);
				symbolInfo* sym = new symbolInfo(temp, "int");

				yylval.symbolinfo = sym;
				return CONST_INT;
			}

[0-9]*[.]([0-9]*[.][0-9]*)+	{
			errorout<<"\nError at line no "<<line_count<<": Too many decimal points "<<yytext<<"\n";
			error_count++;
}

[0-9]+(\.[0-9]+)?(E[+-]?[0-9]+)([0-9]*[.][0-9]*)+	{
			errorout<<"\nError at line no "<<line_count<<": Ill formed number "<<yytext<<"\n";
			error_count++;
}


{FLOAT}		{
				//tokenout<<"<CONST_FLOAT, "<<yytext<<"> ";
				//logout<<"\nLine no "<<line_count<<": Token <CONST_FLOAT> Lexeme "<<yytext<<" found\n";
				//insert in symbol table and print symbol table content(only non empty buckets);
				//if(table.Insert(string(yytext),"CONST_FLOAT")==true){
				//	table.printAll();
				//}
				string temp(yytext);
				symbolInfo* sym = new symbolInfo(temp, "float");

				yylval.symbolinfo = sym;
				return CONST_FLOAT;
}


\'	{
		//BEGIN CHARACTER;
}

<CHARACTER>\' {
		//logout<<"\nError at line no "<<line_count<<": Empty character constant error \'"<<yytext<<"\n";
		//error_count++;
		//BEGIN INITIAL;
	}

<CHARACTER>\\\' {
		//logout<<"\nError at line no "<<line_count<<": Unterminated character \'"<<yytext<<"\n";
		//error_count++;
		//BEGIN INITIAL;
}

<CHARACTER>{LETTER}?; {
		//logout<<"\nError at line no "<<line_count<<": Unterminated character \'"<<yytext<<"\n";
		//error_count++;
		//BEGIN INITIAL;	
}

<CHARACTER>{NEWLINE}	{
		//logout<<"\nError at line no "<<line_count<<": Unterminated character \'\n";
		//error_count++;
		//line_count++;
		//BEGIN INITIAL;
	}

<CHARACTER>{WHITESPACE}+	{
		//logout<<"\nError at line no "<<line_count<<": Unterminated character \'"<<yytext<<"\n";
		//error_count++;
		//BEGIN INITIAL;
	}




\'{LETTER}({WHITESPACE}|{NEWLINE})	{
		//logout<<"\nError at line no "<<line_count<<": Unterminated character "<<yytext<<"\n";
		//error_count++;
	}


\'{CONSTCHAR}\'	{
				//tokenout<<"<CONST_CHAR, "<<yytext[1]<<"> ";
				//logout<<"\nLine no "<<line_count<<": Token <CONST_CHAR> Lexeme "<<yytext<<" found";
				//logout<<" --> <CHAR_CONST, "<<yytext[1]<<"> \n";
				//insert in symbol table and print symbol table content(only non empty buckets);
				
				//if(table.Insert(string(yytext),"CONST_CHAR")==true){
				//	table.printAll();
				//}
			}
\'{SPECIAL}\'	{
				//char* str = toSpecial(yytext);
				//tokenout<<"<CONST_CHAR, "<<str<<"> ";
				//logout<<"\nLine no "<<line_count<<": Token <CONST_CHAR> Lexeme "<<yytext<<"found";
				//logout<<" --> <CHAR_CONST, "<<str<<"> \n";
				//insert in symbol table and print symbol table content(only non empty buckets);
				//str=NULL;
				//if(table.Insert(string(yytext),"CONST_CHAR")==true){
				//	table.printAll();
				//}
			}

\'{WHITESPACE}*{LETTER}{LETTER}+{WHITESPACE}*{LETTER}*\'	{
			//logout<<"\nError at line no "<<line_count<<": Multi character constant error "<<yytext<<"\n";
			//error_count++;

}



{DIGIT}+({IDENTIFIER}+{DIGIT}*)+	{
			errorout<<"\nError at line no "<<line_count<<": Invalid prefix on ID or invalid suffix on Number "<<yytext<<"\n";
			error_count++;
}



{IDENTIFIER}	{
				//tokenout<<"<ID, "<<yytext<<"> ";
				//logout<<"\nLine no "<<line_count<<": Token <ID> Lexeme "<<yytext<<" found\n";
				//insert in symbol table and print symbol table content(only non empty buckets);
				//if(table.Insert(string(yytext),"ID")==true){
				//	table.printAll();
				//}
				string temp(yytext);
				symbolInfo* sym = new symbolInfo(temp, "ID");

				yylval.symbolinfo = sym;
				return ID;
			}

"("		{
				//tokenout<<"<LPAREN, "<<yytext<<"> ";
				//logout<<"\nLine no "<<line_count<<": Token <LPAREN> Lexeme "<<yytext<<" found\n";
				return LPAREN;
		}

")"		{
				//tokenout<<"<RPAREN, "<<yytext<<"> ";
				//logout<<"\nLine no "<<line_count<<": Token <RPAREN> Lexeme "<<yytext<<" found\n";
				return RPAREN;
		}
"{"		{
				//tokenout<<"<LCURL, "<<yytext<<"> ";
				//logout<<"\nLine no "<<line_count<<": Token <LCURL> Lexeme "<<yytext<<" found\n";
				//table.Enter();
				return LCURL;
		}
"}"		{
				//tokenout<<"<RCURL, "<<yytext<<"> ";
				//logout<<"\nLine no "<<line_count<<": Token <RCURL> Lexeme "<<yytext<<" found\n";
				//table.Exit();
				return RCURL;
		}
"["		{
				//tokenout<<"<LTHIRD, "<<yytext<<"> ";
				//logout<<"\nLine no "<<line_count<<": Token <LTHIRD> Lexeme "<<yytext<<" found\n";
				return LTHIRD;
		}			
"]"		{
				//tokenout<<"<RTHIRD, "<<yytext<<"> ";
				//logout<<"\nLine no "<<line_count<<": Token <RTHIRD> Lexeme "<<yytext<<" found\n";
				return RTHIRD;

}

\"	{
			//BEGIN STRING;
			//counter = 0;
			//tokenstr="";
			//logstr="";
			//tokenstr+=yytext;
			//logstr+=yytext;
}

<STRING>\\\" {
	//tokenstr+="\"";
	//logstr+=yytext;
}

<STRING>\" {
			//tokenstr+=yytext;
			//logstr+=yytext;
			//tokenout<<"<STRING, "<<tokenstr<<"> ";
			//logout<<"\nLine no "<<line_count<<": Token <STRING> Lexeme "<<logstr<<" found";
			//logout<<" --> <STRING, "<<tokenstr<<">\n";
			//line_count+=counter;
			//counter=0;
			//BEGIN INITIAL;
}

<STRING>\\	{
			//BEGIN STRINGSPECIAL;			
	}

<STRINGSPECIAL>[t] {
			//logstr+="\\t";
			//tokenstr+='\t';
			//BEGIN STRING;
}

<STRINGSPECIAL>{NEWLINE}	{
			//counter++;
			//logstr+="\\\n";
			//BEGIN STRING;
}
<STRINGSPECIAL>{WHITESPACE} {}
<STRINGSPECIAL>.	{
			//logstr+="\\";
			//logstr+=yytext;
			//BEGIN STRING;	
}

<STRING>{NEWLINE}	{
			//logout<<"\nError at line no "<<line_count<<": Unterminated String "<<logstr<<"\n";
			//counter++;
			//error_count++;
			//line_count+=counter;
			//counter=0;
			//BEGIN INITIAL;			
	}

<STRING>.	{
			//tokenstr+=string(yytext);
			//logstr+=string(yytext);
}

<STRING><<EOF>>	{		
			//logout<<"\nLine no "<<line_count<<" : Unterminated String "<<logstr<<"\n";
			//line_count+=counter;
			//BEGIN INITIAL;	
			//error_count++;		
	}




"//"	{
			//BEGIN SINGLECOMMENT;
			//logstr="//";
			//counter=0;
		}
<SINGLECOMMENT>{WHITESPACE} {
	//tokenstr+=yytext;
	//logstr+=yytext;
}

<SINGLECOMMENT>{NEWLINE}{WHITESPACE}* {		
			//logout<<"\nLine no "<<line_count<<": Token <COMMENT> Lexeme "<<logstr<<" found \n";
			//BEGIN INITIAL;
			//counter++;
			//line_count+=counter;
}

<SINGLECOMMENT>\\\n {
	//logstr+="\\\n";
	//counter++;
}


<SINGLECOMMENT>. {
			//logstr+=string(yytext);
}



"/*"	{
			//BEGIN MULTICOMMENT;
			//counter=0;
			//logstr="";
			//logstr+=yytext;
		}
<MULTICOMMENT>{NEWLINE} {
			//counter++;
			//logstr+=string(yytext);
		}

<MULTICOMMENT>"*/" {
			//logstr+="*/";
			//logout<<"\nLine no "<<line_count<<": Token <COMMENT> Lexeme "<<logstr<<" found\n";
			//BEGIN INITIAL;
			//line_count+=counter;
			//counter=0;
		}

<MULTICOMMENT>. {
			//logstr+=string(yytext);
}
<MULTICOMMENT><<EOF>> {
			//BEGIN INITIAL;
			//logout<<"\nError at line no "<<line_count<<": Unterminated Comment "<<logstr<<"\n";
			//line_count+=counter;
			//error_count++;
		}

.	{

		//logout<<"\nError at line no " <<line_count<<": Unrecognized character "<<yytext<<"\n";
		//error_count++;
}


%%
