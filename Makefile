all:
	flex our_c.l
	bison -d our_c.y
	g++ -std=c++11 lex.yy.c our_c.tab.c -o gengo.out
	rm lex.yy.c our_c.tab.c our_c.tab.h