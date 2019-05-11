(* Ocamllex scanner for MicroC *)

{ open Parser }

let digit = ['0' - '9']
let digits = digit+

rule token = parse
  [' ' '\t' '\r' '\n'] { token lexbuf } (* Whitespace *)
| "/*"     { comment lexbuf }           (* Comments *)
| '('      { LPAREN }
| ')'      { RPAREN }
| '['      { LBRACK }
| ']'      { RBRACK }
| '{'      { LBRACE }
| '}'      { RBRACE }
| ';'      { SEMI   }
| ':'      { COLON  }
| ','      { COMMA  }
| '+'      { PLUS   }
| '-'      { MINUS  }
| '*'      { TIMES  }
| '/'      { DIVIDE }
| '='      { ASSIGN }
| '%'      { MOD    }
| "+="     { ADDASN }
| "-="     { MINASN }
| "*="     { TIMASN } 
| "/="     { DIVASN }
| "=="     { EQ }
| "!="     { NEQ }
| '<'      { LT }
| "<="     { LEQ }
| ">"      { GT }
| ">="     { GEQ }
| "&&"     { AND }
| "||"     { OR }
| "!"      { NOT }
| "|"	   { UNION }
| "&"	   { INTERSECT }
| "if"     { IF }
| "else"   { ELSE }
| "for"    { FOR }
| "while"  { WHILE }
| "return" { RETURN }
| "true"   { BLIT(true)  }
| "false"  { BLIT(false) }

| "int"    { INT }
| "char"   { CHAR }
| "bool"   { BOOL }
| "float"  { FLOAT }
| "string" { STR }
| "map"    { MAP } 
| "void"   { VOID }
| "map"    { MAP }
| "graph"  { GRAPH }
| "list"   { LIST  }
| "{{"     { LGRAPH }
| "}}"     { RGRAPH }
| "--"     { UNIARR }
| "->"     { DIRARR }
| "~>"     { DELEDGE }
| "~"      { DELNODE } 
| ".get_edges"     { GRAPH_EDGES }
| ".get_neighbors" { GRAPH_NODES }
| ".get_all_nodes" { GRAPH_ALL_VERTICES }

|"{[" 	   			{ LMAP }
|"]}" 	   			{ RMAP }
|".put"    			{ MAP_PUT }
|".get"    			{ MAP_GET }
|".containsKey" 	{ MAP_CONTAINS_KEY }
|".containsValue" 	{ MAP_CONTAINS_VALUE }
|".removeNode" 		{ MAP_REMOVE_NODE }
|".isEqual"			{ MAP_IS_EQUAL }

|".len"		{ LIST_SIZE }
|".at"         { LIST_GET  }
|".set"        { LIST_SET  }
|".add_head"   { LIST_ADD_H}
|".remove_head"  { LIST_RM_H   }   
|".add_tail"    { LIST_ADD_T   }

| digits as lxm { LITERAL(int_of_string lxm) }
| digits '.'  digit* ( ['e' 'E'] ['+' '-']? digits )? as lxm { FLIT(lxm) }
| ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']*     as lxm { ID(lxm) }
| '"' (([' '-'!' '#'-'[' ']'-'~'])* as s) '"' { STRLIT(s) }
| eof { EOF }
| _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }

and comment = parse
  "*/" { token lexbuf }
| _    { comment lexbuf }
