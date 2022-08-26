%{

#include<bits/stdc++.h>

#include <stdio.h>
#include <stdlib.h>
#include<sstream>




#include<iostream>
#include<fstream>
using namespace std ; 


int yyparse(void) ; 
int yylex(void) ; 

ofstream logout("1805080_log.txt",std::ofstream::out) ; 
ofstream errorout("1805080_error.txt",std::ofstream::out) ; 
ofstream asmout("1805080.asm",std::ofstream::out) ; 
ofstream optimizeout("1805080_optimize.asm",std::ofstream::out) ; 


#include "symbolTable.h"


extern int line_count ; 
extern int error_count ; 
int var_id=0 ; 
int var_id1=0 ; 
int label_=0 ; 

extern FILE *yyin ; 

symbolTable st(50) ; 


vector<pair<string,int>> global_list ; 
string func_param_list ; 

string global_name(string var){
    return var+to_string(var_id1++) ; 
}
void console_log(string s){
    cout << "\u001b[31m" << s << "\u001b[0m" << endl ; 
}

string newTemp(){
    string t = "t_"+to_string(var_id++) ; 
    global_list.push_back(make_pair(t,0)) ; 
    return t ; 
}

string newLabel(){
    return "Label_"+to_string(label_++) ; 
}    

vector<string> splitString(const string s, char delim) {
    vector<string> v ; 
    stringstream ss(s) ; 
    string item ; 
    while(getline(ss, item, delim)) {
        v.push_back(item) ; 
    }
    return v ; 
}

string getArrayName(const string str){
	stringstream ss(str) ; 
	string item ; 
	while(getline(ss, item, '['))
		return item ; 
}

int getArraySize(string str) {

    stringstream ss(str) ; 
    string token ; 

    while (getline(ss, token, '[')) { }
    stringstream ss2(token) ; 
    getline(ss2, token, ']') ; 

    return stoi(token) ; 
}

vector<pair<string,string>> getParameters(string line) {

    vector<pair<string,string>> paramList ; 
    vector<string> paramPair = splitString(line, ',') ; 
    vector<string> typeAndName ; 

    for (string currentParam: paramPair)
    {
        typeAndName = splitString(currentParam, ' ') ; 
        paramList.push_back(make_pair(typeAndName[1], typeAndName[0])) ; 
    }
    return paramList ; 
}


void yyerror(string s){
	logout << "Error at line " << line_count << ": Syntax Error\n" ; 
	errorout << "Error at line " << line_count << ": Syntax Error\n" ; 
	error_count++ ; 
}



void print_data_segment(){
    asmout<<"\n\n.DATA\n" ; 
    for(int i=0 ; i<global_list.size() ; i++){
        asmout<<"\t\t"<<global_list[i].first<<" dw "<<global_list[i].second ; 
        if(global_list[i].second!=0)asmout<<" DUP(0)" ; 
        asmout<<"\n" ; 
    }
    asmout<<"\n\n" ; 

}

void print_optimize_data_segment(){
    optimizeout<<"\n\n.DATA\n" ; 
    for(int i=0 ; i<global_list.size() ; i++){
        optimizeout<<"   "<<global_list[i].first<<" dw "<<global_list[i].second ; 
        if(global_list[i].second!=0)asmout<<" DUP(0)" ; 
        optimizeout<<"\n" ; 
    }
    optimizeout<<"\n\n" ; 

}

void print_code_segment(string code){
    asmout<<"\n\n.CODE\n\n" ; 
    asmout<<"\n"<<code<<"\n\n" ; 
}

void ltrim(std::string& s, char c) {

   if (s.empty())
      return;

   std::string::iterator p;
   for (p = s.begin(); p != s.end() && *++p == c;);

   if (*p != c)
      p--;

   s.erase(s.begin(), p);
}

void rtrim(std::string& s, char c) {

   if (s.empty())
      return;

   std::string::iterator p;
   for (p = s.end(); p != s.begin() && *--p == c;);

   if (*p != c)
      p++;

   s.erase(p, s.end());
}


string codeOptimization(string inputCode){
  string finalOutput="" ; 
  vector<string> lines ; 
  vector <string> token1, token2, token ; 

  // stringstream class check1
  stringstream check1(inputCode) ; 

  string intermediate ; 

  // Tokenizing w.r.t. space '\n'
  while(getline(check1, intermediate, '\n')) {lines.push_back(intermediate) ; }

  for(int i = 0 ;  i < lines.size() ;  i++){
      //cout << lines[i] << '\n' ; 
        stringstream check2(lines[i]) ; 

        string code; 
        getline(check2, code, ';');

        stringstream check3(code);

      
      while(getline(check3, intermediate, ' ')) {
        if(intermediate[intermediate.length()-1]==','){
            intermediate.replace(intermediate.length()-1,1,"") ; 
        }
        ltrim(intermediate,'\t');
        ltrim(intermediate,' ');
        rtrim(intermediate,' ');
        
        if(intermediate.size()>1){
            token.push_back(intermediate) ; 
            //cout<<intermediate.length()<<" int "<<intermediate<<"\n";
        }
      }
      if(token.size()==0){
        token.clear();
        continue;
      }

      if(token1.size()==0){
        token1 = token ; 
        token.clear() ; 
      }
      else if(token2.size()==0){
        token2 = token ; 
        token.clear() ; 
      }
      else{
        token1.clear() ; 
        token1 = token2 ; 
        token2.clear() ; 
        token2 = token ; 
        token.clear() ; 
      }

        // cout<<"first : "<<token1.size()<<" " ; 
        // for(int j=0 ; j<token1.size() ; j++){
        //     cout<<token1[j]<<" " ; 
        // }
        // cout<<endl ; 
        // cout<<"second : "<<token2.size()<<" "  ; 
        // for(int j=0 ; j<token2.size() ; j++){
        //     cout<<token2[j]<<" " ; 
        // }
        // cout<<endl ; 
        // cout<<endl ; 

      //optimization for mov
      if(token1.size()==token2.size() && token1.size()==3){
        // cout<<token1.size()<<endl ; 
        // for(int j=0 ; j<token2.size() ; j++){
        //   cout<<"first : "<<token1[j]<<" \tsecond line : "<<token2[j]<<"\n" ; 
        // }
        if(token1[0]=="\tMOV" && token2[0]=="\tMOV"){
          if(token1[2]==token2[1] && token1[1] == token2[2]){
            cout<<lines[i]<<" is redundant.\n" ; 
            lines[i]=" ; "+lines[i]+"    is removed for optimization" ; 
            //cout<<lines[i];
          }
        }
        
      }
      else if(token1.size()==token2.size() && token1.size()==2){
        //cout<<token1.size()<<endl ; 
        // for(int j=0 ; j<token2.size() ; j++){
        //   cout<<"first : "<<token1[j]<<" \tsecond line : "<<token2[j]<<"\n" ; 
        // }
        if(token1[0]=="PUSH" && token2[0]=="POP"){
          if(token1[1]==token2[1]){
            cout<<lines[i]<<" is redundant.\n" ; 
            lines[i]=" ; "+lines[i]+"    is removed for optimization" ; 
          }
        }
        
      }
      


      finalOutput += lines[i]+"\n" ; 
  }
  return finalOutput ; 
}

void print_optimize(string code){
    optimizeout<<"\n\n.CODE\n\n" ; 
    string optimize_code=codeOptimization(code) ; 
    optimizeout<<optimize_code<<endl<<endl ; 
}


void print_print_segment(){
    asmout<<"\n\n\nPRINT PROC\n" ; 
    asmout<<"\t ; bx is needed to be print\n" ; 

    asmout<<"\t ; saving ax,bx,cx,dx\n" ; 
    asmout<<"\tpush ax\n" ; 
    asmout<<"\tpush bx\n" ; 
    asmout<<"\tpush cx\n" ; 
    asmout<<"\tpush dx\n\n" ; 

    asmout<<"\tmov cx,0\n" ; 
                
    asmout<<"\tcmp bx,0\n" ; 
    asmout<<"\tJGE while_1\n" ; 
    asmout<<"\tneg bx\n\n" ; 
    asmout<<"\tmov ah,2\n" ; 
    asmout<<"\tmov dl,45\n" ; 
    asmout<<"\tint 21h\n" ; 
    
    asmout<<"\twhile_1:\n" ; 
    asmout<<"\t\tinc cx      ; used for printing loop number\n" ; 
    asmout<<"\t\tmov ax,bx   ;  ax = bx\n" ; 
    asmout<<"\t\tmov bx,10   ;  bx = 10\n" ; 
    asmout<<"\t\txor dx,dx   ;  dx = 0\n" ; 
    asmout<<"\t\tdiv bx      ;  ax = ax / bx (10)\n" ; 
    asmout<<"\t\tpush dx     ;  dx = ax % bx (10)\n" ; 
    asmout<<"\t\tmov bx,ax   ;  bx = ax\n" ; 
    asmout<<"\t\tcmp ax,0\n" ; 
    asmout<<"\tJNE while_1\n" ;  
            
            
    asmout<<"\t\tmov ah,2 \n" ;  
    asmout<<"\t\twhile_p:\n" ; 
    asmout<<"\t\tdec cx\n" ; 
    asmout<<"\t\tpop dx\n" ; 
    asmout<<"\t\tadd dx,'0'\n" ; 
    asmout<<"\t\tint 21h\n" ; 
    asmout<<"\t\tcmp cx,0\n" ; 
    asmout<<"\t\tJNE while_p\n" ; 

    asmout<<"\t ;  printing CR and LF\n" ; 
    asmout<<"\tmov ah, 2\n" ; 
    asmout<<"\tmov dl, 13\n" ; 
    asmout<<"\tint 21h\n" ; 
    asmout<<"\tmov dl, 10\n" ; 
    asmout<<"\tint 21h\n" ; 

    asmout<<"\n\tpop ax\n" ; 
    asmout<<"\tpop bx\n" ; 
    asmout<<"\tpop cx\n" ; 
    asmout<<"\tpop dx\n\n" ; 
    
    asmout<<"RET\n" ; 
    asmout<<"PRINT ENDP\n\n\n" ; 
}

void print_op_print_segment(){
    optimizeout<<"\n\n\nPRINT PROC\n" ; 
    optimizeout<<"\t ; bx is needed to be print\n" ; 

    optimizeout<<"\t ; saving ax,bx,cx,dx\n" ; 
    optimizeout<<"\tpush ax\n" ; 
    optimizeout<<"\tpush bx\n" ; 
    optimizeout<<"\tpush cx\n" ; 
    optimizeout<<"\tpush dx\n\n" ; 

    optimizeout<<"\tmov cx,0\n" ; 
                
    optimizeout<<"\tcmp bx,0\n" ; 
    optimizeout<<"\tJGE while_1\n" ; 
    optimizeout<<"\tneg bx\n\n" ; 
    optimizeout<<"\tmov ah,2\n" ; 
    optimizeout<<"\tmov dl,45\n" ; 
    optimizeout<<"\tint 21h\n" ; 
    
    optimizeout<<"\twhile_1:\n" ; 
    optimizeout<<"\t\tinc cx      ; used for printing loop number\n" ; 
    optimizeout<<"\t\tmov ax,bx   ;  ax = bx\n" ; 
    optimizeout<<"\t\tmov bx,10   ;  bx = 10\n" ; 
    optimizeout<<"\t\txor dx,dx   ;  dx = 0\n" ; 
    optimizeout<<"\t\tdiv bx      ;  ax = ax / bx (10)\n" ; 
    optimizeout<<"\t\tpush dx     ;  dx = ax % bx (10)\n" ; 
    optimizeout<<"\t\tmov bx,ax   ;  bx = ax\n" ; 
    optimizeout<<"\t\tcmp ax,0\n" ; 
    optimizeout<<"\tJNE while_1\n" ;  
            
            
    optimizeout<<"\t\tmov ah,2 \n" ;  
    optimizeout<<"\t\twhile_p:\n" ; 
    optimizeout<<"\t\tdec cx\n" ; 
    optimizeout<<"\t\tpop dx\n" ; 
    optimizeout<<"\t\tadd dx,'0'\n" ; 
    optimizeout<<"\t\tint 21h\n" ; 
    optimizeout<<"\t\tcmp cx,0\n" ; 
    optimizeout<<"\t\tJNE while_p\n" ; 

    optimizeout<<"\t ;  printing CR and LF\n" ; 
    optimizeout<<"\tmov ah, 2\n" ; 
    optimizeout<<"\tmov dl, 13\n" ; 
    optimizeout<<"\tint 21h\n" ; 
    optimizeout<<"\tmov dl, 10\n" ; 
    optimizeout<<"\tint 21h\n" ; 

    optimizeout<<"\n\tpop ax\n" ; 
    optimizeout<<"\tpop bx\n" ; 
    optimizeout<<"\tpop cx\n" ; 
    optimizeout<<"\tpop dx\n\n" ; 
    
    optimizeout<<"RET\n" ; 
    optimizeout<<"PRINT ENDP\n\n\n" ; 
}


void AsmGenerator(string code){
    asmout<<".MODEL SMALL\n" ; 
    asmout<<".STACK 400H\n" ; 

    print_data_segment() ; 

    print_code_segment(code) ; 

    print_print_segment() ; 
    
    asmout<<"END MAIN\n" ; 

}

void OptimizeGenerator(string code){
    optimizeout<<".MODEL SMALL\n" ; 
    optimizeout<<".STACK 400H\n" ; 

    print_optimize_data_segment() ; 

    print_optimize(code) ; 

    print_op_print_segment() ; 
    
    optimizeout<<"END MAIN\n" ; 
}






%}


%union {
	symbolInfo* symbolinfo ; 
}

%define parse.error verbose

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
            $$ = $1 ; 

            if(error_count == 0){
                string a="" ; 
                AsmGenerator($$->getAsmCode()) ; 
                OptimizeGenerator($$->getAsmCode()) ; 
            }

            logout<< "Line "<<line_count-1<<": start : program\n" ; 
            
            //logout << $$->getName()<<"\n\n" ; 
            
        }
 ; 
program : program unit
        {
            logout << "Line "<<line_count<<": program : program unit\n\n" ; 
            $$ = new symbolInfo($1->getName() + "\n" + $2->getName(), "program") ; 
            $$->setAsmCode($1->getAsmCode()+$2->getAsmCode()) ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | unit
        {
            logout << "Line "<<line_count<<": program : unit\n\n" ; 
            $$ = $1 ; 
            logout << $$->getName()<<"\n\n" ; 
        }
 ; 
unit : var_declaration
        {
            logout << "Line "<<line_count<<": unit : var_declaration\n\n" ; 
            $$ = $1 ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | func_declaration
        {
            logout << "Line "<<line_count<<": unit : func_declaration\n\n" ; 
            $$ = $1 ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | func_definition
        {
            logout << "Line "<<line_count<<": unit : func_definition\n\n" ; 
            $$ = $1 ; 
            logout << $$->getName()<<"\n\n" ; 
        }
 ; 
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON 
        {
            

            symbolInfo* currFunc = st.LookUp($2->getName()) ; 

            if(currFunc != nullptr){
                //multiple declaration of function
                logout << "Error at line " << line_count << ": Multiple declaration of " << $2->getName() << "\n\n" ; 
				errorout << "Error at line " << line_count << ": Multiple declaration of " << $2->getName() << "\n\n" ; 
				error_count++ ; 
            }
            else{
                st.Insert($2->getName(), $1->getName()) ; 
                symbolInfo* temp=st.LookUp($2->getName()) ; 
                temp->setAsFunction(getParameters($4->getName())) ; 
                temp->setDefined(false) ; 
            }

            logout << "Line "<<line_count<<": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n" ; 
            $$ = new symbolInfo($1->getName() + " " + $2->getName() + "("+$4->getName()+") ; ", "func_declaration") ; 
            logout << $$->getName()<<"\n\n" ; 


        }
    | type_specifier ID LPAREN RPAREN SEMICOLON 
        {
            symbolInfo* currFunc = st.LookUp($2->getName()) ; 

            if (currFunc != nullptr)	//	 Already declared
            {
                if(currFunc->isFunction()){
                    error_count++ ; 
                    errorout << "Error at line " << line_count << ": Multiple declaration of function '" << $2->getName() << "'\n\n" ; 
                }
                else{
                    vector<pair<string,string>> paramList ; 

                    st.Insert($2->getName(), $1->getName()) ; 
                    symbolInfo* temp=st.LookUp($2->getName()) ; 
                    temp->setAsFunction(paramList) ; 
                    temp->setDefined(false) ; 
                }
            }
            else		//	Is not declared yet
            {
                vector<pair<string,string>> paramList ; 

                st.Insert($2->getName(), $1->getName()) ; 
                symbolInfo* temp=st.LookUp($2->getName()) ; 
                temp->setAsFunction(paramList) ; 
                temp->setDefined(false) ; 

            }

            logout << "Line "<<line_count<<": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n\n" ; 
            $$ = new symbolInfo($1->getName() + " " + $2->getName() + "() ; ", "func_declaration") ; 
            logout << $$->getName()<<"\n\n" ; 
        }
 ; 
func_definition : type_specifier ID LPAREN parameter_list RPAREN
            {
                symbolInfo* currFunc = st.LookUp($2->getName()) ; 

                vector<pair<string,string>> paramList = getParameters($4->getName()) ; 

                if(currFunc != nullptr){
                    if(currFunc->isFunction()){
                        if(currFunc->isDefined()){
                            error_count++ ; 
                            errorout << "Error at line " << line_count << ": Redefination of function '" << $2->getName() << "'\n\n" ; 
                        }
                        else{

                            int declaredSize = currFunc->getParamList().size() ; 
                            int  definedSize = paramList.size() ; 

                            string declaredType = currFunc->getType() ; 
                            string funcType = $1->getType() ; 

                            if (declaredSize != definedSize)	//	ERROR - ParamList size doesnt match
                            {
                                error_count++ ; 
                                errorout << "Error at line " << line_count << ": Number of parameters isn't consistent with declaration" <<"\n\n" ; 
                            }
                            else if (declaredType != funcType)		//	ERROR - Return type doesn't match
                            {
                                error_count++ ; 
                                errorout << "Error at line " << line_count << ": Function return type doesn't match with declaration" <<"\n\n" ; 
                            }

                            vector<pair<string,string>> declaredParamList = currFunc->getParamList() ; 

                            if ((declaredSize != 0) && (declaredSize == definedSize))
                            {    
                                for (int i=0 ;  i < declaredSize ;  i++)
                                {
                                    string declaredType = declaredParamList[i].first ; 
                                    string currentType = paramList[i].first ; 

                                    if (declaredType != currentType)	//	ERROR - Type mismatch in function parameter
                                    {
                                        error_count++ ; 
                                        errorout << "Error at line " << line_count << ": Type mismatch of function parameter '"<< paramList[i].second<<"'\n\n" ; 
                                    }
                                }
                            }

                            symbolInfo* curr = st.LookUp($2->getName()) ; 
                            curr->setAsFunction(paramList) ; 
                            curr->setDefined(true) ; 


                            st.Enter() ; 

                            bool inserted = false ; 
                            func_param_list="" ; 
                            func_param_list +="\t ; poping arguments values & saving them in variable\n" ; 
                            for (int i=0 ;  i < paramList.size() ;  i++)
                            {
                                inserted = st.Insert(paramList[i].first, paramList[i].second) ; 
                                string g_name = global_name(paramList[i].first) ; 
						        global_list.push_back(make_pair(g_name, 0)) ; 
                                

                                if (!inserted)
                                {
                                    error_count++ ; 
                                    errorout << "Error at line " << line_count << ": Multiple declaration of variable '"<< paramList[i].second <<"' in parameter\n\n" ; 
                                }
                                else{
                                    symbolInfo *t=st.LookUp(paramList[i].first) ; 
                                    //console_log(paramList[i].first) ; 
                                    //cout<<"\n\n\n\n\n"<<g_name<<"\n\n\n\n\n\n\n" ; 
                                    t->setAsmVar(g_name) ; 
                                    func_param_list+="\pPOP "+g_name+"\n" ; 
                                }
                            }
                        }
                    }
                    else{
                        st.Enter() ; 
                        error_count++ ; 
                        errorout << "Error at line " << line_count << ": Identifier '"<< currFunc->getName() <<"' is not a function.\n\n" ; 
                    }
                }//function is not declared
                else{
                    st.Insert($2->getName(),$1->getType()) ; 
                    symbolInfo* curr = st.LookUp($2->getName()) ; 
                    curr->setAsFunction(paramList) ; 
                    curr->setDefined(true) ; 
                    st.Enter() ; 

                    bool inserted = false ; 
                    func_param_list="" ; 
                    func_param_list +="\t ; poping arguments values & saving them in variable\n" ; 

                    for (int i=0 ;  i < paramList.size() ;  i++)
                    {

                        string g_name = global_name(paramList[i].first) ; 
						global_list.push_back(make_pair(g_name, 0)) ; 
                        inserted = st.Insert(paramList[i].first, paramList[i].second) ; 
                        
                        if (!inserted)
                        {
                            error_count++ ; 
                            errorout << "Error at line " << line_count << ": Multiple declaration of variable '"<< paramList[i].second <<"' in parameter\n\n" ; 
                        }
                        else{
                            symbolInfo* t = st.LookUp(paramList[i].first) ; 
                            t->setAsmVar(g_name) ; 
                            func_param_list+="\tPOP "+g_name+"\n" ; 
                            //console_log(g_name) ; 
                            //console_log(paramList[i].first) ; 
                            //cout<<"\n\n\n\n\n"<<paramList[i].first<<" "<<g_name<<"\n\n\n\n" ; 
                        }
                    }
                }
            }
        compound_statement 
            {
                logout << "Line "<<line_count<<": func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n" ; 
                $$ = new symbolInfo($1->getName() + " " + $2->getName() + "(" + $4->getName() + ")" + $7->getName() + "\n", "func_definition") ; 
                logout << $$->getName()<<"\n\n" ; 

                string code = "" ; 
					
                if ($2->getName() == "main") {
                    code += "MAIN PROC\n" ; 
                    code += "\tMOV AX , @DATA\n" ; 
                    code += "\tMOV DS , AX\n\n\n" ; 

                    code += $7->getAsmCode() ; 

                    code += "\n\n\tMOV AX , 4CH\n" ; 
                    code += "\tINT 21H\n" ; 
                    code += "MAIN ENDP\n" ; 
                }
                else {
                    code += $2->getName() + " PROC\n" ; 

                    code += "\tPOP BP\t\t\t ;  storing the return pointer in BP\n" ; 
                    code += func_param_list ; 
                    code += "\tPUSH BP\t\t\t ;  retrieving the return pointer for nested function call\n" ; 

                    code += $7->getAsmCode() ; 
                    code += "\tPUSH BP\t\t\t ;  retrieving the return pointer\n" ; 
                    
                    code += "\tRET\n" ; 

                    code += $2->getName() + " ENDP\n\n" ; 
                }
                $$->setAsmCode(code) ; 
            }
    | type_specifier ID LPAREN RPAREN 
            {
                symbolInfo* currFunc = st.LookUp($2->getName()) ; 
            
                if (currFunc != nullptr) // Function is declared
                {
                    if (currFunc->isDefined()) // Declared and Defined
                    {
                        error_count++ ; 
                        errorout << "Error at line " << line_count << ": Re-definition of function '"<< $2->getName() <<"'\n\n" ; 
                    }
                    else	// Declared, but not defined
                    {

                        vector<pair<string,string>> declaredParam = currFunc->getParamList() ; 

                        if (declaredParam.size() != 0)	//	ERROR - ParamList size doesnt match
                        {
                            error_count++ ; 
                            errorout << "Error at line " << line_count << ": Number of parameters isn't consistent with declaration\n\n" ; 
                        }
                        else if (currFunc->getType() != $1->getName())		
                        {
                            error_count++ ; 
                            errorout << "Error at line " << line_count << ": Function return type doesn't match with declaration\n\n" ; 
                        }
                        else{
                            st.Remove($2->getName()) ; 

                            vector<pair<string,string>> paramList ; 
                            st.Insert($2->getName(), $1->getName()) ; 
                            symbolInfo* temp=st.LookUp($2->getName()) ; 

                            temp->setAsFunction(paramList) ; 
                            temp->setDefined(true) ; 
                        }
                    }
                }
                else	// The Function isn't even declared.
                {
                    
                    vector<pair<string,string>> paramList ; 
                    st.Insert($2->getName(), $1->getName()) ; 
                    symbolInfo* temp=st.LookUp($2->getName()) ; 

                    temp->setAsFunction(paramList) ; 
                    temp->setDefined(true) ; 
                    
                }
                st.Enter() ; 
            }
        compound_statement 
            {
                string code = "" ; 
					
                if ($2->getName() == "main") {
                    code += "MAIN PROC\n" ; 
                    code += "\tMOV AX , @DATA\n" ; 
                    code += "\tMOV DS , AX\n\n\n" ; 
                    code+="\tMOV AX , BX\n" ; 
                    code+="\tMOV BX , AX\n" ; 

                    code += $6->getAsmCode() ; 

                    

                    code += "\n\n\tMOV AX , 4CH\n" ; 
                    code += "\tINT 21H\n" ; 
                    code += "MAIN ENDP\n" ; 
                }
                else {
                    code += $2->getName() + " PROC\n" ; 
                    
                    code += "\tPOP BP		 ;  storing the return pointer in BP\n" ; 
                    
                    code += $6->getAsmCode() ; 
                    //if($6->getAsmVar()!=""){code += "\tPUSH "+$6->getAsmVar()+"\n" ; }
                    //else code += "\tPUSH AX\n" ; 
                    code += "\tPUSH BP		 ;  retrieving the return pointer\n" ; 
                    code += "\tRET\n" ; 

                    code += $2->getName() + " ENDP\n\n" ; 
                }


                //logout << "Line "<<line_count<<": func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n" ; 
                $$ = new symbolInfo($1->getName() + " " + $2->getName() + "()" + $6->getName() + "\n", "func_definition") ; 
                $$->setAsmCode(code) ; 
                //logout << $$->getName()<<"\n\n" ; 
            }
 ; 
parameter_list : parameter_list COMMA type_specifier ID 
        {
            logout << "Line "<<line_count<<": parameter_list : parameter_list COMMA type_specifier ID\n\n" ; 
            $$ = new symbolInfo($1->getName() + "," + $3->getName() + " " + $4->getName(), "parameter_list") ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | parameter_list COMMA type_specifier 
        {
            logout << "Line "<<line_count<<": parameter_list : parameter_list COMMA type_specifier\n\n" ; 
            $$ = new symbolInfo($1->getName() + "," + $3->getName(), "parameter_list") ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | type_specifier ID 
        {
            logout << "Line "<<line_count<<": parameter_list : type_specifier ID\n\n" ; 
            $$ = new symbolInfo($1->getName() + " " + $2->getName(), "parameter_list") ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | type_specifier 
        {
            logout << "Line "<<line_count<<": parameter_list : type_specifier\n\n" ; 
            $$ = $1 ; 
            logout << $$->getName()<<"\n\n" ; 
        }
 ; 
compound_statement : LCURL statements RCURL 
        {
            logout << "Line "<<line_count<<": compound_statement : LCURL statements RCURL\n\n" ; 
            $$ = new symbolInfo("{\n"+$2->getName()+"\n}", "compound_statement") ; 
            $$->setAsmCode($2->getAsmCode()) ; 
            logout << $$->getName()<<"\n\n" ; 
            st.printAll(logout) ; 
            st.Exit() ; 
        }
    | LCURL RCURL 
        {
            logout << "Line "<<line_count<<": compound_statement : LCURL RCURL\n\n" ; 
            $$ = new symbolInfo("{\n}", "compound_statement") ; 
            logout << $$->getName()<<"\n\n" ; 
        }
 ; 
var_declaration : type_specifier declaration_list SEMICOLON 
        {
            logout << "Line "<<line_count<<": var_declaration : type_specifier declaration_list SEMICOLON\n\n" ; 

            if($1->getType()=="void"){
                error_count++ ; 
                errorout << "Error at line " << line_count << ": Variable type can't be void" <<"\n\n" ; 
            }
            else{
                vector<string> varList = splitString($2->getName(),',') ; 
            
                for (string var : varList){

                    string type = $1->getType() ; 
                    if ((var.find("[") != string::npos) || (var.find("]") != string::npos)) {
						string arrName = getArrayName(var) ; 
                        int arrSize = getArraySize(var) ; 
                        
                        if(!st.Insert(arrName,type)){
                            error_count++ ; 
                            errorout << "Error at line " << line_count << ": Multiple declaration of variable '" << arrName << "'\n\n" ; 
                        }
                        else{
                            symbolInfo* temp = st.LookUp(arrName) ; 
                            temp->setAsArray($1->getType(),arrName,arrSize) ; 
                            //errorout<<temp->getType()<<"type variable declared"<<endl ; 
                            string name = global_name(arrName) ; 
							global_list.push_back( make_pair(name,arrSize)) ; 
                            temp->setAsmVar(name) ; 
                        }
                    }
					else {
                        if(!st.Insert(var,type)){
                            error_count++ ; 
                            errorout << "Error at line " << line_count << ": Multiple declaration of variable '" << var << "'\n\n" ; 
                        }
                        else{
                            symbolInfo* temp = st.LookUp(var) ; 
                            //cout<<temp->getName()<<endl ; 
                            string g_name = global_name(var) ; 
							global_list.push_back( make_pair(g_name,0)) ; 
                            //console_log(temp->getName()) ; 
                            
                            //cout << "asdadasdasdasdasd" << endl ; 
                            //console_log(g_name) ; 
                            //console_log(temp->getName()) ; 
                            temp->setAsmVar(g_name) ; 
                            //cout << temp->getName() << endl ; 
                            //cout<<temp->getAsmVar()<<endl ; 
                        }
					}
				}
            }
            $$ = new symbolInfo($1->getName() + " " + $2->getName() + " ; ", "var_declaration") ; 
            logout << $$->getName()<<"\n\n" ; 
        }
 ; 
type_specifier : INT 
        {
            logout << "Line "<<line_count<<": type_specifier : INT\n\n" ; 
            $$ = new symbolInfo("int", "int") ; 
			logout << $$->getName()<<"\n\n" ; 
        }
    | FLOAT 
        {
            logout << "Line "<<line_count<<": type_specifier : FLOAT\n\n" ; 
            $$ = new symbolInfo("float", "float") ; 
			logout << $$->getName()<<"\n\n" ; 
        }
    | VOID 
        {
            logout << "Line "<<line_count<<": type_specifier : VOID\n\n" ; 
            $$ = new symbolInfo("void", "void") ; 
			logout << $$->getName()<<"\n\n" ; 
        }
 ; 
declaration_list : declaration_list COMMA ID 
        {
            logout << "Line "<<line_count<<": declaration_list : declaration_list COMMA ID\n\n" ; 
            $$ = new symbolInfo($1->getName()+","+$3->getName(), "declaration_list") ; 
            logout<<$$->getName()<<"\n\n" ; 
        }
    | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD 
        {
            logout << "Line "<<line_count<<": declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n" ; 
            $$ = new symbolInfo($1->getName() + "," + $3->getName() + "[" + $5->getName() + "]",	"declaration_list") ; 
            logout<<$$->getName()<<"\n\n" ; 
        }
    | ID 
        {
            logout << "Line "<<line_count<<": declaration_list : ID\n\n" ; 
            $$ = $1 ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | ID LTHIRD CONST_INT RTHIRD 
        {
            logout << "Line "<<line_count<<": declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n" ; 
            $$ = new symbolInfo($1->getName() + "[" + $3->getName() + "]",	"declaration_list") ; 
            logout<<$$->getName()<<"\n\n" ; 
        }
 ; 
statements : statement 
        {
            logout << "Line "<<line_count<<": statements : statement\n\n" ; 
            $$ = $1 ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | statements statement 
        {
            logout << "Line "<<line_count<<": statements : statements statement\n\n" ; 
            $$ = new symbolInfo($1->getName() + "\n" + $2->getName(), "statements") ; 
            $$->setAsmCode($1->getAsmCode()+$2->getAsmCode()) ; 
            logout << $$->getName()<<"\n\n" ; 
        }
 ; 
statement : var_declaration 
        {
            logout << "Line "<<line_count<<": statement : var_declaration\n\n" ; 
            $$ = $1 ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | expression_statement 
        {
            logout << "Line "<<line_count<<": statement : expression_statement\n\n" ; 
            $$ = $1 ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | {st.Enter() ; } compound_statement 
        {
            logout << "Line "<<line_count<<": statement : compound_statement\n\n" ; 
            $$=$2 ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | FOR LPAREN expression_statement expression_statement expression 
    RPAREN statement
        {
            logout << "Line "<<line_count<<": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n" ; 
            $$ = new symbolInfo("for(" + $3->getName() + $4->getName() + $5->getName() + ")" + $7->getName(),	"statement") ; 
            logout<<$$->getName() ; 

            string code="" ; 
            code += "\t ; statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n" ; 

            code += "\t ; executing first expression\n" ; 
            code += $3->getAsmCode() ; 
            
            if ($3->getName() != " ; " && $4->getName() != " ; ")
            {
                string label_1 = newLabel() ; 
                string label_2 = newLabel() ; 
                
                code+="\t ; Lable for FOR loop----loop starts here\n" ; 
                code += "\t"+label_1 + ":\n" ; 
                code+="\t ; executing conditional part\n" ; 
                code += $4->getAsmCode() ; 
                code += "\tMOV AX , " + $4->getAsmVar() + "\n\n" ; 
                code += "\t ; checking condition\n" ; 
                code += "\tCMP AX , 0\n" ; 
                code += "\tJE " + label_2 + "\t\t\t ; loop ends\n" ; 

                code+="\t ; executing statement part\n" ; 
                code += $7->getAsmCode() ; 

                code+="\t ; executing inc/dec part\n" ; 
                code += $5->getAsmCode() ; 

                code+="\t ; executing conditional part\n" ; 
                code += "\tJMP " + label_1 + "\n\n" ; 
                code+="\t ; label for loop ends---loop finishes here\n" ; 
                code += "\t"+label_2 + ":\n\n" ; 
            }

            $$->setAsmCode(code) ; 



        }
    | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE 
        {
            logout << "Line "<<line_count<<": statement : IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE\n\n" ; 
            $$=new symbolInfo("if("+$3->getName()+")"+$5->getName(), "statement") ; 
            logout<<$$->getName()<<"\n\n" ; 

            string code="" ; 

            code+="\t ; statement : IF LPAREN expression RPAREN statement\n\n" ; 

            code+="\t ; executing expression part\n" ; 
            code += $3->getAsmCode() ; 
            string label0 = newLabel() ; 

            code+="\t ; comparing values\n" ; 
            code+="\t CMP "+$3->getAsmVar()+",0\n" ; 
            code+="\t JE "+label0+"\n\n" ; 
            code+="\t ; statement of if\n" ; 
            code+=$5->getAsmCode()+"\n" ; 
            code+="\t"+label0+":\n" ; 
            code+="\t ; if executed\n\n" ; 

            $$->setAsmCode(code) ; 

        }
    | IF LPAREN expression RPAREN statement ELSE statement 
        {
            logout << "Line "<<line_count<<": statement : IF LPAREN expression RPAREN statement ELSE statement\n\n" ; 
            $$=new symbolInfo("if("+$3->getName()+")"+$5->getName()+"else "+$7->getName(), "statement") ; 
            logout<<$$->getName()<<"\n\n" ; 
            string code="" ; 

            code+="\t ; statement : IF LPAREN expression RPAREN statement ELSE statement\n\n" ; 

            code+="\t ; executing expression part\n" ; 
            code+=$3->getAsmCode() ; 
            string label0=newLabel() ; 
            string label1=newLabel() ; 

            code+="\t ; comparing values\n" ; 
            code+="\t CMP "+$3->getAsmVar()+",1\n" ; 
            code+="\t JNE "+label0+"\n\n" ; 
            code+="\t ; statement of if\n" ; 
            code+=$5->getAsmCode() ; 
            code+="\tJMP "+label1+":\n\n" ; 
            code+="\t ; statement of else\n" ; 
            code+="\t"+label0+":\n" ; 
            code+=$7->getAsmCode()+"\n" ; 
            code+="\t"+label1+":\n" ; 
            code+="\t ; if else executed\n\n" ; 

            $$->setAsmCode(code) ; 

        }
    | WHILE LPAREN expression RPAREN statement 
        {
            logout << "Line "<<line_count<<": statement : WHILE LPAREN expression RPAREN statement\n\n" ; 
            $$ = new symbolInfo("while("+$3->getName()+")"+$5->getName(), "statement") ; 
            logout<<$$->getName()<<"\n\n" ; 

            string code = "" ; 
            code+= "\t ; statement : WHILE LPAREN expression RPAREN statement\n" ; 

            string label_1 = newLabel() ; 
            string label_2 = newLabel() ; 

            code += "\t ; while loop starts here\n" ; 
            code += "\t ; label for loop\n" ; 
            code += "\t"+label_1 + ":\n\n" ; 
            code += "\t ; conditional segments of loop\n" ; 
            code += "\t ; executing conditional parts\n" ; 
            code += $3->getAsmCode() ; 
            code += "\t ; checking condition\n" ; 
            code += "\tMOV AX , " + $3->getAsmVar() + "\n" ; 
            code += "\tCMP AX , 0\n" ; 
            code += "\tJE " + label_2 + "\n\n" ; 

            code += "\t ; statement part of loop\n" ; 
            code += $5->getAsmCode() ; 
            code += "\tJMP " + label_1 + "\n" ; 
            code += label_2 + ":\n" ; 

            $$->setAsmCode(code) ; 

        }
    | PRINTLN LPAREN ID RPAREN SEMICOLON 
        {
            logout << "Line "<<line_count<<": statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n" ; 

            symbolInfo* currId = st.LookUp($3->getName()) ; 

            if(currId == nullptr){
                error_count++ ; 
                errorout << "Error at line " << line_count << ": Variable '" << $3->getName() << "' Undeclared\n\n" ; 
            }
            else{
                if(currId->isVariable()==false){
                    error_count++ ; 
                    errorout << "Error at line " << line_count << ": Function can't be inside of printf" << "\n\n" ; 
                }
            }
            
            
            $$ = new symbolInfo("printf("+$3->getName()+") ; ", "statement") ; 
            //$3->print() ; 
            string code = "" ; 
            code+="\t ; "+$$->getName()+"\n" ; 
            code+="\tPUSH BX\t\t\t ; BX will be used in printing\n" ; 
            code+="\tMOV BX , "+currId->getAsmVar()+"\n" ; 
            code+="\tCALL PRINT\n" ; 
            code+="\tPOP BX ; \n\n" ; 
            $$->setAsmCode(code) ; 

            logout<<$$->getName()<<"\n\n" ; 
        }
    | RETURN expression SEMICOLON 
        {
            logout << "Line "<<line_count<<": statement : RETURN expression SEMICOLON\n\n" ; 

            if($2->getName() == "void"){
                error_count++ ; 
                errorout << "Error at line " << line_count << ":Function type void can't have a return statement"<< "\n\n" ; 
            }

            string code="" ; 
            
            $$ = new symbolInfo("return "+$2->getName()+" ; ", "statement") ; 
            logout<<$$->getName()<<"\n\n" ; 

            code+="\t ; Retrning values\n" ; 
            code+="\t ; "+$$->getName()+"\n\n" ; 
            code+="\t ; Executing expression\n" ; 
            code+=$2->getAsmCode() ; 
            code+="\t ; Getting return pointer\n" ; 
            code+="\tPOP BP\n" ; 
            code+="\t ; pusing values in stack\n" ; 
            code+="\tPUSH "+$2->getAsmVar()+"\n" ; 

            $$->setAsmCode(code) ; 
            $$->setAsmVar($2->getAsmVar()) ; 
        }
 ; 
expression_statement : SEMICOLON 
        {
            $$ = new symbolInfo(" ; ", "SEMICOLON") ; 
        }
    | expression SEMICOLON 
        {
            logout << "Line "<<line_count<<": expression_statement : expression SEMICOLON\n\n" ; 
            $$ = new symbolInfo($1->getName() + " ; ", "expression_statement") ; 
            $$->setAsmCode($1->getAsmCode()) ; 
            $$->setAsmVar($1->getAsmVar()) ; 
            logout<< $$->getName()<<"\n\n" ; 
        }
 ; 
variable : ID 
        {
            logout << "Line "<<line_count<<": variable : ID\n\n" ; 
            symbolInfo *currId=st.LookUp($1->getName()) ; 

            if(currId == nullptr){
                error_count++ ; 
                errorout << "Error at line " << line_count << ": Undeclared variable '" << $1->getName() << "' referred\n\n" ; 
                $$ = new symbolInfo($1->getName(),"error") ; 
            }
            else{
                if(currId->isArray()){
                    $$ = new symbolInfo() ; 
                    $$->setAsArray("error",currId->getName(), currId->getSize()) ; 
                }
                else
                {
                    $$ = new symbolInfo(currId->getName(), currId->getType()) ; 
                    $$->setAsmVar(currId->getAsmVar()) ; 
                }
            }

            logout<< $$->getName()<<"\n\n" ; 
        }
    | ID LTHIRD expression RTHIRD 
        {
            logout << "Line "<<line_count<<": variable : ID LTHIRD expression RTHIRD\n\n" ; 

            symbolInfo *currId=st.LookUp($1->getName()) ; 

            string type ; 

            string code__="" ; 
            string temp=newTemp() ; 
            

            if(currId == nullptr){
                error_count++ ; 
                errorout << "Error at line " << line_count << ": Undeclared variable '" << $1->getName() << "' referred\n\n" ; 
                type="error" ; 
            }
            else{
                if(currId->isArray()){
                    if($3->getType() != "int"){
                        error_count++ ; 
                        errorout << "Error at line " << line_count << ": Non-integer array index of '" << $1->getName() << "'\n\n" ; 
                    }
                    type=currId->getType() ; 
                    

                    
                }
                else{
                    error_count++ ; 
                    errorout << "Error at line " << line_count << ": Type Mismatch. Variable '" << $1->getName() << "' is not an array\n\n" ; 
                    type="error" ; 
                }
            }

            string code="" ; 

           

            code+="\t ; variable : ID LTHIRD expression RTHIRD\n" ; 
            $$ = new symbolInfo($1->getName()+"["+$3->getName()+"]", type) ; 
            code+="\t ; "+$$->getName()+"\n" ; 

            code +="\t ; expression code\n" ; 
            code += $3->getAsmCode() ; 
            code += "\tLEA SI, " + currId->getAsmVar() + "\n" ; 
            code += "\tADD SI, "+$3->getAsmVar()+"\n" ; 
            code += "\tADD SI, "+$3->getAsmVar()+"\n" ; 
            temp = "[SI]" ; 


            
            logout<< $$->getName()<<"\n\n" ; 

            $$->setAsmCode(code) ; 
            $$->setAsmVar(temp) ; 
            
        }
 ; 
expression : logic_expression 
        {
            logout << "Line "<<line_count<<": expression : logic_expression\n\n" ; 
            $$ = $1 ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | variable ASSIGNOP logic_expression 
        {
            logout << "Line "<<line_count<<": expression : variable ASSIGNOP logic_expression\n\n" ; 

            if($1->getType()=="float" && $3->getType()=="int"){

            }
            else if($1->getType()!=$3->getType()){
                error_count++ ; 
                errorout << "Error at line " << line_count << ": Warning : Type Mismatch of variable (!=) "<< $1->getName() << "\n\n" ; 
                //errorout<<"left "<<$1->getType()<<"right"<<$3->getType()<<endl ; 
            }
            if($1->getType()=="error"){
                error_count++ ; 
                errorout << "Error at line " << line_count << ": Warning : Type Mismatch of variable (error) "<< $1->getName() << "\n\n" ; 
            }

            $$ = new symbolInfo($1->getName() + "=" + $3->getName(), "expression") ; 

            string code = "" ; 
            code+=$1->getAsmCode()+$3->getAsmCode() ; 

            code += "\t ; "+$$->getName()+"\n" ; 
            code += "\tMOV AX , "+$3->getAsmVar()+"\n" ; 
            code += "\tMOV "+$1->getAsmVar()+" , AX\n\n" ; 
            $$->setAsmCode(code) ; 
            $$->setAsmVar($1->getAsmVar()) ; 


            logout<<$$->getName()<<"\n\n" ; 
        }
 ; 
logic_expression : rel_expression 
        {
            logout << "Line "<<line_count<<": logic_expression : rel_expression\n\n" ; 
            $$ = $1 ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | rel_expression LOGICOP rel_expression 
        {
            logout << "Line "<<line_count<<": logic_expression : rel_expression LOGICOP rel_expression\n\n" ; 
            
            string type = "int" ; 
            
            string lType = $1->getType() ; 
            string rType = $3->getType() ; 
            
            if ((lType != "int") || (rType != "int"))
            {
                error_count++ ; 
                errorout << "Error at line " << line_count << ": Both operand of " << $2->getName() << " should be int type\n\n" ; 
                type = "error" ; 
            }


            $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName(),	type) ; 

            string code="" ; 
            string temp=newTemp() ; 
            string label0=newLabel() ; 
            string label1=newLabel() ; 

            code+=$1->getAsmCode()+$3->getAsmCode() ; 

            
            code+=" ; logic_expression : rel_expression LOGICOP rel_expression\n" ; 
            code+="\t ; "+$$->getName()+"\n" ; 

            int cmp_var=1 ; 
            if($2->getName()=="&&")cmp_var=0 ; 


            
            code += "\tCMP " + $1->getAsmVar()+","+to_string(cmp_var)+"\n" ; 
            code += "\tJE " + label0 + "\n" ; 
            code += "\tCMP " + $3->getAsmVar()+","+to_string(cmp_var)+"\n" ; 
            code += "\tJE " + label0 + "\n" ; 
            code += "\tMOV " + temp + " , 1\n" ; 
            code += "\tJMP " + label1 + "\n\n" ; 
            code += "\t"+label0 + ":\n" ; 
            code += "\tMOV " + temp + " , 0\n" ; 
            code += "\t"+label1 + ":\n" ; 
            code += "\t ; Rel_expression logicop executed \n\n" ; 


            $$->setAsmCode(code) ; 
            $$->setAsmVar(temp) ; 

            
            logout<<$$->getName()<<"\n\n" ; 
        }
 ; 
rel_expression : simple_expression 
        {
            logout << "Line "<<line_count<<": rel_expression : simple_expression\n\n" ; 
            $$ = $1 ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | simple_expression RELOP simple_expression 
        {
            logout << "Line "<<line_count<<": rel_expression : simple_expression RELOP simple_expression\n\n" ; 
            $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName(),	"int") ; 
            logout << $$->getName()<<"\n\n" ; 

            string code="" ; 
            string temp=newTemp() ; 
            string lebel_0=newLabel() ; 
            string lebel_1=newLabel() ; 

            code+=$1->getAsmCode()+$3->getAsmCode() ; 
            code += "\t ; rel_expression : simple_expression RELOP simple_expression\n" ; 
            code+="\t ; "+$$->getName()+"\n" ; 

            code += "\tMOV AX , " + $1->getAsmVar()  + "\n" ; 
			code += "\tCMP AX , " + $3->getAsmVar() + "\n" ; 
            if($2->getName() == "<"){code += "\tJL " + lebel_1 + "\n" ; }
            else if($2->getName() == ">"){code += "\tJG " + lebel_1 + "\n" ; }
            else if($2->getName() == "<="){code += "\tJLE " + lebel_1 + "\n" ; }
            else if($2->getName() == ">="){code += "\tJGE " + lebel_1 + "\n" ; }
            else if($2->getName() == "=="){code += "\tJE " + lebel_1 + "\n" ; }
            else{code += "\tJNE " + lebel_1 + "\n" ; }

            code += "\tMOV AX , 0\n" ; 
            code += "\tMOV " + temp + " , AX\n" ; 
            code += "\tJMP " + lebel_0 + "\n\n" ; 
            code += "\t"+lebel_1 + ":\n" ; 
            code += "\tMOV AX , 1\n" ; 
            code += "\tMOV " + temp + ", AX\n" ; 
            code += "\t"+lebel_0 + ":\n" ; 
            code += "\t ; Rel_expression relop executed \n\n" ; 

            $$->setAsmCode(code) ; 
            $$->setAsmVar(temp) ; 
        }
 ; 
simple_expression : term 
        {
            logout << "Line "<<line_count<<": simple_expression : term\n\n" ; 
            $$ = $1 ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | simple_expression ADDOP term 
        {
            logout << "Line "<<line_count<<": simple_expression : simple_expression ADDOP term \n\n" ; 
            
            string type = "int" ; 
            if (($1->getType() == "float") || ($3->getType() == "float"))
            {
                type = "float" ; 
            }

            string temp=newTemp() ; 
            string code = "" ; 

            $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName(), type) ; 

            code += $1->getAsmCode()+$3->getAsmCode() ; 
            code +="\t ; "+$$->getName()+"\n" ; 
            code += "\tMOV AX , " + $1->getAsmVar()  + "\n" ; 
            if ($2->getName() == "+") {  
                code += "\tADD AX , " + $3->getAsmVar() + "\n" ; 
            }
            else {
                code += "\tSUB AX , " + $3->getAsmVar() + "\n" ; 
            }
            code += "\tMOV " + temp + " , AX\n\n" ; 


            $$->setAsmCode(code) ; 
            $$->setAsmVar(temp) ; 

            
            logout << $$->getName()<<"\n\n" ; 
        }
 ; 
term : unary_expression 
        {
            logout << "Line "<<line_count<<": term : unary_expression\n\n" ; 
            $$ = $1 ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | term MULOP unary_expression 
        {
            logout << "Line "<<line_count<<": term : term MULOP unary_expression\n\n" ; 

            string return_type ; 
            
            if($2->getName() == "%"){
                if($1->getType() != "int" || $3->getType() != "int"){
                    error_count++ ; 
                    errorout << "Error at line " << line_count << ": Non-integer operand on modulus operator" <<"\n\n" ; 
					return_type="error" ; 
                }
                else if($3->getName()=="0"){
                    error_count++ ; 
                    errorout << "Error at line " << line_count << ": Modulus by zero" <<"\n\n" ; 
					return_type="error" ; 
                }
                return_type="int" ; 
            }
            else if($2->getName() == "/" && $3->getName()=="0"){
                    error_count++ ; 
                    errorout << "Error at line " << line_count << ": Divided by zero not possible" <<"\n\n" ; 
					return_type="error" ; 
            }
            else if($2->getName() == "/" || $2->getName()=="*"){
                if($1->getType()=="float" || $3->getType()=="float"){
                    return_type="float" ; 
                }
                else return_type="int" ; 
            }
            else{
                return_type="undeclared" ; 
            }
            
            $$ = new symbolInfo($1->getName() + $2->getName()+ $3->getName(), return_type) ; 
            string temp = newTemp() ; 
                string code="" ; 
                code += "\t ; " + $$->getName() + "\n" ; 
            if(return_type=="int"){
                
                code+=$1->getAsmCode()+$3->getAsmCode() ; 
                if($2->getName()=="*"){
                    code += "\tMOV AX , " + $1->getAsmVar() + "\t\t\t ;  AX=" + $1->getAsmVar() + "\n" ; 
                    code += "\tMOV BX , " + $3->getAsmVar() + "\t\t\t ;  BX=" + $3->getAsmVar() + "\n" ; 
                    code += "\tMUL BX\t\t\t ; AX=AX*BX\n" ; 
                    code += "\tMOV " + temp + " , AX\n\n" ; 
                }
                else{
                    code += "\tMOV AX , " + $1->getAsmVar() + "\t\t\t ;  AX=" + $1->getAsmVar() + "\n" ; 
                    code += "\tMOV BX , " + $3->getAsmVar() + "\t\t\t ;  BX=" + $3->getAsmVar() + "\n" ; 
                    code += "\tXOR DX , DX\t\t\t ; DX=0\n" ; 
                    code += "\tDIV BX\t\t\t ; DX=AX%BX\n" ; 
                    if($2->getName()=="/")code += "\tMOV " + temp + ", AX\n\n" ; 
                    else if($2->getName()=="%")code += "\tMOV " + temp + ", DX\n\n" ; 
                }

            }

            $$->setAsmCode(code) ; 
            $$->setAsmVar(temp) ; 
            logout << $$->getName()<<"\n\n" ; 
        }
 ; 
unary_expression : ADDOP unary_expression 
        {
            logout << "Line "<<line_count<<": unary_expression : ADDOP unary_expression\n\n" ; 
            $$ = new symbolInfo($1->getName() + $2->getName(),	$2->getType()) ; 
            logout << $$->getName()<<"\n\n" ; 

            string code = "" ; 
            string temp=$2->getAsmVar() ; 
            code+=$2->getAsmCode() ; 

            if($1->getName()=="-"){
                
                code+="\t ; "+$$->getName()+"\n" ; 
                code += "\tMOV AX , " + temp + "\n" ; 
                temp=newTemp() ; 
				code += "\tMOV " + temp + " , AX\n" ; 
				code += "\tNEG " + temp + "\n\n" ; 
            }

            $$->setAsmCode(code) ; 
            $$->setAsmVar(temp) ; 

        }
    | NOT unary_expression 
        {
            logout << "Line "<<line_count<<": unary_expression : NOT unary_expression\n\n" ; 
            $$ = new symbolInfo("!" + $2->getName(),  $2->getType()) ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | factor 
        {
            logout << "Line "<<line_count<<": unary_expression : factor\n\n" ; 
            $$ = $1 ; 
            logout << $$->getName()<<"\n\n" ; 
        }
 ; 
factor : variable 
        {
            logout << "Line "<<line_count<<": factor : variable\n\n" ; 
            $$ = $1 ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | ID LPAREN argument_list RPAREN 
        {
            logout << "Line "<<line_count<<": factor : ID LPAREN expression RPAREN\n\n" ; 
            
            symbolInfo *curr ; 
            curr = st.LookUp($1->getName()) ; 

            string temp ; 
			string code = "" ; 
            code+="\t ; factor : ID LPAREN expression RPAREN\n" ; 

            //undeclared function
            if(curr==NULL){
			    errorout << "Error at line " << line_count << ": Undeclared function " << $1->getName() << "\n\n" ; 
			    error_count++ ; 
                $$ = new symbolInfo($1->getName()+"(" + $3->getName() + ")",	"undeclared" ) ; 

            }
            else{
                //function
                if(curr->isFunction()){
                    $$ = new symbolInfo($1->getName()+"(" + $3->getName() + ")", curr->getType() ) ; 

                    vector<string> argNames = splitString($3->getName(), ',') ; 
					vector<string> argTypes = splitString($3->getType(), ',') ; 

                    vector<pair<string,string>> paramList = curr->getParamList() ; 

                    
                    if(argNames.size() != paramList.size()){
                        error_count++ ; 
                        errorout << "Error at line " << line_count << ": Number of arguments isn't consistent with function" <<$1->getName() <<"\n\n" ; 
                    }
                    else{
                        for(int i=0 ; i<argNames.size() ; i++){
                            if(argTypes[i] != paramList[i].second){
                                error_count++ ; 
                                errorout << "Error at line " << line_count << ": Type mismatch on function '" << curr->getName() << "'s argument '" << paramList[i].first << "'\n\n" ; 
                            }
                        }

                        code+="\t ; pusing registers in stack\n" ; 
                        code += "\tPUSH AX\n" ; 
						code += "\tPUSH BX\n" ; 
						code += "\tPUSH CX\n" ; 
						code += "\tPUSH DX\n" ; 

						// Pushing the value of arguments in the stack
						// to get back in the PROC later.
                        vector<string> asmNames= splitString($3->getAsmVar(),',') ; 
						int c = asmNames.size() ; 
                            code+="\t ; pusing arguments in stack\n" ; 
                            //code+="\t ; ---asmvar"+$3->getAsmVar()+"\n" ; 
						while(c--) {
							code += "\tPUSH " + asmNames[c] + "\n" ; 
						}

						code += "\tCALL " + curr->getName() + "\t\t\t ; calling the function\n" ; 
						temp = newTemp() ; 
						if(curr->getType()!="void")code += "\tPOP " + temp + " ; getting the return value\n" ; 

                        code+="\t ; poping registers in stack\n" ; 
						code += "\tPOP DX\n" ; 
						code += "\tPOP CX\n" ; 
						code += "\tPOP BX\n" ; 
						code += "\tPOP AX\n" ; 
                        code+="\t ; function call ends here \n\n" ; 
                    }

                }
                else // non function
                {
                    errorout << "Error at line " << line_count << "Non function Identifier '" << curr->getName() << "' accessed\n\n" ; 
                    error_count++ ; 
                    $$ = new symbolInfo($1->getName()+"(" + $3->getName() + ")",	"undeclared" ) ; 
                }
            }
           
            logout << $$->getName()<<"\n\n" ; 
            $$->setAsmCode(code) ; 
            $$->setAsmVar(temp) ;    


        }
    | LPAREN expression RPAREN 
        {
            logout << "Line "<<line_count<<": factor : LPAREN argument_list RPAREN\n\n" ; 
            $$ = new symbolInfo("(" + $2->getName() + ")",	$2->getType() ) ; 
            $$->setAsmCode($2->getAsmCode()) ; 
            $$->setAsmVar($2->getAsmVar()) ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | CONST_INT 
        {
            logout << "Line "<<line_count<<": factor : CONST_INT\n\n" ; 
            $$ = yylval.symbolinfo ; 
            $$->setAsmVar($$->getName()) ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | CONST_FLOAT 
        {
            logout << "Line "<<line_count<<": factor : CONST_FLOAT\n\n" ; 
            $$ = yylval.symbolinfo ; 
            $$->setAsmVar($$->getName()) ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | variable INCOP 
        {
            logout << "Line "<<line_count<<": factor : variable INCOP\n\n" ; 
            $$ = new symbolInfo($1->getName() + "++",	$1->getType()) ; 

            string temp = newTemp() ; 
            string code="" ; 
            code+="\n\t ; "+$$->getName()+"\n" ; 
            code+="\tMOV AX , "+$1->getAsmVar()+"\n" ; 
            code+="\tMOV "+temp+" , AX\n" ; 
            code+="\tINC "+$1->getAsmVar()+"\n" ; 
            
            $$->setAsmCode(code) ; 
            $$->setAsmVar(temp) ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | variable DECOP 
        {
            logout << "Line "<<line_count<<": factor : variable DECOP\n\n" ; 
            $$ = new symbolInfo($1->getName() + "--",	$1->getType()) ; 

            string temp = newTemp() ; 
            string code="" ; 
            code+="\n\t ; "+$$->getName()+"\n" ; 
            code+="\tMOV AX , "+$1->getAsmVar()+"\n" ; 
            code+="\tMOV "+temp+" , AX\n" ; 
            code+="\tDEC "+$1->getAsmVar()+"\n" ; 
            
            $$->setAsmCode(code) ; 
            $$->setAsmVar(temp) ; 

            logout << $$->getName()<<"\n\n" ; 
        }
 ; 
argument_list : arguments 
        {
            logout << "Line "<<line_count<<": argument_list : arguments\n\n" ; 
            $$ = $1 ; 
            logout << $$->getName()<<"\n\n" ; 
        }
    | 
        {
            logout << "Line "<<line_count<<": argument_list : \n\n" ; 
            $$ = new symbolInfo("","void") ; 
            logout << $$->getName()<<"\n\n" ; 
        }
 ; 
arguments : arguments COMMA logic_expression 
        {
            logout << "Line "<<line_count<<": arguments : arguments COMMA logic_expression\n\n" ; 
            string argNames = $1->getName() + "," + $3->getName() ; 
            string argTypes = $1->getType() + "," + $3->getType() ; 

            $$ = new symbolInfo(argNames, argTypes) ; 
            $$->setAsmCode($1->getAsmCode()+$3->getAsmCode()) ; 
            $$->setAsmVar($1->getAsmVar()+","+$3->getAsmVar()) ; 

            logout << $$->getName()<<"\n\n" ; 

        }
    | logic_expression 
        {
            logout << "Line "<<line_count<<": arguments : logic_expression\n\n" ; 
            $$ = $1 ; 
            logout << $$->getName()<<"\n\n" ; 
        }
 ; 
%%

main(int argc,char *argv[])
{

    //#ifdef YYDEBUG
    //yydebug = 1 ; 
    //#endif

    if(argc!=2){
		cout << "Please provide input file name and try again\n" ; 
		return 0 ; 
	}
	FILE *infile=fopen(argv[1],"r") ; 
	if(infile==NULL){
		cout << "Cannot open specified file\n" ; 
		return 0 ; 
	}
	
	
	yyin=infile ; 
	yyparse() ; 
	//symboltable.printAllScopeTable(logout) ; 
	logout << "Total lines: " << line_count-1 << endl ; 
    logout << "Total errors: " << error_count << endl ; 
	fclose(yyin) ; 
	logout.close() ; 
	errorout.close() ; 
	
	
	return 0 ; 
}