(* Abstract Syntax Tree and functions for printing it *)

type op = Add | Sub | Mult | Div | Equal | Neq | Less | Leq | Greater | Geq 
        | And | Or | Union | Intersect | Mod

type uop = Neg | Not

type gop = Delnode | Deledge 

type expr =
    Literal of int
  | Fliteral of string
  | BoolLit of bool
  | CharLit of char
  | StrLit of string
  | MapLit of (expr * expr) list 
  | ListLit of expr list 
  | Id of string
  | Binop of expr * op * expr
  | GraphLit of expr list
  | GraphMod of string * (expr list)
  | Unop of uop * expr
  | Assign of string * expr
  | OpAssign of string * op * expr
  | GraphEdges of expr * expr
  | GraphNodes of expr * expr
  | GraphAllNodes of expr
  | GraphAll of expr
  | GraphAddVertex of expr
  | GraphAddEdge of expr * expr
  | GraphAddWedge of expr * expr * expr
  | GraphDelVertex of expr
  | GraphDelEdge of expr * expr
  | MapPut of expr * expr * expr 
  | MapGet of expr * expr 
  | MapContainsKey of expr * expr
  | MapContainsValue of expr * expr 
  | MapRemoveNode of expr * expr
  | MapIsEqual of expr * expr
  | ListSize of expr
  | ListGet of expr * expr
  | ListSet of expr * expr * expr
  | List_Add_Head of expr * expr
  | List_Rm_Head of expr
  | List_Add_Tail of expr * expr
  | Call of string * expr list
  | Noexpr

type typ = 
    Int
  | Bool
  | Char
  | Float
  | String
  | Void
  | Graph
  | Map
  | List of typ 

type bind = typ * string

type stmt =
    Block of stmt list
  | Expr of expr
  | Return of expr
  | If of expr * stmt * stmt
  | While of expr * stmt

type func_decl = {
    typ : typ;
    fname : string;
    formals : bind list;
    locals : bind list;
    body : stmt list;
  }

type program = bind list * func_decl list

(* Pretty-printing functions *)

let string_of_op = function
    Add -> "+"
  | Sub -> "-"
  | Mult -> "*"
  | Div -> "/"
  | Equal -> "=="
  | Neq -> "!="
  | Less -> "<"
  | Leq -> "<="
  | Greater -> ">"
  | Geq -> ">="
  | And -> "&&"
  | Or -> "||"
  | Union -> "|"
  | Intersect -> "&"
  | Mod -> "%"

let string_of_gop = function
    Delnode -> "~"
  | Deledge -> "~>"

let string_of_uop = function
    Neg -> "-"
  | Not -> "!"

let rec string_of_typ = function
    Int -> "int"
  | Bool -> "bool"
  | Float -> "float"
  | Char -> "char"
  | String -> "string"
  | Graph -> "graph" 
  | Void -> "void"
  | Map -> "map"
  | List(l) -> "list" ^ "<" ^ string_of_typ l ^ ">"

let rec string_of_expr =
  function
    Literal(l) -> string_of_int l
  | Fliteral(l) -> l
  | BoolLit(true) -> "true"
  | BoolLit(false) -> "false"
  | CharLit(l) -> Char.escaped l
  | StrLit(l) -> "\"" ^ l ^ "\""
  | ListLit(l) -> "[" ^ String.concat "," (List.map string_of_expr l) ^ "]" 
    | Id(s) -> s
  | GraphLit(l) -> "{{" ^ String.concat "," (List.map (fun(e) -> string_of_expr e) l) ^ "}}"
  | GraphMod(id, l) -> id ^ "{{" ^ String.concat "," (List.map (fun(e) -> string_of_expr e) l) ^ "}}"
  | GraphNodes(id, n) -> string_of_expr id ^ ".get_neighbors(" ^ string_of_expr n ^ ")"
  | GraphEdges(id, e) -> string_of_expr id ^ ".get_edges(" ^ string_of_expr e ^ ")"
  | GraphAllNodes(id) -> string_of_expr id ^ ".get_all_nodes()"
  | GraphAll(id) -> string_of_expr id ^ ".get_all_nodes()"
  | GraphAddVertex(_) -> "FAILED graphaddvertex not implemented"
  | GraphAddEdge(_,_) -> "FAILED graphaddedge not implemented" 
  | GraphAddWedge(_,_,_) -> "FAILED graphaddwedge not implemented"
  | GraphDelVertex(_) -> "FAILED graphdelvertex not implemented"
  | GraphDelEdge(_,_) -> "FAILED graphdeledge not implemented"
  | MapLit(l) -> "{[" ^ String.concat "," (List.map (fun(k, v) -> string_of_expr k ^ ":" ^ string_of_expr v) l) ^ "]}" 
  | MapPut(m, key, value) -> string_of_expr m ^ ".put(" ^ string_of_expr key ^ "," ^ string_of_expr value ^ ")"
  | MapGet(m, key) -> string_of_expr m ^ ".get(" ^ string_of_expr key ^ ")"
  | MapContainsKey(m, key) -> string_of_expr m ^ ".containsKey(" ^ string_of_expr key ^ ")"
  | MapContainsValue(m, value) -> string_of_expr m ^ ".containsValue(" ^ string_of_expr value ^")" 
  | MapRemoveNode(m, key) -> string_of_expr m ^ ".removeNode(" ^ string_of_expr key ^ ")"
  | MapIsEqual(m1, m2) -> string_of_expr m1 ^ ".isEqual(" ^ string_of_expr m2 ^ ")"
  | ListSize(l) -> string_of_expr l ^ ".len"
  | ListGet(l, idx) -> string_of_expr l ^ ".at(" ^ string_of_expr idx ^ ")"
  | ListSet(l, idx, e) -> string_of_expr l ^ ".set(" ^ string_of_expr idx ^ "," ^ string_of_expr e ^ ")"
  | List_Add_Head(l, e) -> string_of_expr l ^ ".add_head(" ^ string_of_expr e^ ")"
  | List_Rm_Head(l) -> string_of_expr l ^ ".remove_head()"
  | List_Add_Tail(l, e) -> string_of_expr l ^ ".add_tail(" ^ string_of_expr e ^ ")"
  | Binop(e1, o, e2) ->
      string_of_expr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_expr e2
  | Unop(o, e) -> string_of_uop o ^ string_of_expr e
  | Assign(v, e) -> v ^ " = " ^ string_of_expr e
  | OpAssign(v, o, e) -> v ^ string_of_op o ^ " " ^ string_of_expr e
  | Call(f, el) ->
      f ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
  | Noexpr -> ""

let rec string_of_stmt = function
    Block(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_stmt stmts) ^ "}\n"
  | Expr(expr) -> string_of_expr expr ^ ";\n";
  | Return(expr) -> "return " ^ string_of_expr expr ^ ";\n";
  | If(e, s, Block([])) -> "if (" ^ string_of_expr e ^ ")\n" ^ string_of_stmt s
  | If(e, s1, s2) ->  "if (" ^ string_of_expr e ^ ")\n" ^
      string_of_stmt s1 ^ "else\n" ^ string_of_stmt s2
  | While(e, s) -> "while (" ^ string_of_expr e ^ ") " ^ string_of_stmt s

let string_of_vdecl (t, id) = string_of_typ t ^ " " ^ id ^ ";\n"

let string_of_fdecl fdecl =
  string_of_typ fdecl.typ ^ " " ^
  fdecl.fname ^ "(" ^ String.concat ", " (List.map snd fdecl.formals) ^
  ")\n{\n" ^
  String.concat "" (List.map string_of_vdecl fdecl.locals) ^
  String.concat "" (List.map string_of_stmt fdecl.body) ^
  "}\n"

let string_of_program (vars, funcs) =
  String.concat "" (List.map string_of_vdecl vars) ^ "\n" ^
  String.concat "\n" (List.map string_of_fdecl funcs)
