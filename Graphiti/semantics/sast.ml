(* Semantically-checked Abstract Syntax Tree and functions for printing it *)

open Ast

type sexpr = typ * sx
and sx =
    SLiteral of int
  | SFliteral of string
  | SBoolLit of bool
  | SCharLit of char
  | SStrLit of string
  | SListLit of sexpr list 
  | SMapLit of (sexpr * sexpr) list 
  | SGraphLit of sexpr  list
  | SGraphMod of string * (sexpr list)
  | SId of string
  | SBinop of sexpr * op * sexpr
  | SUnop of uop * sexpr
  | SAssign of string * sexpr
  | SGraphEdges of sexpr * sexpr
  | SGraphNodes of sexpr * sexpr
  | SGraphAllNodes of sexpr
  | SGraphAll of sexpr
  | SGraphAddVertex of sexpr
  | SGraphAddEdge of sexpr * sexpr 
  | SGraphAddWedge of sexpr * sexpr * sexpr
  | SGraphDelVertex of sexpr
  | SGraphDelEdge of sexpr * sexpr
  | SMapPut of sexpr * sexpr * sexpr 
  | SMapGet of sexpr * sexpr
  | SMapContainsKey of sexpr * sexpr 
  | SMapContainsValue of sexpr * sexpr
  | SListSize of sexpr
  | SListGet of sexpr * sexpr
  | SListSet of sexpr * sexpr * sexpr
  | SList_Add_Head of sexpr * sexpr
  | SList_Rm_Head of sexpr
  | SList_Add_Tail of sexpr * sexpr
  | SOpAssign of string * op * sexpr
  | SMapRemoveNode of sexpr * sexpr
  | SMapIsEqual of sexpr * sexpr
  | SCall of string * sexpr list
  | SNoexpr

type sstmt =
    SBlock of sstmt list
  | SExpr of sexpr
  | SReturn of sexpr
  | SIf of sexpr * sstmt * sstmt
  | SWhile of sexpr * sstmt

type sfunc_decl = {
    styp : typ;
    sfname : string;
    sformals : bind list;
    slocals : bind list;
    sbody : sstmt list;
  }

type sprogram = bind list * sfunc_decl list

(* Pretty-printing functions *)
let rec string_of_sexpr (t, e) =
        
  "(" ^ string_of_typ t ^ " : " ^ (match e with
    SLiteral(l) -> string_of_int l
  | SBoolLit(true) -> "true"
  | SBoolLit(false) -> "false"
  | SFliteral(l) -> l
  | SCharLit(l) -> Char.escaped l
  | SMapLit(l) -> "{[" ^ String.concat "," (List.map (fun(k, v) -> string_of_sexpr k ^ ":" ^ string_of_sexpr v) l ) ^ "]}"
  | SMapPut(m, k, v) -> string_of_sexpr m ^ ".put(" ^ string_of_sexpr k ^ "," ^ string_of_sexpr v ^ ")"
  | SMapGet(m, k) -> string_of_sexpr m ^ ".get(" ^ string_of_sexpr k ^ ")"
  | SMapContainsKey(m, k) -> string_of_sexpr m ^ ".containsKey(" ^ string_of_sexpr k ^ ")"
  | SMapContainsValue(m, v) -> string_of_sexpr m ^ ".containsValue(" ^ string_of_sexpr v ^ ")"
  | SMapRemoveNode(m, k) -> string_of_sexpr m ^ ".removeNode(" ^ string_of_sexpr k ^ ")"
  | SMapIsEqual(m1, m2) -> string_of_sexpr m1 ^ ".isEqual(" ^ string_of_sexpr m2 ^ ")"
  | SListLit(l) -> "[" ^ String.concat "," (List.map string_of_sexpr l) ^ "]"
  | SListSize(l) -> string_of_sexpr l ^ ".len"
  | SListGet(l, idx) -> string_of_sexpr l ^ ".at(" ^ string_of_sexpr idx ^ ")"
  | SListSet(l, idx, e) -> string_of_sexpr l ^ ".set(" ^ string_of_sexpr idx ^ "," ^ string_of_sexpr e ^ ")"
  | SList_Add_Head(l, e) -> string_of_sexpr l ^ ".add_head(" ^ string_of_sexpr e^ ")"
  | SList_Rm_Head(l) -> string_of_sexpr l ^ ".remove_head()"
  | SList_Add_Tail(l, e) -> string_of_sexpr l ^ ".add_tail(" ^ string_of_sexpr e ^ ")"
  | SGraphMod(g, l) -> g ^ "{{" ^ String.concat "," (List.map (fun(e) -> string_of_sexpr e) l) ^ "}}"
  | SGraphEdges(g, e) -> string_of_sexpr g ^ ".get_edges(" ^ string_of_sexpr e^ ")"
  | SGraphNodes(g, n) -> string_of_sexpr g ^ ".get_neighbors(" ^ string_of_sexpr n ^ ")"
  | SGraphAllNodes(g) -> string_of_sexpr g ^ ".get_all_nodes()"
  | SGraphAll(g) -> string_of_sexpr g ^ ".get_all_nodes()"
  | SStrLit(l) -> l
  | SId(s) -> s
  | SBinop(e1, o, e2) ->
      string_of_sexpr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_sexpr e2
  | SUnop(o, e) -> string_of_uop o ^ string_of_sexpr e
  | SAssign(v, e) -> v ^ " = " ^ string_of_sexpr e
  | SOpAssign(v,o,e) -> v ^ " " ^ string_of_op o ^ " " ^ string_of_sexpr e
  | SCall(f, el) ->
      f ^ "(" ^ String.concat ", " (List.map string_of_sexpr el) ^ ")"
  | SNoexpr -> ""
				  ) ^ ")"

let rec string_of_sstmt = function
    SBlock(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_sstmt stmts) ^ "}\n"
  | SExpr(expr) -> string_of_sexpr expr ^ ";\n";
  | SReturn(expr) -> "return " ^ string_of_sexpr expr ^ ";\n";
  | SIf(e, s, SBlock([])) ->
      "if (" ^ string_of_sexpr e ^ ")\n" ^ string_of_sstmt s
  | SIf(e, s1, s2) ->  "if (" ^ string_of_sexpr e ^ ")\n" ^
      string_of_sstmt s1 ^ "else\n" ^ string_of_sstmt s2
  | SWhile(e, s) -> "while (" ^ string_of_sexpr e ^ ") " ^ string_of_sstmt s

let string_of_sfdecl fdecl =
  string_of_typ fdecl.styp ^ " " ^
  fdecl.sfname ^ "(" ^ String.concat ", " (List.map snd fdecl.sformals) ^
  ")\n{\n" ^
  String.concat "" (List.map string_of_vdecl fdecl.slocals) ^
  String.concat "" (List.map string_of_sstmt fdecl.sbody) ^
  "}\n"

let string_of_sprogram (vars, funcs) =
  String.concat "" (List.map string_of_vdecl vars) ^ "\n" ^
  String.concat "\n" (List.map string_of_sfdecl funcs)
