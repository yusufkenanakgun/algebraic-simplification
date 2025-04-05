# Compiler and Tools
CC = g++
YACC = yacc
LEX = lex

# Files
LEX_FILE = project.l
CONST_YACC_FILE = constant_folding.y
COPY_YACC_FILE = copy_propagation.y
SIMP_YACC_FILE = algebraic_simplification.y

CONST_OUTPUT = constant_folding
COPY_OUTPUT = copy_propagation
SIMP_OUTPUT = algebraic_simplification

# Default target
all: lex const copy simp

# Build constant_folding
const: $(CONST_YACC_FILE)
	$(YACC) -d -v $(CONST_YACC_FILE)
	$(LEX) $(LEX_FILE)
	$(CC) lex.yy.c y.tab.c -ll -o $(CONST_OUTPUT)

# Build copy_propagation
copy: $(COPY_YACC_FILE)
	$(YACC) -d -v $(COPY_YACC_FILE)
	$(LEX) $(LEX_FILE)
	$(CC) lex.yy.c y.tab.c -ll -o $(COPY_OUTPUT)

simp: $(SIMP_YACC_FILE)
	$(YACC) -d -v $(SIMP_YACC_FILE)
	$(LEX) $(LEX_FILE)
	$(CC) lex.yy.c y.tab.c -ll -o $(SIMP_OUTPUT)

# Lex file processing
lex: $(LEX_FILE)
	$(LEX) $(LEX_FILE)

# Clean generated files
clean:
	rm -f lex.yy.c y.tab.c y.tab.h y.output $(CONST_OUTPUT) $(COPY_OUTPUT) $(SIMP_OUTPUT) output.txt input.txt

# Run constant_folding
run_const_fold:
	./$(CONST_OUTPUT) input.txt > output.txt

# Run copy_propagation
run_copy_prop:
	./$(COPY_OUTPUT) output.txt > input.txt

run_algbr_simp:
	./$(SIMP_OUTPUT) input.txt
