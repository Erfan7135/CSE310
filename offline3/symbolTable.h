#include<iostream>
#include<string>


using namespace std;

class symbolInfo{
    string Name;
    string Type;

    symbolInfo *next;
public:

    
 symbolInfo(string A, string B){
    Name=A;
    Type=B;
    next = NULL;
}

    void  setName(string A){
        Name=A;
    }

    void  setType(string B){
        Type=B;
    }

    void  setNext(symbolInfo *s){
        next = s;
    }


    string  getName(){
        return Name;
    }
    string  getType(){
        return Type;
    }

    symbolInfo*  getNext(){
        return next;
    }

    ~symbolInfo(){

    }


};

class scopeTable{
    int buckets;
    symbolInfo **table;
    scopeTable *parent;
    string id;
    int child_no;
    unsigned long  hash(string str){
    unsigned long hash = 0;
    unsigned int i = 0;
    unsigned int len = str.length();

   for(i=0;i<len;i++)
        hash = str[i] + (hash << 6) + (hash << 16) - hash;

    return hash%buckets;
}

public:
    


 scopeTable(int n){
    buckets = n;
    table = new symbolInfo*[buckets];
    parent = NULL;
    for(int i=0;i<n;i++){
        table[i]=NULL;
    }
    id="1";
    child_no=0;
}

string  getId(){
    return id;
}

scopeTable*  getParent(){
    return parent;
}

int  getChild(){
    return child_no;
}

void  setId(string &str){
    id=str;
}

void  setParent(scopeTable *s){
    parent=s;
}

void  setChild(int n){
    child_no=n;
}

bool  Insert(string a, string b){
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
                //logout<<"\n"<<s->getName();
                //logout<<" already exists in current ScopeTable"<<endl;
                delete s;
                return false;
            }
            prev=curr;
            curr=curr->getNext();
            p++;
        }
        prev->setNext(s);
        //logout<<"Inserted in ScopeTable# "<<id<<" at position "<<bucket_no<<", "<< p<<"\n"<<endl;
        return true;
    }
}

symbolInfo*  LookUp(string str){
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
                //logout<<"Found in ScopeTable# "<<id<<" at position "<<bucket_no<<", "<< p<<"\n"<<endl;
                return a;
            }
            p++;
            a=a->getNext();
        }
        //not found
        return NULL;
    }
}

bool  Delete(string str){
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
                //logout<<"Found in ScopeTable# "<<id<<" at position "<<bucket_no<<", "<< p<<"\n";
                //logout<<"Deleted entry at "<<bucket_no<<","<<p<<" in the current scopetable\n\n";
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

void  print(){

    //logout<<"\nScopeTable # "<<id<<"\n";
    for(int i=0;i<buckets;i++){
        
        symbolInfo *a;
        a=table[i];
        if(a==NULL)continue;
        //logout<<i<<" --> ";
        while(a!=NULL){
            //logout<<"< "<<a->getName()<<" : "<<a->getType()<<">";
            a = a->getNext();
            //if(a!=NULL)logout<<" ";
        }
        //logout<<"\n";
    }
}

 ~scopeTable(){
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



};

class symbolTable{
    int bucket;
    scopeTable *current;

public:
    symbolTable(int n){
        bucket = n;
        current=new scopeTable(n);
        current->setParent(NULL);
    }

    void Enter(){
        scopeTable *a = new scopeTable(bucket);
        a->setParent(current);
        current->setChild(current->getChild()+1);
        string id = current->getId();
        id.append(".");
        id.append(to_string(current->getChild()));
        a->setId(id);
        current=a;
        //logout<<"Created Scope with ID#"<<current->getId()<<"\n\n";
    
    }
    void Exit(){
        if(current!=NULL){
            //logout<<"Exited from Scope with ID#"<<current->getId()<<"\n\n";
            scopeTable *temp = current;
            current=current->getParent();
            delete temp;
        }
        //else logout<<"No Current Scope \n\n";
    }

    void printCurrent(){
        current->print();
    }

    void printAll(){
        scopeTable *temp = current;
        while(temp!=NULL){
            temp->print();
            temp=temp->getParent();
        }
        //logout<<"\n\n";
    }

    bool Insert(string a,string b){
        if(current==NULL){
            current=new scopeTable(bucket);
            current->setParent(NULL);
        }
        return current->Insert(a,b);
    }

    symbolInfo* LookUp(string a){
        scopeTable *s;
        s=current;
        while(s!=NULL){
            symbolInfo *sI = s->LookUp(a);
            if(sI==NULL){
                s=s->getParent();
            }
            else{
                return sI;
            }

        }
        //logout<<"Not Found\n\n";
        return NULL;
    }

    symbolInfo* LookUp_Current(string a);
    bool Remove(string str){
        scopeTable *s;
        s=current;
        while(s!=NULL){
            bool a = s->Delete(str);
            if(a)return true;
        }
        //logout<<str<<" Not Found\n\n";
        return false;
    }


    ~symbolTable(){
        scopeTable *s;
        s=current;
        while(s!=NULL){
            current = current->getParent();
            delete s;
            s = current;
        }
    }

};
