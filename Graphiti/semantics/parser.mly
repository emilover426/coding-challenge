/* Ocamlyacc parser for MicroC */

%{
open Ast
%}

/*precedence not assigned here*/
%token SEMI LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE COMMA
%token MAP_PUT MAP_GET MAP_CONTAINS_KEY MAP_CONTAINS_VALUE MAP_REMOVE_NODE MAP_IS_EQUAL
%token GRAPH_EDGES GRAPH_NODES GRAPH_ALL_VERTICES
%token NOT EQ NEQ LT LEQ GT GEQ AND OR UNION INTERSECT
%token MOD PLUS MINUS TIMES DIVIDE ASSIGN ADDASN MINASN TIMASN DIVASN
%token RETURN IF ELSE FOR WHILE INT CHAR BOOL FLOAT STR VOID GRAPH MAP
%token LGRAPH RGRAPH UNIARR DIRARR DELEDGE DELNODE
%token LIST LIST_SIZE LIST_GET LIST_SET LIST_ADD_H LIST_RM_H LIST_ADD_T /* LIST_RM_T */
%token COLON LMAP RMAP 
/*
%token STR_SIZE
*/
%token <int> LITERAL
%token <bool> BLIT
%token <string> ID FLIT
%token <char> CHARLIT
%token <string> STRLIT
%token EOF

%start program
%type <Ast.program> program

%nonassoc NOELSE
%nonassoc ELSE
%nonassoc COLON
%right ASSIGN ADDASN MINASN TIMASN DIVASN 
/*
%left STRSIZE
*/
%left OR
%left AND
%right EQ NEQ
%left LT GT LEQ GEQ UNION INTERSECT
%left PLUS MINUS
%left TIMES DIVIDE MOD
%right NOT NEG
%right LIST_SIZE LIST_GET LIST_SET LIST_ADD_H LIST_RM_H LIST_ADD_T /*LIST_RM_T*/
%right  MAP_PUT MAP_GET MAP_CONTAINS_KEY MAP_CONTAINS_VALUE MAP_REMOVE_NODE MAP_IS_EQUAL GRAPH_EDGES GRAPH_NODES
%right FOR
%%

program:
  decls EOF { $1 }

decls:
   /* nothing */ { ([], [])               }
 | decls vdecl { (($2 :: fst $1), snd $1) }
 | decls fdecl { (fst $1, ($2 :: snd $1)) }

fdecl:
   typ ID LPAREN formals_opt RPAREN LBRACE vdecl_list stmt_list RBRACE
     { { typ = $1;
     fname = $2;
     formals = List.rev $4;
     locals = List.rev $7;
     body = List.rev $8 } }

formals_opt:
    /* nothing */ { [] }
  | formal_list   { $1 }

formal_list:
    typ ID		     { [($1, $2)] }
  | formal_list COMMA typ ID { ($3, $4) :: $1 }

typ:
    INT    			{ Int    }
  | CHAR   			{ Char   }
  | BOOL   			{ Bool   }
  | FLOAT  			{ Float  }
  | STR    			{ String }
  | VOID   			{ Void   }
  | MAP                         { Map    } 
  | GRAPH                       { Graph  }
  | LIST LT typ GT              { List($3) }

vdecl_list:
    /* nothing */    { [(Int, "__i");
                        (List(Map), "__nodes");
                        (Int, "__l")]}
  | vdecl_list vdecl { $2 :: $1 }

vdecl:
    typ ID SEMI { ($1, $2) }

stmt_list:
    /* nothing */  { [] }
  | stmt_list stmt { $2 :: $1 }

stmt:
    expr SEMI                               { Expr $1               }
  | RETURN expr_opt SEMI                    { Return $2             }
  | LBRACE stmt_list RBRACE                 { Block(List.rev $2)    }
  | IF LPAREN expr RPAREN stmt %prec NOELSE { If($3, $5, Block([])) }
  | IF LPAREN expr RPAREN stmt ELSE stmt    { If($3, $5, $7)        }
  | WHILE LPAREN expr RPAREN stmt           { While($3, $5)         }

expr_opt:
    /* nothing */ { Noexpr }
  | expr          { $1 }

expr:
    LITERAL                     { Literal($1)            }
  | FLIT                        { Fliteral($1)           }
  | BLIT                        { BoolLit($1)            }
  | CHARLIT                     { CharLit($1)            }
  | ID                          { Id($1)                 }
  | STRLIT                      { StrLit($1)             }
  | LBRACK args_opt RBRACK      { ListLit($2)   	 	 }
  | LMAP map_lit_element RMAP   { MapLit($2)		 	 }
  | LGRAPH graph_i_opt RGRAPH     { GraphLit($2)         }
  | ID LGRAPH graph_m_opt RGRAPH  { GraphMod($1, $3)     }
  | expr PLUS   expr            { Binop($1, Add,   $3)   }
  | expr MINUS  expr            { Binop($1, Sub,   $3)   }
  | expr TIMES  expr            { Binop($1, Mult,  $3)   }
  | expr DIVIDE expr            { Binop($1, Div,   $3)   }
  | expr MOD    expr            { Binop($1, Mod,   $3)   }
  | expr EQ     expr            { Binop($1, Equal, $3)   }
  | expr NEQ    expr            { Binop($1, Neq,   $3)   }
  | expr LT     expr            { Binop($1, Less,  $3)   }
  | expr LEQ    expr            { Binop($1, Leq,   $3)   }
  | expr GT     expr            { Binop($1, Greater, $3) }
  | expr GEQ    expr            { Binop($1, Geq,   $3)   }
  | expr AND    expr            { Binop($1, And,   $3)   }
  | expr OR     expr            { Binop($1, Or,    $3)   }
  | expr UNION  expr            { Binop($1, Union, $3) }
  | expr INTERSECT expr         { Binop($1, Intersect, $3) }
  | MINUS expr %prec NOT       { Unop(Neg, $2)           }
  | NOT expr                   { Unop(Not, $2)          }
  | ID ASSIGN expr             { Assign($1, $3)         }
  | ID ADDASN expr             { OpAssign($1, Add, $3) }
  | ID MINASN expr             { OpAssign($1, Sub, $3) }
  | ID TIMASN expr             { OpAssign($1, Mult, $3) }
  | ID DIVASN expr             { OpAssign($1, Div, $3) }
  | ID LPAREN args_opt RPAREN  { Call($1, $3)           }
  | LPAREN expr RPAREN           { $2                   }

  | expr GRAPH_EDGES LPAREN expr RPAREN  		{ GraphEdges($1, $4) }
  | expr GRAPH_ALL_VERTICES LPAREN RPAREN  		{ GraphAll($1)  }
  | expr GRAPH_NODES LPAREN expr RPAREN  		{ GraphNodes($1, $4) }
  | expr MAP_PUT LPAREN expr COMMA expr RPAREN 	{ MapPut($1, $4, $6) 		}
  | expr MAP_GET LPAREN expr RPAREN 			{ MapGet($1, $4) 			} 
  | expr MAP_CONTAINS_KEY LPAREN expr RPAREN 	{ MapContainsKey($1, $4) 	}
  | expr MAP_CONTAINS_VALUE LPAREN expr RPAREN 	{ MapContainsValue ($1, $4) }   
  | expr MAP_REMOVE_NODE LPAREN expr RPAREN 	{ MapRemoveNode ($1, $4) 	}
  | expr MAP_IS_EQUAL LPAREN expr RPAREN 		{ MapIsEqual($1, $4) 		}
  | expr LIST_SIZE LPAREN RPAREN                { ListSize($1)          }
  | expr LIST_GET LPAREN expr RPAREN            { ListGet($1, $4)       }
  | expr LIST_SET LPAREN expr COMMA expr RPAREN { ListSet($1, $4, $6)   }
  | expr LIST_ADD_H LPAREN expr RPAREN          { List_Add_Head($1, $4) }
  | expr LIST_RM_H LPAREN RPAREN                { List_Rm_Head($1)      }
  | expr LIST_ADD_T LPAREN expr RPAREN          { List_Add_Tail($1, $4) }

/* Used for Graphs */
graph_i_opt:
      /* nothing */    { [] }
    | graph_i_list     { $1 }

graph_i_list:
      graph_i_expr                         { $1 }
    | graph_i_list COMMA graph_i_expr      { $1 @ $3 }

graph_i_expr:
    /*(fromId, weight, toId)*/
      expr                                 { [GraphAddVertex($1)] } 
    | expr UNIARR expr                     { [GraphAddEdge($1, $3); GraphAddEdge($3, $1)] }
    | expr DIRARR expr                     { [GraphAddEdge($1, $3)] }
    | expr LBRACK expr RBRACK UNIARR expr  { [GraphAddWedge($1, $3, $6); GraphAddWedge($6, $3, $1)] }
    | expr LBRACK expr RBRACK DIRARR expr  { [GraphAddWedge($1, $3, $6)] }

graph_m_opt:
                     { [] }
    | graph_m_list   { $1 }

graph_m_list:
      graph_m_expr                     { $1 }
    | graph_m_list COMMA graph_m_expr  { $1 @ $3 }
    
graph_m_expr:
      expr                                   { [GraphAddVertex($1)] } 
    | expr UNIARR expr                       { [GraphAddEdge($1, $3); GraphAddEdge($3, $1)] }
    | expr DIRARR expr                       { [GraphAddEdge($1, $3)] }
    | expr LBRACK expr RBRACK UNIARR expr    { [GraphAddWedge($1, $3, $6); GraphAddWedge($6, $3, $1)] }
    | expr LBRACK expr RBRACK DIRARR expr    { [GraphAddWedge($1, $3, $6)] } 
    | DELNODE expr                           { [GraphDelVertex($2)] }
    | expr DELEDGE expr                      { [GraphDelEdge($1, $3)] }

/* Used for Maps */
map_lit_element:
	/* nothing */	{ [] }
	|  map_list 	{ List.rev $1 }

map_list:
	  map_entry					{ $1 }
	| map_list COMMA map_entry  { $1 @ $3 }

map_entry:
	expr COLON expr 		{ [($1, $3)] }

/* Used for Lists */
args_opt:
    /* nothing */ { [] }
  | args_list  { List.rev $1 }

args_list:
    expr                    { [$1] }
  | args_list COMMA expr 	{ $3 :: $1 }
