%{
#include <stdio.h>
#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <cmath>
#include <cstring> // For strdup

using namespace std;
#include "y.tab.h"

extern FILE *yyin;
extern int yylex();
void yyerror(string s);

vector<string> stringSymbolTable;

int operation(int num1, int num2, char op) {
    switch (op) {
        case '+': return num1 + num2;
        case '-': return num1 - num2;
        case '*': return num1 * num2;
        case '/':
            if (num2 == 0) {
                yyerror("Division by zero!");
                return 0;
            }
            return num1 / num2;
        case '^': return pow(num1, num2);
        default:
            yyerror("Invalid operator!");
            return 0;
    }
}

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

%type <str> statement assignment program
%%

program:
        assignment program
        |
        {
            // Print all stored lines at the end
            for (size_t i = 0; i < stringSymbolTable.size(); ++i) {
                cout << stringSymbolTable[i] << endl;
            }
        }
        ;

assignment:
    statement SEMICOLON
    ;

statement:
    IDENTIFIER ASSIGN INTEGER
    {
        string line = string($1) + " = " + to_string($3) + ";";
        stringSymbolTable.push_back(line);
    }
    | IDENTIFIER ASSIGN IDENTIFIER
    {
        string line = string($1) + " = " + string($3) + ";";
        stringSymbolTable.push_back(line);
    }
    | IDENTIFIER ASSIGN INTEGER OP INTEGER
    {
        int a = operation($3, $5, $4);
        string line = string($1) + " = " + to_string(a) + ";";
        stringSymbolTable.push_back(line);
    }
    | IDENTIFIER ASSIGN IDENTIFIER OP INTEGER
    {
        string line = string($1) + " = " + string($3) + $4 + to_string($5) + ";";
        stringSymbolTable.push_back(line);
    }
    | IDENTIFIER ASSIGN INTEGER OP IDENTIFIER
    {
        string line = string($1) + " = " + to_string($3) + $4 + string($5) + ";";
        stringSymbolTable.push_back(line);
    }
    | IDENTIFIER ASSIGN IDENTIFIER OP IDENTIFIER
    {
        string line = string($1) + " = " + string($3) + $4 + string($5) + ";";
        stringSymbolTable.push_back(line);
    }
    | error
    {
        cout << "Syntax error in assignment. Skipping to the next statement..." << endl;
    }
    ;

%%

void yyerror(string s) {
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
