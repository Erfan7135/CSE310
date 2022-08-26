#include<string>
#include<iostream>
using namespace std;

class symbolInfo{
    string Name;
    string Type;

    symbolInfo *next;
public:

    symbolInfo(string A,string B);
    void setName(string A);
    void setType(string B);
    void setNext(symbolInfo *s);
    string getName();
    string getType();
    symbolInfo* getNext();
    ~symbolInfo();
};


symbolInfo::symbolInfo(string A, string B){
    Name=A;
    Type=B;
    next = NULL;
}

void symbolInfo::setName(string A){
    Name=A;
}

void symbolInfo::setType(string B){
    Type=B;
}

void symbolInfo::setNext(symbolInfo *s){
    next = s;
}


string symbolInfo::getName(){
    return Name;
}
string symbolInfo::getType(){
    return Type;
}

symbolInfo* symbolInfo::getNext(){
    return next;
}

symbolInfo::~symbolInfo(){

}




