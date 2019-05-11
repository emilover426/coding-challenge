(* Semantic checking for the Graphiti compiler *)
(* Authors:
	Lists: Andrew Quijano
	Graphs: Sydney Lee & Michal Porubcin
	Maps: Emily Hao & Alice Thum
*)


open Ast
open Sast

module StringMap = Map.Make(String)

(* Semantic checking of the AST. Returns an SAST if successful,
	 throws an exception if something is wrong.

	 Check each global variable, then check each function *)
let get_type(t, _) = t
let first_element (myList) = match myList with
 [] -> Void
| first_e1 :: _ -> get_type(first_e1)

(* Use this function to check if the sexpr is acceptable element in list*)
let valid_element_type = function
       	(Void,_) -> raise(Failure("Invalid List<Void>!"))
	| _ -> ()
let check_type (ex, ty) = 
	if ex = ty then () 
	else raise (Failure ("Mismatch desired expr and type!"))

let check (globals, functions) =

	(* Verify a list of bindings has no void types*)
	let check_binds (kind : string) (binds : bind list) =
		List.iter (function
	(Void, b) -> raise (Failure ("illegal void " ^ kind ^ " " ^ b))
			| _ -> ()) binds;
		
			(* Verify a list of bindings has no duplicate names*)
			let rec dups = function
				[] -> ()
			|	((_,n1) :: (_,n2) :: _) when n1 = n2 ->
		raise (Failure ("duplicate " ^ kind ^ " " ^ n1))
			| _ :: t -> dups t
		in dups (List.sort (fun (_,a) (_,b) -> compare a b) binds)
	in

  let check_list_binds (binds : sexpr list) =
      List.iter valid_element_type binds;

      let rec same_type = function
          [] -> ()
      | ((t1,_) :: (t2,_) :: _) when t1 != t2 ->
              raise (Failure ("List elements must be all same type!"))
      | _ :: t -> same_type t
      in same_type (List.sort (fun (a,_) (b,_) -> compare a b) binds);
      
      (*first_element(binds)*)
  in

	(**** Check global variables ****)

	check_binds "global" globals;

	(**** Check functions ****)

	(* Collect function declarations for built-in functions: no bodies *)
	let built_in_decls = 
		let add_bind map (name, ty) = StringMap.add name {
			typ = Void;
			fname = name; 
			formals = [(ty, "x")];
			locals = []; 
			body = [] } map
		in List.fold_left add_bind StringMap.empty [("printi", Int);
													("printb", Bool);
													("printf", Float);
													("printbig", Int);
													("print", String);
													("printm", Map);
													("printl", List(String));
                                                    ("printl", List(Int));
                                                    ("printg", Graph)]
		in

	(* Add function name to symbol table *)
	let add_func map fd = 
		let built_in_err = "function " ^ fd.fname ^ " may not be defined"
		and dup_err = "duplicate function " ^ fd.fname
		and make_err er = raise (Failure er)
		and n = fd.fname (* Name of the function *)
		in match fd with (* No duplicate functions or redefinitions of built-ins *)
				 _ when StringMap.mem n built_in_decls -> make_err built_in_err
			 | _ when StringMap.mem n map -> make_err dup_err  
			 | _ ->  StringMap.add n fd map 
	in

	(* Collect all function names into one symbol table *)
	let function_decls = List.fold_left add_func built_in_decls functions
	in
	
	(* Return a function from our symbol table *)
	let find_func s = 
		try StringMap.find s function_decls
		with Not_found -> raise (Failure ("unrecognized function " ^ s))
	in

	let _ = find_func "main" in (* Ensure "main" is defined *)

	let check_function func =
		(* Make sure no formals or locals are void or duplicates *)
		check_binds "formal" func.formals;
		check_binds "local" func.locals;

		(* Raise an exception if the given rvalue type cannot be assigned to
			 the given lvalue type *)
		let check_assign lvaluet rvaluet err =
			 if lvaluet = rvaluet then lvaluet else raise (Failure err)
		in   

		(* Build local symbol table of variables for this function *)
		let symbols = List.fold_left (fun m (ty, name) -> StringMap.add name ty m)
									StringMap.empty (globals @ func.formals @ func.locals )
		in

		(* Return a variable from our local symbol table *)
		let type_of_identifier s =
			try StringMap.find s symbols
			with Not_found -> raise (Failure ("undeclared identifier " ^ s))
		in

		(* Return a semantically-checked expression, i.e., with a type *)
			 
		let rec expr =
			let check_list m =
				let (t, _) = expr m in
				match t with
				 List(_) -> ()
				|_ -> raise (Failure ("Expected List<E> instead of " ^ string_of_typ t)) in
			let check_list_type m =
				let (t, _) = expr m in
				match t with
				 List(ty) -> ty
				|_ -> raise (Failure ("List must be of type list instead of " ^ string_of_typ t)) in
			let check_map m =
				let (t, mc) = expr m in
				match t with
				 Map -> (t, mc)
				|_ -> raise (Failure ("Map must be of type map instead of " ^ string_of_typ t)) in
			let check_key k = 
				let (t, kc) = expr k in
				match t with
				 String -> (t, kc)
				|_ -> raise (Failure ("Key must be type string instead of " ^ string_of_typ t)) in
			let check_value v =
				let (t, vc) = expr v in
					match t with
		   		 String -> (t, vc)
				|_ -> raise (Failure ("Value must be a string type instead of " ^ string_of_typ t)) in
			let check_node n =
				let (t, n') = expr n in
				match t with
				 Map | Void -> (t, n')
				| _ -> raise (Failure ("Node must be map type instead of " ^ string_of_typ t)) in
			let check_weight w =
				let (t, n') = expr w in
				match t with
				 String | Void -> (t, n')
				| _ -> raise (Failure ("Weight must be a string type instead of " ^ string_of_typ t)) in
			let check_graph g =
        			let (t, g') = expr g in
        			match t with
          			Graph -> (t, g')
        			| _ -> raise (Failure ("Graph must be graph type instead of " ^ string_of_typ t)) in 

			function
			  Literal  l -> (Int, SLiteral l)
			| Fliteral l -> (Float, SFliteral l)
			| BoolLit l  -> (Bool, SBoolLit l)
			| CharLit l -> (Char, SCharLit l)
			| StrLit l -> (String, SStrLit l)
			| Noexpr     -> (Void, SNoexpr)      
			| Id s       -> (type_of_identifier s, SId s)
	    	| ListLit l  -> check_list_binds (List.map expr l);
            	(List(first_element(List.map expr l)), SListLit (List.map expr l))
			| MapLit l -> 
				let m = List.map (fun (k, v) ->
				let k' = check_key k in
				let v' = check_value v in 
				(k', v')) l in (Map, SMapLit m)
			| GraphLit l ->
            	let m = List.map (fun (e) -> expr e) l
            	in (Graph, SGraphLit (m))
			| GraphMod (g, l) ->
            	let m = List.map (fun (e) -> expr e) l
            	in (Graph, SGraphMod (g, m))
            | GraphEdges(g, n) ->
          		let g' = check_graph g
          		and n' = check_node n in
          		(Graph, SGraphEdges(g', n'))
       		| GraphNodes(g, n) ->
          		let g' = check_graph g
          		and n' = check_node n in
				(Graph, SGraphNodes(g', n'))
            | GraphAllNodes(g) ->
            	let g' = check_graph g in
            	(Graph, SGraphAllNodes(g'))
            | GraphAll(g) ->
            	let g' = check_graph g in
            	(Graph, SGraphAll(g'))
            | GraphAddVertex(n) ->
            	let n' = check_node n in
            	(Graph, SGraphAddVertex(n'))
            | GraphAddEdge(n1, n2) ->
            	let n1' = check_node n1
            	and n2' = check_node n2 in
            	(Graph, SGraphAddEdge(n1', n2'))
            | GraphAddWedge(n1, w, n2) ->
            	let n1' = check_node n1
            	and w' = check_weight w
            	and n2' = check_node n2 in
            	(Graph, SGraphAddWedge(n1', w', n2'))
            | GraphDelVertex(n) ->
            	let n' = check_node n in
            	(Graph, SGraphDelVertex(n'))
            | GraphDelEdge(n1, n2) ->
            	let n1' = check_node n1
            	and n2' = check_node n2 in
            	(Graph, SGraphDelEdge(n1', n2'))
            | Assign(var, e) as ex -> 
					let lt = type_of_identifier var
					and (rt, e') = expr e in (* recursive *)
					let err = "illegal assignment " ^ string_of_typ lt ^ " = " ^ 
						string_of_typ rt ^ " in " ^ string_of_expr ex
					in (check_assign lt rt err, SAssign(var, (rt, e')))
			(* Add all our operators BELOW *)
			| Unop(op, e) as ex -> 
					let (t, e') = expr e in
					let ty = match op with
						Neg when t = Int || t = Float -> t
					| Not when t = Bool -> Bool
					| _ -> raise (Failure ("illegal unary operator " ^ string_of_uop op ^ string_of_typ t ^ " in " ^ string_of_expr ex))
					in (ty, SUnop(op, (t, e')))
			| Binop(e1, op, e2) as e -> 
					let (t1, e1') = expr e1 
					and (t2, e2') = expr e2 in
					(* All binary operators require operands of the same type *)
					let same = t1 = t2 in
					(* Determine expression type based on operator and operand types *)
					let ty = match op with
						Add | Sub | Mult | Div | Mod when same && t1 = Int   -> Int
					| Add when same && t1 = List(Int) -> List(Int)
                                        | Add when same && t1 = Graph -> Graph
					| Add when same && t1 = List(String) -> List(String)
					| Add when same && t1 = List(Map) -> List(Map)
					| Add when same && t1 = List(Float) -> List(Float)
                                        | Add | Sub | Mult | Div when same && t1 = Float -> Float
                                        | Add                    when same && t1 = String-> String
                                        | Equal | Neq            when same               -> Bool
					| Less | Leq | Greater | Geq
					when same && (t1 = Int || t1 = Float) -> Bool
					| And | Or when same && t1 = Bool -> Bool
                                        | Union | Intersect when same && t1 = Graph -> Graph
					| _ -> raise (
				Failure ("illegal binary operator " ^ string_of_typ t1 ^ " " ^ string_of_op op ^ " " ^
								 string_of_typ t2 ^ " in " ^ string_of_expr e))
					in (ty, SBinop((t1, e1'), op, (t2, e2')))
			| OpAssign(var, op, e) as ex -> 
					let lt = type_of_identifier var
					and (rt, e2') = expr e in 
					let err = "illegal op-assignment " ^ string_of_typ lt ^ " " ^ string_of_op op ^ " " ^ 
						string_of_typ rt ^ " in " ^ string_of_expr ex
					in (check_assign lt rt err, SOpAssign(var, op, (rt, e2')))
			
			| Call(fname, args) as call -> 
					let fd = find_func fname in
					let param_length = List.length fd.formals in
					if List.length args != param_length then
						raise (Failure ("expecting " ^ string_of_int param_length ^ 
														" arguments in " ^ string_of_expr call))
					else let check_call (ft, _) e = 
						let (et, e') = expr e in 
						let err = "illegal argument found " ^ string_of_typ et ^
							" expected " ^ string_of_typ ft ^ " in " ^ string_of_expr e
						in (check_assign ft et err, e')
					in
					let args' = List.map2 check_call fd.formals args
					in (fd.typ, SCall(fname, args'))
		  	
			(* Map Methods *)
			| MapPut(m, k, v) -> let (a, b, c) = (fun (m, k, v) ->
				let m' = check_map m in
				let k' = check_key k in
				let v' = check_value v in
				(m', k', v')) (m, k, v)  in (Int, SMapPut (a, b, c))
			| MapContainsKey(m, k) -> let (a, b) = (fun (m, k) ->
				let m' = check_map m in
				let k' = check_key k in
				(m', k')) (m, k)  in (Int, SMapContainsKey (a, b))
			| MapContainsValue (m, v) -> let (a, b) = (fun (m, v) ->
				let m' = check_map m in
				let v' = check_value v in
				(m', v')) (m, v)  in (Int, SMapContainsValue (a, b))
			| MapGet(m, k) -> let (a, b) = (fun (m, k) ->
				let m' = check_map m in
				let k' = check_key k in
				(m', k')) (m, k)  in (String, SMapGet(a, b))
			| MapRemoveNode(m, k) -> let (a, b) = (fun (m, k) ->
				let m' = check_map m in
				let k' = check_key k in
				(m', k')) (m, k)  in (Int, SMapRemoveNode (a, b))
		        | MapIsEqual(m1, m2) -> let (a, b) = (fun (m1, m2) ->
				let m1' = check_map m1 in
				let m2' = check_map m2 in
				(m1', m2')) (m1, m2)  in (Int, SMapIsEqual(a, b))
			
			(* List Methods *)
			| ListSize l -> check_list(l);
            	(Int, SListSize (expr l))
      		| ListGet(l, i) -> check_list(l);
				check_type(get_type(expr i), Int);
          		(check_list_type(l), SListGet (expr l, expr i))
      		| ListSet(l, i, e) -> check_list(l);
				check_type(get_type(expr i), Int);
				valid_element_type(expr e);
				(check_list_type(l), SListSet (expr l, expr i, expr e))
      		| List_Add_Head(l, e) -> check_list(l);
				valid_element_type(expr e);
				(Void, SList_Add_Head (expr l, expr e))
      		| List_Rm_Head(l) -> check_list(l);
				(check_list_type(l), SList_Rm_Head (expr l))
     		| List_Add_Tail(l, e) -> check_list(l);
				valid_element_type(expr e);
				(Void, SList_Add_Tail (expr l, expr e))

            in

		let check_bool_expr e = 
			let (t', e') = expr e
			and err = "expected Boolean expression in " ^ string_of_expr e
			in if t' != Bool then raise (Failure err) else (t', e') 
		in

		(* Return a semantically-checked statement i.e. containing sexprs *)
		let rec check_stmt = function
				Expr e -> SExpr (expr e)
			| If(p, b1, b2) -> SIf(check_bool_expr p, check_stmt b1, check_stmt b2)
			| While(p, s) -> SWhile(check_bool_expr p, check_stmt s)
			| Return e -> let (t, e') = expr e in
				if t = func.typ then SReturn (t, e') 
				else raise (
		Failure ("return gives " ^ string_of_typ t ^ " expected " ^
			 string_of_typ func.typ ^ " in " ^ string_of_expr e))
			
			(* A block is correct if each statement is correct and nothing
				 follows any Return statement.  Nested blocks are flattened. *)
			| Block sl -> 
					let rec check_stmt_list = function
							[Return _ as s] -> [check_stmt s]
						| Return _ :: _   -> raise (Failure "nothing may follow a return")
						| Block sl :: ss  -> check_stmt_list (sl @ ss) (* Flatten blocks *)
						| s :: ss         -> check_stmt s :: check_stmt_list ss
						| []              -> []
					in SBlock(check_stmt_list sl)

		in (* body of check_function *)
		{ styp = func.typ;
			sfname = func.fname;
			sformals = func.formals;
			slocals  = func.locals;
			sbody = match check_stmt (Block func.body) with
	SBlock(sl) -> sl
			| _ -> raise (Failure ("internal error: block didn't become a block?"))
		}
	in (globals, List.map check_function functions)
