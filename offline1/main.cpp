#include<iostream>
#include<fstream>

#include "symbolInfo.cpp"
#include "scopeTable.cpp"
#include "symbolTable.cpp"



using namespace std;


int main(){

    ifstream fin("input.txt");
    int n;
    fin>>n;
    symbolTable ST(n);
    char c;
    string str1,str2;
    while(getline(fin,str1)){
        fin>>c;
        if(c=='I'){
            fin>>str1>>str2;
            cout<<"I "<<str1<<" "<<str2<<"\n";
            ST.Insert(str1,str2);
        }
        else if(c=='L'){
            fin>>str1;
            cout<<"L "<<str1<<"\n";
            ST.LookUp(str1);
        }
        else if(c=='P'){
            fin>>c;
            if(c=='A'){
                cout<<"P A"<<"\n";
                ST.printAll();
            }
            else if(c=='C'){
                cout<<"P C"<<"\n";
                ST.printCurrent();
            }
            else{

            }
        }
        else if(c=='D'){
            fin>>str1;
            cout<<"D "<<str1<<"\n";
            ST.Remove(str1);

        }
        else if(c=='S'){
             cout<<"S"<<"\n";
            ST.Enter();
        }
        else if(c=='E'){
            cout<<"E"<<"\n";
            ST.Exit();
        }
        else{

        }
    }

    fin.close();


    return 0;
}
