#include <stdio.h>

extern void show();
extern int yyparse();
extern void yyrestart();
extern void optimize();

int main(int argc, char**argv){
if(argc < 2){
	yyparse();
	return 0;
	}
for(int i = 1; i < argc; i++){
	FILE *f = fopen(argv[i],"r");
	if(!f) return 1;
	yyrestart(f);
	yyparse();
	fclose(f);
	}
show();
optimize();
printf("\n\n");
show();
printf("\n\n");
return 0;
}
