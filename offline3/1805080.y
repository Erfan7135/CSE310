%{

#include<bits/stdc++.h>

#include <stdio.h>
#include <stdlib.h>

#include "symbolTable.h"

#include<iostream>
#include<fstream>
using namespace std;


int yyparse(void);
int yylex(void);

ofstream logout("1805080_log.txt",std::ofstream::out);
ofstream errorout("1805080_error.txt",std::ofstream::out);


extern int line_count;
extern int error_count;

extern FILE *yyin;

symbolTable st(50);
    

void yyerror(char *s){
	logout << "Error at line " << line_count << ": Syntax Error\n";
	errorout << "Error at line " << line_count << ": Syntax Error\n";
	error_count++;
}






%}


%union {
	symbolInfo* symbolinfo;
}


%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE 
%token INCOP DECOP ASSIGNOP NOT 
%token LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD
%token COMMA SEMICOLON PRINTLN

%token <symbolinfo> ID CONST_INT CONST_FLOAT CONST_CHAR

%token <symbolinfo> ADDOP MULOP RELOP LOGICOP

%type <symbolinfo> start program unit var_declaration variable type_specifier declaration_list
%type <symbolinfo> expression_statement func_declaration parameter_list func_definition
%type <symbolinfo> compound_statement statements unary_expression factor statement arguments
%type <symbolinfo> expression logic_expression simple_expression rel_expression term argument_list


%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start   : program
        {
            logout<< "Line "<<line_count-1<<": start : program\n";
            $$ = $1;
            logout << $$->getName()<<"\n\n";
        }
;
program : program unit
        {
            logout << "Line "<<line_count<<": program : program unit\n\n";
            $$ = new symbolInfo($1->getName() + "\n" + $2->getName(), "program");
            logout << $$->getName()<<"\n\n";
        }
    | unit
        {
            logout << "Line "<<line_count<<": program : unit\n\n";
            $$ = $1;
            logout << $$->getName()<<"\n\n";
        }
;
unit : var_declaration
        {
            logout << "Line "<<line_count<<": unit : var_declaration\n\n";
            $$ = $1;
            logout << $$->getName()<<"\n\n";
        }
    | func_declaration
        {
            logout << "Line "<<line_count<<": unit : func_declaration\n\n";
            $$ = $1;
            logout << $$->getName()<<"\n\n";
        }
    | func_definition
        {
            logout << "Line "<<line_count<<": unit : func_definition\n\n";
            $$ = $1;
            logout << $$->getName()<<"\n\n";
        }
;
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON 
        {
            logout << "Line "<<line_count<<": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n";
            $$ = new symbolInfo($1->getName() + " " + $2->getName() + "("+$4->getName()+");", "func_declaration");
            logout << $$->getName()<<"\n\n";
        }
    | type_specifier ID LPAREN RPAREN SEMICOLON 
        {
            logout << "Line "<<line_count<<": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n\n";
            $$ = new symbolInfo($1->getName() + " " + $2->getName() + "();", "func_declaration");
            logout << $$->getName()<<"\n\n";
        }
;
func_definition : type_specifier ID LPAREN parameter_list RPAREN 
    compound_statement 
        {
            logout << "Line "<<line_count<<": func_definition : type_specifier ID LPAREN parameter_list RPAREN\n\n";
        }
    | type_specifier ID LPAREN RPAREN compound_statement 
        {
            logout << "Line "<<line_count<<": func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n";
        }
;
parameter_list : parameter_list COMMA type_specifier ID 
        {
            logout << "Line "<<line_count<<": parameter_list : parameter_list COMMA type_specifier ID\n\n";
            $$ = new symbolInfo($1->getName() + "," + $3->getName() + " " + $4->getName(), "parameter_list");
            logout << $$->getName()<<"\n\n";
        }
    | parameter_list COMMA type_specifier 
        {
            logout << "Line "<<line_count<<": parameter_list : parameter_list COMMA type_specifier\n\n";
            $$ = new symbolInfo($1->getName() + "," + $3->getName(), "parameter_list");
            logout << $$->getName()<<"\n\n";
        }
    | type_specifier ID 
        {
            logout << "Line "<<line_count<<": parameter_list : type_specifier ID\n\n";
            $$ = new symbolInfo($1->getName() + " " + $2->getName(), "parameter_list");
            logout << $$->getName()<<"\n\n";
        }
    | type_specifier 
        {
            logout << "Line "<<line_count<<": parameter_list : type_specifier\n\n";
            $$ = $1;
            logout << $$->getName()<<"\n\n";
        }
;
compound_statement : LCURL statements RCURL 
        {
            logout << "Line "<<line_count<<": compound_statement : LCURL statements RCURL\n\n";
            $$ = new symbolInfo("{\n"+$2->getName()+"\n}", "compound_statement");
            logout << $$->getName()<<"\n\n";
        }
    | LCURL RCURL 
        {
            logout << "Line "<<line_count<<": compound_statement : LCURL RCURL\n\n";
            $$ = new symbolInfo("{\n}", "compound_statement");
            logout << $$->getName()<<"\n\n";
        }
;
var_declaration : type_specifier declaration_list SEMICOLON 
        {
            logout << "Line "<<line_count<<": var_declaration : type_specifier declaration_list SEMICOLON\n\n";
            $$ = new symbolInfo($1->getName() + " " + $2->getName() + ";", "var_declaration");
            logout << $$->getName()<<"\n\n";
        }
;
type_specifier : INT 
        {
            logout << "Line "<<line_count<<": type_specifier : INT\n\n";
            $$ = new symbolInfo("int", "int");
			logout << $$->getName()<<"\n\n";
        }
    | FLOAT 
        {
            logout << "Line "<<line_count<<": type_specifier : FLOAT\n\n";
            $$ = new symbolInfo("float", "float");
			logout << $$->getName()<<"\n\n";
        }
    | VOID 
        {
            logout << "Line "<<line_count<<": type_specifier : VOID\n\n";
            $$ = new symbolInfo("void", "void");
			logout << $$->getName()<<"\n\n";
        }
;
declaration_list : declaration_list COMMA ID 
        {
            logout << "Line "<<line_count<<": declaration_list : declaration_list COMMA ID\n\n";
            $$ = new symbolInfo($1->getName()+","+$3->getName(), "declaration_list");
            logout<<$$->getName()<<"\n\n";
        }
    | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD 
        {
            logout << "Line "<<line_count<<": declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n";
            $$ = new symbolInfo($1->getName() + "," + $3->getName() + "[" + $5->getName() + "]",	"declaration_list");
            logout<<$$->getName()<<"\n\n";
        }
    | ID 
        {
            logout << "Line "<<line_count<<": declaration_list : ID\n\n";
            $$ = $1;
            logout << $$->getName()<<"\n\n";
        }
    | ID LTHIRD CONST_INT RTHIRD 
        {
            logout << "Line "<<line_count<<": declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n";
            $$ = new symbolInfo($1->getName() + "[" + $3->getName() + "]",	"declaration_list");
            logout<<$$->getName()<<"\n\n";
        }
;
statements : statement 
        {
            logout << "Line "<<line_count<<": statements : statement\n\n";
            $$ = $1;
            logout << $$->getName()<<"\n\n";
        }
    | statements statement 
        {
            logout << "Line "<<line_count<<": statements : statements statement\n\n";
            $$ = new symbolInfo($1->getName() + "\n" + $2->getName(), "statements");
            logout << $$->getName()<<"\n\n";
        }
;
statement : var_declaration 
        {
            logout << "Line "<<line_count<<": statement : var_declaration\n\n";
            $$ = $1;
            logout << $$->getName()<<"\n\n";
        }
    | expression_statement 
        {
            logout << "Line "<<line_count<<": statement : expression_statement\n\n";
            $$ = $1;
            logout << $$->getName()<<"\n\n";
        }
    | compound_statement 
        {
            logout << "Line "<<line_count<<": statement : compound_statement\n\n";
        }
    | FOR LPAREN expression_statement expression_statement expression 
    RPAREN statement
        {
            logout << "Line "<<line_count<<": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n";
            $$ = new symbolInfo("for(" + $3->getName() + $4->getName() + $5->getName() + ")" + $7->getName(),	"statement");
            logout<<$$->getName();
        }
    | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE 
        {
            logout << "Line "<<line_count<<": statement : IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE\n\n";
            $$=new symbolInfo("if("+$3->getName()+")"+$5->getName(), "statement");
            logout<<$$->getName()<<"\n\n";
        }
    | IF LPAREN expression RPAREN statement ELSE statement 
        {
            logout << "Line "<<line_count<<": statement : IF LPAREN expression RPAREN statement ELSE statement\n\n";
            $$=new symbolInfo("if("+$3->getName()+")"+$5->getName()+"else "+$7->getName(), "statement");
            logout<<$$->getName()<<"\n\n";
        }
    | WHILE LPAREN expression RPAREN statement 
        {
            logout << "Line "<<line_count<<": statement : WHILE LPAREN expression RPAREN statement\n\n";
            $$ = new symbolInfo("while("+$3->getName()+")"+$5->getName(), "statement");
            logout<<$$->getName()<<"\n\n";
        }
    | PRINTLN LPAREN ID RPAREN SEMICOLON 
        {
            logout << "Line "<<line_count<<": statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n";
            $$ = new symbolInfo("printf("+$3->getName()+");", "statement");
            logout<<$$->getName()<<"\n\n";
        }
    | RETURN expression SEMICOLON 
        {
            logout << "Line "<<line_count<<": statement : RETURN expression SEMICOLON\n\n";
            $$ = new symbolInfo("return "+$2->getName()+";", "statement");
            logout<<$$->getName()<<"\n\n";
        }
;
expression_statement : SEMICOLON 
        {
            $$ = new symbolInfo(";", "SEMICOLON");
        }
    | expression SEMICOLON 
        {
            logout << "Line "<<line_count<<": expression_statement : expression SEMICOLON\n\n";
            $$ = new symbolInfo($1->getName() + ";", "expression_statement");
            logout<< $$->getName()<<"\n\n";
        }
;
variable : ID 
        {
            logout << "Line "<<line_count<<": variable : ID\n\n";
            $$ = $1;
            logout<< $$->getName()<<"\n\n";
        }
    | ID LTHIRD expression RTHIRD 
        {
            logout << "Line "<<line_count<<": variable : ID LTHIRD expression RTHIRD\n\n";
            $$ = new symbolInfo($1->getName()+"["+$3->getName()+"]", "variable");
            logout<< $$->getName()<<"\n\n";
        }
;
expression : logic_expression 
        {
            logout << "Line "<<line_count<<": expression : logic_expression\n\n";
            $$ = $1;
            logout << $$->getName()<<"\n\n";
        }
    | variable ASSIGNOP logic_expression 
        {
            logout << "Line "<<line_count<<": expression : variable ASSIGNOP logic_expression\n\n";

            if($1->getType()!=$3->getType()){
                error_count++;
                errorout<<"Type Mismatch";
            }
            if($1->getType()=="error"){
                error_count++;
                errorout<<"Type Mismatch";
            }

            $$ = new symbolInfo($1->getName() + "=" + $3->getName(), "expression");
            logout<<$$->getName()<<"\n\n";
        }
;
logic_expression : rel_expression 
        {
            logout << "Line "<<line_count<<": logic_expression : rel_expression\n\n";
            $$ = $1;
            logout << $$->getName()<<"\n\n";
        }
    | rel_expression LOGICOP rel_expression 
        {
            logout << "Line "<<line_count<<": logic_expression : rel_expression LOGICOP rel_expression\n\n";
            
            string type = "int";
            
            string lType = $1->getType();
            string rType = $3->getType();
            
            if ((lType != "int") || (rType != "int"))
            {
                error_count++;
                errorout<< "Both operand of " << $2->getName() << " should be int type\n\n";
                type = "error";
            }

            $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName(),	type);
            logout<<$$->getName()<<"\n\n";
        }
;
rel_expression : simple_expression 
        {
            logout << "Line "<<line_count<<": rel_expression : simple_expression\n\n";
            $$ = $1;
            logout << $$->getName()<<"\n\n";
        }
    | simple_expression RELOP simple_expression 
        {
            logout << "Line "<<line_count<<": rel_expression : simple_expression RELOP simple_expression\n\n";
            $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName(),	"int");
            logout << $$->getName()<<"\n\n";
        }
;
simple_expression : term 
        {
            logout << "Line "<<line_count<<": simple_expression : term\n\n";
            $$ = $1;
            logout << $$->getName()<<"\n\n";
        }
    | simple_expression ADDOP term 
        {
            logout << "Line "<<line_count<<": simple_expression : simple_expression ADDOP term \n\n";
            
            string type = "int";
            if (($1->getType() == "float") || ($3->getType() == "float"))
            {
                type = "float";
            }

            $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName(), type);
            logout << $$->getName()<<"\n\n";
        }
;
term : unary_expression 
        {
            logout << "Line "<<line_count<<": term : unary_expression\n\n";
            $$ = $1;
            logout << $$->getName()<<"\n\n";
        }
    | term MULOP unary_expression 
        {
            logout << "Line "<<line_count<<": term : term MULOP unary_expression\n\n";
            $$ = new symbolInfo($1->getName() + $2->getName()+ $3->getName(),	"term");
            logout << $$->getName()<<"\n\n";
        }
;
unary_expression : ADDOP unary_expression 
        {
            logout << "Line "<<line_count<<": unary_expression : ADDOP unary_expression\n\n";
            $$ = new symbolInfo($1->getName() + $2->getName(),	$2->getType());
            logout << $$->getName()<<"\n\n";
        }
    | NOT unary_expression 
        {
            logout << "Line "<<line_count<<": unary_expression : NOT unary_expression\n\n";
            $$ = new symbolInfo("!" + $2->getName(),  $2->getType());
            logout << $$->getName()<<"\n\n";
        }
    | factor 
        {
            logout << "Line "<<line_count<<": unary_expression : factor\n\n";
            $$ = $1;
            logout << $$->getName()<<"\n\n";
        }
;
factor : variable 
        {
            logout << "Line "<<line_count<<": factor : variable\n\n";
            $$ = $1;
            logout << $$->getName()<<"\n\n";
        }
    | ID LPAREN argument_list RPAREN 
        {
            logout << "Line "<<line_count<<": factor : ID LPAREN argument_list RPAREN\n\n";
            $$ = new symbolInfo($1->getName()+"(" + $3->getName() + ")",	$3->getType() );
            logout << $$->getName()<<"\n\n";
        }
    | LPAREN expression RPAREN 
        {
            logout << "Line "<<line_count<<": factor : LPAREN expression RPAREN\n\n";
            $$ = new symbolInfo("(" + $2->getName() + ")",	$2->getType() );
            logout << $$->getName()<<"\n\n";
        }
    | CONST_INT 
        {
            logout << "Line "<<line_count<<": factor : CONST_INT\n\n";
            $$ = yylval.symbolinfo;
            logout << $$->getName()<<"\n\n";
        }
    | CONST_FLOAT 
        {
            logout << "Line "<<line_count<<": factor : CONST_FLOAT\n\n";
            $$ = yylval.symbolinfo;
            logout << $$->getName()<<"\n\n";
        }
    | variable INCOP 
        {
            logout << "Line "<<line_count<<": factor : variable INCOP\n\n";
            $$ = new symbolInfo($1->getName() + "++",	$1->getType());
            logout << $$->getName()<<"\n\n";
        }
    | variable DECOP 
        {
            logout << "Line "<<line_count<<": factor : variable DECOP\n\n";
            $$ = new symbolInfo($1->getName() + "--",	$1->getType());
            logout << $$->getName()<<"\n\n";
        }
;
argument_list : arguments 
        {
            logout << "Line "<<line_count<<": argument_list : arguments\n\n";
            $$ = $1;
            logout << $$->getName()<<"\n\n";
        }
    | 
        {
            logout << "Line "<<line_count<<": argument_list : \n\n";
            $$ = new symbolInfo("","void");
            logout << $$->getName()<<"\n\n";
        }
;
arguments : arguments COMMA logic_expression 
        {
            logout << "Line "<<line_count<<": arguments : arguments COMMA logic_expression\n\n";
            string argNames = $1->getName() + "," + $3->getName();
            string argTypes = $1->getType() + "," + $3->getType();

            $$ = new symbolInfo(argNames, argTypes);
            logout << $$->getName()<<"\n\n";

        }
    | logic_expression 
        {
            logout << "Line "<<line_count<<": arguments : logic_expression\n\n";
            $$ = $1;
            logout << $$->getName()<<"\n\n";
        }
;
%%

main(int argc,char *argv[])
{

    if(argc!=2){
		cout << "Please provide input file name and try again\n";
		return 0;
	}
	
	FILE *infile=fopen(argv[1],"r");
	if(infile==NULL){
		cout << "Cannot open specified file\n";
		return 0;
	}
	
	
	yyin=infile;
	yyparse();
	//symboltable.printAllScopeTable(logout);
	logout << "Total lines: " << line_count-1 << endl;
    logout << "Total errors: " << error_count << endl;
	fclose(yyin);
	logout.close();
	errorout.close();
	
	
	return 0;
}