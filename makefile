parser: lexical
	gcc main.c syntax.tab.c -lfl -ly -o parser
lexical: syntax
	flex lexical.l
syntax: 
	bison -d -v syntax.y

# 定义的一些伪目标
.PHONY: clean test
test:
	./parser lab2_test/lab2_1.txt
	./parser lab2_test/lab2_2.txt
	./parser lab2_test/lab2_3.txt
clean:
	rm -f parser lex.yy.c syntax.tab.c syntax.tab.h syntax.output
