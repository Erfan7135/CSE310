#include<iostream>
#include<string>


using namespace std;

class symbolTable{
    int bucket;
    scopeTable *current;

public:
    symbolTable(int n);
    void Enter();
    void Exit();
    void printCurrent();
    void printAll();
    bool Insert(string a,string b);
    symbolInfo* LookUp(string a);
    bool Remove(string str);

    ~symbolTable();

};

symbolTable::symbolTable(int n){
    bucket = n;
    current=new scopeTable(n);
    current->setParent(NULL);
}

void symbolTable::Enter(){
    scopeTable *a = new scopeTable(bucket);
    a->setParent(current);
    current->setChild(current->getChild()+1);
    string ID = current->getId();
    ID.append(".");
    ID.append(to_string(current->getChild()));
    a->setId(ID);
    current=a;
    cout<<"Created Scope with ID#"<<current->getId()<<"\n\n";
}

void symbolTable::Exit(){
    if(current!=NULL){
        cout<<"Exited from Scope with ID#"<<current->getId()<<"\n\n";
        current=current->getParent();
    }
    else cout<<"No Current Scope \n\n";
}

void symbolTable::printCurrent(){
    current->print();
}

void symbolTable::printAll(){
    scopeTable *temp = current;
    while(temp!=NULL){
        temp->print();
        temp=temp->getParent();
    }
    cout<<"\n\n";
}

bool symbolTable::Insert(string a,string b){
    if(current==NULL){
        current=new scopeTable(bucket);
    current->setParent(NULL);
    }
    return current->Insert(new symbolInfo(a,b));
}

symbolInfo* symbolTable::LookUp(string a){
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
    cout<<"Not Found\n\n";
    return NULL;
}

bool symbolTable::Remove(string str){
    scopeTable *s;
    s=current;
    while(s!=NULL){
        bool a = s->Delete(str);
        if(a)return true;
        s=s->getParent();

    }
    cout<<str<<" Not Found\n\n";
    return NULL;
}

symbolTable::~symbolTable(){
    scopeTable *s;
    s=current;
    while(s!=NULL){
        current = current->getParent();
        delete s;
        s = current;
    }
}
