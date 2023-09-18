//这些东西看起来可能很复杂，但重复性操作较多，思路清晰并不难做

%{
#include <stdio.h>
#include <stdlib.h>

typedef struct node_t
{
    //表明结点的类型，用于打印输出
    //0	1	2	3	4	5
    //ID	TYPE	INT	FLOAT	value	symbol
    int type;
    //存放子结点个数
    int   n_children;         
    //存放当前行数
    int   line;   
    //指向子结点           
    struct node_t** children; 
    //存放结点值
    union{
    	char* name;
    	int int_value;
    	float float_value;
    	};
} NODE,*pNODE;

pNODE HEAD_NODE = NULL;
int error_count = 0;
int error_line = 0;

pNODE CreateNode(int type, int n_children, int line);
void ShowTree(pNODE node,int x);
void show();
void OptimizeTree(pNODE x, pNODE parent,int n);
void SelectOptimizeTree(pNODE x, pNODE parent,int n);
void ConditionDistribute(pNODE oldc,pNODE *c,char *ch1);
void ProjectionOptimizeTree(pNODE x, pNODE parent,int n);
void AttributeDistribute(pNODE oldc,pNODE *c,char *ch1);




#define YYSTYPE pNODE
#include "lex.yy.c"
%}

%token SELECT
%token PROJECTION
%token JOIN
%token ID
%token LP
%token RP
%token LB
%token RB
%token AND
%token COMMA
%token APOS
%token ASSIGNOP

%%
Program : Whole{	$$ = CreateNode(4,1,@$.first_line);
			$$->name = "Program";
			$$->children[0] = $1;
			HEAD_NODE = $$;
			}
	;
Whole : WholeX{
				$$ = CreateNode(4,1,@$.first_line);
				$$->name = "Whole";
				$$->children[0] = $1;
				}
	| SELECT LB Conditions RB LP Whole RP{
				$$ = CreateNode(4,7,@$.first_line);
				$$->name = "Whole";
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->children[3] = $4;
				$$->children[4] = $5;
				$$->children[5] = $6;
				$$->children[6] = $7;
				}
	| PROJECTION LB Attributes RB LP Whole RP{
				$$ = CreateNode(4,7,@$.first_line);
				$$->name = "Whole";
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->children[3] = $4;
				$$->children[4] = $5;
				$$->children[5] = $6;
				$$->children[6] = $7;
				}
	;
WholeX : Whole JOIN Whole{
				$$ = CreateNode(4,3,@$.first_line);
				$$->name = "WholeX";
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				}
	| ID{$$ = CreateNode(4,1,@$.first_line);
				$$->name = "WholeX";
				$$->children[0] = $1;}
	;

Conditions : Condition AND Conditions{
				$$ = CreateNode(4,3,@$.first_line);
				$$->name = "Conditions";
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				}
	| Condition{	$$ = CreateNode(4,1,@$.first_line);
			$$->name = "Conditions";
			$$->children[0] = $1;
			}
	;
Condition : ID ASSIGNOP APOS ID APOS{
				$$ = CreateNode(4,5,@$.first_line);
				$$->name = "Condition";
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->children[3] = $4;
				$$->children[4] = $5;
				}
	;
Attributes : ID COMMA Attributes{
				$$ = CreateNode(4,3,@$.first_line);
				$$->name = "Attributes";
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				}
	| ID{
				$$ = CreateNode(4,1,@$.first_line);
				$$->name = "Attributes";
				$$->children[0] = $1;
				}
	;
	
%%

//==================================================================
//函 数 名:CreateNode
//功能描述:建立树结点
//输入参数:int type,指明结点类型
//输入参数:int n_children,指明结点有几个子结点
//输入参数:int line,指明结点所在行
//返回值:pNODE ,树结点
//==================================================================
pNODE CreateNode(int type, int n_children, int line){
	pNODE new = (pNODE)malloc(sizeof(NODE));
	new -> type = type;
	new -> n_children = n_children;
	new -> line = line;
	new -> children = (struct node_t**)malloc(sizeof(pNODE) * n_children);
	return new;
}

//==================================================================
//函 数 名:ShowTree
//功能描述:遍历输出
//输入参数:pNODE node,遍历到的结点
//输入参数:int x,递归的层数
//==================================================================
void ShowTree(pNODE node, int x){
	if(node != NULL){
		switch(node->type){
			case(0):printf("%s\n",node->name);break;
			case(4):
				if(!strcmp(node->name,"Condition"))
				{
					for(int i = 0; i < x; i++)
						printf("  ");
					printf(" %s = ’ %s ’\n",node->children[0]->name,node->children[3]->name);
				}
				else if(!strcmp(node->name,"Attributes"))
				{
					for(int i = 0; i < x; i++)
						printf("  ");
					printf(" %s\n",node->children[0]->name);
					if(node->n_children == 3)
						ShowTree(node->children[2],x);
				}
				else if(!strcmp(node->name,"Whole"))
				{
					for(int i = 0; i < node->n_children; i++){
						ShowTree(node->children[i],x+1);
					}
				}
				else if(!strcmp(node->name,"WholeX"))
				{
					if(node->n_children == 1)
					{
						for(int i = 0; i < x; i++)
							printf("  ");
						printf("%s ",node->children[0]->name);
						
					}
					else
					{
						
						ShowTree(node->children[0],x+2);
						printf("\n");
						for(int i = 0; i < x+1; i++)
							printf("  ");
						printf("JOIN\n");
						ShowTree(node->children[2],x+2);
					}
				}
				else
				{
					for(int i = 0; i < node->n_children; i++){
						ShowTree(node->children[i],x);
				}
				break;
			case(5):if(!strcmp(node->name,"SELECT"))
				{
					for(int i = 0; i < x; i++)
						printf("  ");
					printf("SELECT\n");
				}
				else if(!strcmp(node->name,"PROJECTION"))
				{
					for(int i = 0; i < x; i++)
						printf("  ");
					printf("PROJECTION\n");
				}
					
				break;
		}
		}
	}
}

//==================================================================
//函 数 名:show
//功能描述:调用ShowTree
//==================================================================
void show(){
	ShowTree(HEAD_NODE,0);
}

//==================================================================
//函 数 名:OptimizeTree
//功能描述:优化树
//输入参数:pNODE x,Whole结点
//输入参数:pNODE parent,Whole的父结点
//输入参数:int n,Whole是其父结点的第几个子树
//==================================================================
void OptimizeTree(pNODE x, pNODE parent,int n)
{
	//选择或者投影
	if(x->n_children == 7)
	{
		if(!strcmp(x->children[0]->name,"SELECT"))
			SelectOptimizeTree(x,parent,n);
		else
			ProjectionOptimizeTree(x,parent,n);
	}
}

//==================================================================
//函 数 名:SelectOptimizeTree
//功能描述:Select优化树，将先连接后选择改为先选择后连接
//输入参数:pNODE x,Whole结点
//输入参数:pNODE parent,Whole的父结点
//输入参数:int n,Whole是其父结点的第几个子树
//==================================================================
void SelectOptimizeTree(pNODE x, pNODE parent,int n)
{

	//查看内层语句
	//内层非选择或者投影
	if(x->children[5]->n_children == 1)
	{
		//内层包含连接
		if(x->children[5]->children[0]->n_children == 3)
		{
			parent->children[n] = x->children[5];
			pNODE w1 =  x->children[5]->children[0]->children[0];
			pNODE w2 =  x->children[5]->children[0]->children[2];
			
			//获得首字母
			char* ch1 = w1->children[0]->children[0]->name;
			
			//新建两个Conditions结点
			
			pNODE c[2];
			c[0] = NULL ;
			c[1] = NULL ;
			
			ConditionDistribute(x->children[2],c,ch1);
			
			
			//分配到条件
			if(c[0] != NULL)
			{
				pNODE new1 = CreateNode(4,7,0);
				new1->name = "Whole";
				new1->children[0] = CreateNode(5,0,0);
				new1->children[0]->name = "SELECT";
				new1->children[1] = CreateNode(5,0,0);
				new1->children[1]->name = "LB";
				new1->children[2] = c[0];
				new1->children[3] = CreateNode(5,0,0);
				new1->children[3]->name = "RB";
				new1->children[4] = CreateNode(5,0,0);
				new1->children[4]->name = "LP";
				new1->children[5] = w1;
				new1->children[6] = CreateNode(5,0,0);
				new1->children[6]->name = "RP";
				x->children[5]->children[0]->children[0] = new1;
			}
				
			if(c[1] != NULL)
			{
				
				pNODE new2 = CreateNode(4,7,0);
				new2->name = "Whole";
				new2->children[0] = CreateNode(5,0,0);
				new2->children[0]->name = "SELECT";
				new2->children[1] = CreateNode(5,0,0);
				new2->children[1]->name = "LB";
				new2->children[2] = c[1];
				new2->children[3] = CreateNode(5,0,0);
				new2->children[3]->name = "RB";
				new2->children[4] = CreateNode(5,0,0);
				new2->children[4]->name = "LP";
				new2->children[5] = w2;
				new2->children[6] = CreateNode(5,0,0);
				new2->children[6]->name = "RP";
				x->children[5]->children[0]->children[2] = new2;
			}
				
			free(x->children[0]);
			free(x->children[1]);
			free(x->children[3]);
			free(x->children[4]);
			free(x->children[6]);
			free(x);
		}
			
	}
	//选择或者投影
	else
	{
		OptimizeTree(x->children[5],x,5);
	}
}

//==================================================================
//函 数 名:ConditionDistribute
//功能描述:将原本的条件分配
//输入参数:pNODE oldc,旧条件结点
//输入参数:pNODE* c,新结点
//输入参数:char *ch1,用于新结点1的条件
//==================================================================
void ConditionDistribute(pNODE oldc,pNODE* c,char *ch1)
{
	//获得首字母
	char* chold = oldc->children[0]->children[0]->name;
	
	pNODE pold = oldc->children[0];
	pNODE p1 = NULL;
	pNODE p2 = NULL;
	
	pNODE pp1 = NULL,pp2 = NULL;
	

	
	//比对首字母，相同就是一个关系的。这种检测方式并不可靠，但是实验并没有给出如何分类...
	do
	{
		if(*chold == *ch1)
		{
			
			p1 = CreateNode(4,3,0);
			if(*(c+0) == NULL)
			{
				*(c+0) = p1;
			}
			p1->name = "Conditions";
			p1->n_children = 1;
			
			
			if(pp1 == NULL)
				pp1 = p1;
			else
			{
				pp1->n_children = 3;
				pp1->children[2] = p1;
				pp1 = p1;
			}
			p1->children[0] = pold;
			p1->children[1] = CreateNode(5,0,0);
			p1->children[1]->name = "AND";
			p1->children[2] = NULL;
			p1 = NULL;
			
		}
		else
		{
			p2 = CreateNode(4,3,0);
			
			if(c[1] == NULL)
			{
				c[1] = p2;
			}
			p2->name = "Conditions";
			p2->n_children = 1;
			
			//printf("%s\n",c[1]->name);
			
			if(pp2 == NULL)
				pp2 = p2;
			else
			{
				pp2->n_children = 3;
				pp2->children[2] = p2;
				pp2 = p2;
			}
			p2->children[0] = pold;
			p2->children[1] = CreateNode(5,0,0);
			p2->children[1]->name = "AND";
			p2->children[2] = NULL;
			p2 = NULL;
		}
		//还有后续条件
		if(oldc->n_children == 3)
		{
			pNODE pfree = oldc;
			oldc = oldc->children[2];
			pold = oldc->children[0];
			chold = pold->children[0]->name;
			free(pfree);
			continue;
		}
		else
			break;
	}while(1);
}

//==================================================================
//函 数 名:ProjectionOptimizeTree
//功能描述:Projection优化树，将先连接后选择改为先选择后连接
//输入参数:pNODE x,Whole结点
//输入参数:pNODE parent,Whole的父结点
//输入参数:int n,Whole是其父结点的第几个子树
//==================================================================
void ProjectionOptimizeTree(pNODE x, pNODE parent,int n)
{
	//查看内层语句
	//内层非选择或者投影
	if(x->children[5]->n_children == 1)
	{
		//内层包含连接
		if(x->children[5]->children[0]->n_children == 3)
		{
			parent->children[n] = x->children[5];
			pNODE w1 =  x->children[5]->children[0]->children[0];
			pNODE w2 =  x->children[5]->children[0]->children[2];
			
			//获得首字母
			char* ch1 = w1->children[0]->children[0]->name;
			
			pNODE c[2];
			c[0] = NULL;
			c[1] = NULL;
			
			AttributeDistribute(x->children[2],c,ch1);
			//分配到条件
			if(c[0] != NULL)
			{
				pNODE new1 = CreateNode(4,7,0);
					new1->name = "Whole";
				new1->children[0] = CreateNode(5,0,0);
				new1->children[0]->name = "PROJECTION";
				new1->children[1] = CreateNode(5,0,0);
				new1->children[1]->name = "LB";
				new1->children[2] = c[0];
				new1->children[3] = CreateNode(5,0,0);
				new1->children[3]->name = "RB";
				new1->children[4] = CreateNode(5,0,0);
				new1->children[4]->name = "LP";
				new1->children[5] = w1;
				new1->children[6] = CreateNode(5,0,0);
				new1->children[6]->name = "RP";
				x->children[5]->children[0]->children[0] = new1;
			}
				
			if(c[1] != NULL)
			{
				pNODE new2 = CreateNode(4,7,0);
				new2->name = "Whole";
				new2->children[0] = CreateNode(5,0,0);
				new2->children[0]->name = "PROJECTION";
				new2->children[1] = CreateNode(5,0,0);
				new2->children[1]->name = "LB";
				new2->children[2] = c[1];
				new2->children[3] = CreateNode(5,0,0);
				new2->children[3]->name = "RB";
				new2->children[4] = CreateNode(5,0,0);
				new2->children[4]->name = "LP";
				new2->children[5] = w2;
				new2->children[6] = CreateNode(5,0,0);
				new2->children[6]->name = "RP";
				x->children[5]->children[0]->children[2] = new2;
			}
				
			free(x->children[0]);
			free(x->children[1]);
			free(x->children[3]);
			free(x->children[4]);
			free(x->children[6]);
			free(x);
		}
			
	}
	//选择或者投影
	else
	{
		OptimizeTree(x->children[5],x,5);
	}
}

//==================================================================
//函 数 名:AttributeDistribute
//功能描述:将原本的条件分配
//输入参数:pNODE oldc,旧Attributes结点
//输入参数:pNODE* c,新结点
//输入参数:char *ch1,用于新结点1的条件
//==================================================================
void AttributeDistribute(pNODE oldc,pNODE* c,char *ch1)
{
	//获得首字母
	char* chold = oldc->children[0]->name;
	
	pNODE pold = oldc->children[0];
	pNODE p1 = NULL;
	pNODE p2 = NULL;
	
	pNODE pp1 = NULL,pp2 = NULL;
	
	//比对首字母，相同就是一个关系的
	do
	{
		if(*chold == *ch1)
		{
			p1 = CreateNode(4,3,0);
			if(c[0] == NULL)
			{
				c[0] = p1;
			}
			p1->name = "Attributes";
			p1->n_children = 1;
			
			
			if(pp1 == NULL)
				pp1 = p1;
			else
			{
				pp1->n_children = 3;
				pp1->children[2] = p1;
				pp1 = p1;
			}
			p1->children[0] = pold;
			p1->children[1] = CreateNode(5,0,0);
			p1->children[1]->name = "COMMA";
			p1->children[2] = NULL;
			p1 = NULL;
		}
		else
		{
			p2 = CreateNode(4,3,0);
			if(c[1] == NULL)
			{
				c[1] = p2;
			}
			p2->name = "Attributes";
			p2->n_children = 1;
			
			
			if(pp2 == NULL)
				pp2 = p2;
			else
			{
				pp2->n_children = 3;
				pp2->children[2] = p2;
				pp2 = p2;
			}
			p2->children[0] = pold;
			p2->children[1] = CreateNode(5,0,0);
			p2->children[1]->name = "COMMA";
			p2->children[2] = NULL;
			p2 = NULL;
		}
		//还有后续
		if(oldc->n_children == 3)
		{
			pNODE pfree = oldc;
			oldc = oldc->children[2];
			pold = oldc->children[0];
			chold = pold->name;
			free(pfree);
			continue;
		}
		else
			break;
	}while(1);
}

//==================================================================
//函 数 名:optimize
//功能描述:调用OptimizeTree
//==================================================================
void optimize(){
	OptimizeTree(HEAD_NODE->children[0],HEAD_NODE,0);
}
