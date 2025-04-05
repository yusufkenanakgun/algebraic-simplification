%{
#include <stdio.h>
#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <cmath>
#include <cstring> // For strdup

using namespace std;

extern FILE *yyin;
extern int yylex();
void yyerror(const char* s);

map<string, int> symbolTable;
map<string, string> stringSymbolTable;

%}

%union {
    int ival;
    char *str;
    char op;
}

%token ASSIGN SEMICOLON
%token <str> IDENTIFIER
%token <ival> INTEGER
%token <op> OP

%start program

%%
program:
    program statement SEMICOLON
    |
    ;

statement:
    IDENTIFIER ASSIGN INTEGER 
    {
        symbolTable[$1] = $3;
        cout << $1 << " = " << $3 << ";" << endl;
    }
    | IDENTIFIER ASSIGN IDENTIFIER
    {
        string str;

        if (symbolTable.find($3) != symbolTable.end()) {
            symbolTable[$1] = symbolTable[$3];
            str = to_string(symbolTable[$3]);
        } else if (stringSymbolTable.find($3) != stringSymbolTable.end()) {
            stringSymbolTable[$1] = stringSymbolTable[$3];
            str = stringSymbolTable[$3];
        } else {
            stringSymbolTable[$1] = $3;
            str = $3;
        }
        cout << $1 << " = " << str << ";" << endl;
    }
    | IDENTIFIER ASSIGN INTEGER OP INTEGER
    {
        string str = to_string($3) + $4 + to_string($5) ;
        cout << $1 << " = " << str << ";" << endl;
    }
    | IDENTIFIER ASSIGN IDENTIFIER OP INTEGER
    {
        string leftValue;

        if (symbolTable.find($3) != symbolTable.end()) {
            leftValue = to_string(symbolTable[$3]);
        } else if (stringSymbolTable.find($3) != stringSymbolTable.end()) {
            leftValue = stringSymbolTable[$3];
        } else {
            leftValue = $3;
        }
        cout << $1 << " = " << leftValue + $4 + to_string($5) << ";" << endl;
    }
    | IDENTIFIER ASSIGN INTEGER OP IDENTIFIER
    {
        string rightValue;

        if (symbolTable.find($5) != symbolTable.end()) {
            rightValue = to_string(symbolTable[$5]);
        } else if (stringSymbolTable.find($5) != stringSymbolTable.end()) {
            rightValue = stringSymbolTable[$5];
        } else {
            rightValue = $5;
        }
        cout << $1 << " = " << to_string($3) + $4 + rightValue << ";" << endl;
    }
    | IDENTIFIER ASSIGN IDENTIFIER OP IDENTIFIER
    {
        string leftValue, rightValue;

        if (symbolTable.find($3) != symbolTable.end()) {
            leftValue = to_string(symbolTable[$3]);
        } else if (stringSymbolTable.find($3) != stringSymbolTable.end()) {
            leftValue = stringSymbolTable[$3];
        } else {
            leftValue = $3;
        }

        if (symbolTable.find($5) != symbolTable.end()) {
            rightValue = to_string(symbolTable[$5]);
        } else if (stringSymbolTable.find($5) != stringSymbolTable.end()) {
            rightValue = stringSymbolTable[$5];
        } else {
            rightValue = $5;
        }
        cout << $1 << " = " << leftValue + $4 + rightValue << ";" << endl;
    }
    | error
    {
        cout << "Syntax error in assignment. Skipping to the next statement..." << endl;
    }
    ;
%%
void yyerror(const char* s) {
    cerr << "Error: " << s << endl;
}

int yywrap() {
    return 1;
}

int main(int argc, char *argv[]) {
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        cerr << "Could not open file: " << argv[1] << endl;
        return 1;
    }
    yyparse();
    fclose(yyin);
    return 0;
}
