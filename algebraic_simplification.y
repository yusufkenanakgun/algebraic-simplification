%{
#include <stdio.h>
#include <iostream>
#include <string>
#include <map>
#include <cmath>
#include <cstring> // For strdup

using namespace std;
#include "y.tab.h"

extern FILE *yyin;
extern int yylex();
void yyerror(const char* s);
string algebraic_simplification(string str1, string str2, char op);


// Dead code elimination function
bool dead_code(string a, string b) {
    return a == b;
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

%start program

%%
program:
    program statement SEMICOLON
    |
    ;

statement:
    IDENTIFIER ASSIGN INTEGER 
    {
        cout << $1 << " = " << $3 << endl;
    }
    | IDENTIFIER ASSIGN IDENTIFIER
    {
        if (!dead_code(string($1), string($3))) {
            cout << $1 << " = " << $3 << endl;
        }
    }
    | IDENTIFIER ASSIGN INTEGER OP INTEGER
    {
        string str = to_string($3) + $4 + to_string($5);
        cout << $1 << " = " << str << endl;
    }
    | IDENTIFIER ASSIGN IDENTIFIER OP INTEGER
    {
        string str = algebraic_simplification(string($3), to_string($5), $4);
        if (!dead_code(string($1), str)) {
            cout << $1 << " = " << str << endl;
        }
    }
    | IDENTIFIER ASSIGN INTEGER OP IDENTIFIER
    {
        string str = algebraic_simplification(to_string($3), string($5), $4);
        if (!dead_code(string($1), str)) {
            cout << $1 << " = " << str << endl;
        }
    }
    | IDENTIFIER ASSIGN IDENTIFIER OP IDENTIFIER
    {
        string str = string($3) + $4 + string($5);
        if (!dead_code(string($1), str)) {
            cout << $1 << " = " << str << endl;
        }
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

// Algebraic simplification function
string algebraic_simplification(string str1, string str2, char op) {
    switch (op) {
        case '+':
            if (str1 == "0") { return str2; }
            else if (str2 == "0") { return str1; }
            break;

        case '-':
            if (str1 == "0") { return "-" + str2; }
            else if (str2 == "0") { return str1; }
            break;

        case '*':
            if (str1 == "1") { return str2; }
            else if (str2 == "1") { return str1; }
            else if (str1 == "0" || str2 == "0") { return "0"; }
            break;

        case '/':
            if (str2 == "0") {
                yyerror("Division by zero!");
                return ""; // Handle division by zero gracefully
            }
            if (str1 == "0") { return "0"; }
            else if (str2 == "1") { return str1; }
            break;

        case '^':
            if (str2 == "2") { return str1 + "*" + str1; }
            else if (str2 == "1") { return str1; }
            else if (str2 == "0") { return "1"; }
            break;

        default:
            yyerror("Invalid operator for simplification!");
            return "";
    }
    return str1 + string(1, op) + str2;
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
