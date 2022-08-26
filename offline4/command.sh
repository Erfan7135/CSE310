#!/bin/bash

bison -v --debug --defines=y.tab.h -Wconflicts-sr 1805080.y
echo '1'
g++ -w -c -o y.o 1805080.tab.c
echo '2'
flex 1805080.l		
echo '3'
g++ -w -c -o l.o lex.yy.c
echo '4'
g++ -o a.out y.o l.o -lfl
echo '5'
./a.out test5_i.c
