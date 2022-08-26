#include<iostream>
#include<string>


using namespace std;

class scopeTable{
    int buckets;
    symbolInfo **table;
    scopeTable *parent;
    string id;
    int child_no;
    unsigned long hash(string str);

public:
    scopeTable(int n);

    void setParent(scopeTable *s);
    void setId(string &str);
    void setChild(int n);

    scopeTable* getParent();
    string getId();
    int getChild();

    bool Insert(string a, string b);
    symbolInfo* LookUp(string str);
    bool Delete(string str);
    void print();

    ~scopeTable();

};

unsigned long scopeTable::hash(string str){
    unsigned long hash = 0;
    unsigned int i = 0;
    unsigned int len = str.length();

   for(i=0;i<len;i++)
        hash = str[i] + (hash << 6) + (hash << 16) - hash;

    return hash%buckets;
}


scopeTable::scopeTable(int n){
    buckets = n;
    table = new symbolInfo*[buckets];
    parent = NULL;
    for(int i=0;i<n;i++){
        table[i]=NULL;
    }
    id="1";
    child_no=0;
}

string scopeTable::getId(){
    return id;
}

scopeTable* scopeTable::getParent(){
    return parent;
}

int scopeTable::getChild(){
    return child_no;
}

void scopeTable::setId(string &str){
    id=str;
}

void scopeTable::setParent(scopeTable *s){
    parent=s;
}

void scopeTable::setChild(int n){
    child_no=n;
}

bool scopeTable::Insert(string a, string b){
    symbolInfo *s = new symbolInfo(a,b);
    unsigned long bucket_no = hash(s->getName().c_str());
    if(table[bucket_no]==NULL){
        table[bucket_no]=s;
        //logout<<"Inserted in ScopeTable# "<<id<<" at position "<<bucket_no<<", "<< 0<<"\n\n"<<endl;
        return true;
    }
    else{
        int p=0;
        symbolInfo *curr,*prev;
        curr=table[bucket_no];
        prev=NULL;
        while(curr!=NULL ){
            if(curr->getName().compare(s->getName())==0){
                //Already Exist
                logout<<"<"<<s->getName()<<","<<s->getType()<<"> ";
                logout<<"Already exist in current Scope Table\n\n"<<endl;
                delete s;
                return false;
            }
            prev=curr;
            curr=curr->getNext();
            p++;
        }
        prev->setNext(s);
        logout<<"Inserted in ScopeTable# "<<id<<" at position "<<bucket_no<<", "<< p<<"\n\n"<<endl;
        return true;
    }
}

symbolInfo* scopeTable::LookUp(string str){
    unsigned long bucket_no = hash(str.c_str());
    if(table[bucket_no]==NULL){
        return NULL;//bucket empty, not found
    }
    else{
        symbolInfo *a;
        a=table[bucket_no];
        int p=0;
        while(a!=NULL ){
            if(a->getName().compare(str)==0){
                //Found
                logout<<"Found in ScopeTable# "<<id<<" at position "<<bucket_no<<", "<< p<<"\n\n"<<endl;
                return a;
            }
            p++;
            a=a->getNext();
        }
        //not found
        return NULL;
    }
}

bool scopeTable::Delete(string str){
    unsigned long bucket_no = hash(str.c_str());
    if(table[bucket_no]==NULL){
        return false;//not found
    }
    else{
        symbolInfo *a,*b;
        b=NULL;
        a=table[bucket_no];
        int p=0;
        while(a!=NULL ){
            if(a->getName().compare(str)==0){
                //found
                // if found in first position
                if(b==NULL){
                    table[bucket_no]=a->getNext();
                }
                // if found in other position
                else{
                    b->setNext(a->getNext());
                }
                logout<<"Found in ScopeTable# "<<id<<" at position "<<bucket_no<<", "<< p<<"\n";
                logout<<"Deleted entry at "<<bucket_no<<","<<p<<" in the current scopetable\n\n";
                delete a;
                return true;
            }
            p++;
            b=a;
            a=a->getNext();
        }
        return false;//not found
    }
}

void scopeTable::print(){

    logout<<"\nScopeTable #"<<id<<"\n";
    for(int i=0;i<buckets;i++){
        
        symbolInfo *a;
        a=table[i];
        if(a==NULL)continue;
        logout<<i<<"-->";
        while(a!=NULL){
            logout<<"<"<<a->getName()<<":"<<a->getType()<<">";
            a = a->getNext();
        }
        logout<<"\n";
    }
}

scopeTable::~scopeTable(){
    for(int i=0;i<buckets;i++){
        symbolInfo *temp;
        temp=table[i];
        while(temp!=NULL){
            table[i]=temp->getNext();
            delete temp;
            temp=table[i];
        }

    }
    delete []table;
}

