(* Code generation: translate takes a semantically checked AST and
produces LLVM IR

LLVM tutorial: Make sure to read the OCaml version of th
e tutorial

http://llvm.org/docs/tutorial/index.html

Detailed documentation on the OCaml LLVM library:

http://llvm.moe/
http://llvm.moe/ocaml/

Authors:
	Lists: Andrew Quijano
	Graphs: Sydney Lee & Michal Porubcin
	Maps: Emily Hao & Alice Thum

*)
module C = Char
module L = Llvm
module A = Ast
open Ast
open Sast

module StringMap = Map.Make(String)

let get_type(t, _) = t
let first_element (myList) = match myList with
 [] -> Void
| first_e1 :: _ -> get_type(first_e1)

let check_list_type m =
	let (t, _) = m in 
	match t with
	 List(ty) -> ty
	|_ -> raise (Failure ("List must be of type list in ListLit (CODEGEN): " ^ string_of_typ t))

(* translate : Sast.program -> Llvm.module *)
let translate (globals, functions) =
  let context    = L.global_context () in

  (* Black Magic*)
  let llmem_graph = L.MemoryBuffer.of_file "graph.bc" in
  let llm_graph = Llvm_bitreader.parse_bitcode context llmem_graph in

  (* Create the LLVM compilation module into which
     we will generate code *)
  let the_module = L.create_module context "Graphiti" in

  (* Get types from the context *)
  let i32_t      = L.i32_type    context
  and i8_t       = L.i8_type     context
  and i1_t       = L.i1_type     context
  and float_t    = L.double_type context
  and void_t     = L.void_type   context
  and str_t      = L.pointer_type (L.i8_type context) 
  and void_ptr_t = L.pointer_type (L.i8_type context)
  and lst_t      = L.pointer_type (match L.type_by_name llm_graph "struct.list" with
      None -> raise (Failure "Missing implementation for struct list")
    | Some t -> t)
  and map_t    = L.pointer_type (match L.type_by_name llm_graph "struct.map" with
      None -> raise (Failure "Missing implementation for struct map")
    | Some t -> t)
  and graph_t = L.pointer_type (match L.type_by_name llm_graph "struct.graph" with
      None -> raise (Failure "Missing implementation for struct graph")
    | Some t -> t)
  in

  (* Return the LLVM type for a MicroC type *)
  let ltype_of_typ = function
      A.Int   -> i32_t
    | A.Char  -> i8_t
    | A.Bool  -> i1_t
    | A.Float -> float_t
    | A.Void  -> void_t
    | A.String -> str_t
    | A.Map   -> map_t
    | A.List _ -> lst_t
    | A.Graph  ->  graph_t
  in

  (* Create a map of global variables after creating each *)
  let global_vars : L.llvalue StringMap.t =
    let global_var m (t, n) =
      let init = match t with
          A.Float -> L.const_float (ltype_of_typ t) 0.0
        | _ -> L.const_int (ltype_of_typ t) 0
      in StringMap.add n (L.define_global n init the_module) m in
    List.fold_left global_var StringMap.empty globals in

  (*print functions which built-in prints will call *)
  let printf_t : L.lltype =
      L.var_arg_function_type i32_t [| L.pointer_type i8_t |] in
  let printf_func : L.llvalue =
      L.declare_function "printf" printf_t the_module in

  let printbig_t : L.lltype =
      L.function_type i32_t [| i32_t |] in
  let printbig_func : L.llvalue =
      L.declare_function "printbig" printbig_t the_module in
  
  let printm_t : L.lltype = 
      L.function_type map_t [| map_t |] in
  let printm_func : L.llvalue = 
      L.declare_function "printm" printm_t the_module in

  let printl_t : L.lltype = 
      L.function_type lst_t [| lst_t |] in
  let printl_func : L.llvalue = 
      L.declare_function "printl" printl_t the_module in

  let printg_t : L.lltype = 
      L.function_type graph_t [| graph_t |] in
  let printg_func : L.llvalue = 
      L.declare_function "printg" printg_t the_module in
  

  (* Functions for Lists. It is generic so elements are void *! *)
  let make_list_t = L.function_type lst_t [||] in
  let make_list_func = L.declare_function "make_list" make_list_t the_module in

  let list_size_t = L.function_type i32_t [| lst_t |] in
  let list_size_func = L.declare_function "size" list_size_t the_module in
 
  let list_get_t = L.function_type void_ptr_t [| lst_t; i32_t |] in
  let list_get_func = L.declare_function "list_get" list_get_t the_module in

  let list_add_tail_t = L.function_type i32_t [| lst_t; void_ptr_t |] in
  let list_add_tail_func = L.declare_function "add_tail" list_add_tail_t the_module in

  (* Testing casting void inside the C code. Test <int>*)

  let list_set_int_t = L.function_type i32_t [| lst_t; i32_t; i32_t |] in
  let list_set_int_func = L.declare_function "list_set_int" list_set_int_t the_module in

  let list_add_head_int_t = L.function_type i32_t [| lst_t; i32_t |] in
  let list_add_head_int_func = L.declare_function "add_head_int" list_add_head_int_t the_module in

  let list_rm_head_int_t = L.function_type i32_t [| lst_t |] in
  let list_rm_head_int_func = L.declare_function "remove_head_int" list_rm_head_int_t the_module in

  let list_add_tail_int_t = L.function_type i32_t [| lst_t; i32_t |] in
  let list_add_tail_int_func = L.declare_function "add_tail_int" list_add_tail_int_t the_module in

  (* Convert Maps to Void * for usage for List<map> *)
  let list_set_map_t = L.function_type map_t [| lst_t; i32_t; map_t |] in
  let list_set_map_func = L.declare_function "list_set_map" list_set_map_t the_module in

  let list_add_head_map_t = L.function_type i32_t [| lst_t; map_t |] in
  let list_add_head_map_func = L.declare_function "add_head_map" list_add_head_map_t the_module in

  let list_rm_head_map_t = L.function_type map_t [| lst_t |] in
  let list_rm_head_map_func = L.declare_function "remove_head_map" list_rm_head_map_t the_module in

  let list_add_tail_map_t = L.function_type i32_t [| lst_t; map_t |] in
  let list_add_tail_map_func = L.declare_function "add_tail_map" list_add_tail_map_t the_module in

  (* Convert strings to Void * for usage for List<string> *)
  let list_set_str_t = L.function_type str_t [| lst_t; i32_t; str_t |] in
  let list_set_str_func = L.declare_function "list_set_str" list_set_str_t the_module in

  let list_add_head_str_t = L.function_type i32_t [| lst_t; str_t |] in
  let list_add_head_str_func = L.declare_function "add_head_str" list_add_head_str_t the_module in

  let list_rm_head_str_t = L.function_type str_t [| lst_t |] in
  let list_rm_head_str_func = L.declare_function "remove_head_str" list_rm_head_str_t the_module in

  let list_add_tail_str_t = L.function_type i32_t [| lst_t; str_t |] in
  let list_add_tail_str_func = L.declare_function "add_tail_str" list_add_tail_str_t the_module in

  (* Convert float/decimal to Void * for usage for List<float> *)
  let list_set_dec_t = L.function_type float_t [| lst_t; i32_t; float_t |] in
  let list_set_dec_func = L.declare_function "list_set_dec" list_set_dec_t the_module in

  let list_add_head_dec_t = L.function_type i32_t [| lst_t; float_t  |] in
  let list_add_head_dec_func = L.declare_function "add_head_dec" list_add_head_dec_t the_module in

  let list_rm_head_dec_t = L.function_type float_t [| lst_t |] in
  let list_rm_head_dec_func = L.declare_function "remove_head_dec" list_rm_head_dec_t the_module in

  let list_add_tail_dec_t = L.function_type i32_t [| lst_t; float_t |] in
  let list_add_tail_dec_func = L.declare_function "add_tail_dec" list_add_tail_dec_t the_module in

  (* Functions for maps Map *) 
  let make_map_t = L.function_type map_t [||] in 
  let make_map_func = L.declare_function "make_map" make_map_t the_module in

  let map_contains_key_t = L.function_type i32_t [| map_t; str_t |] in
  let map_contains_key_func = L.declare_function "contains_key" map_contains_key_t the_module in

  let map_contains_value_t = L.function_type i32_t [| map_t; str_t |] in
  let map_contains_value_func = L.declare_function "contains_value" map_contains_value_t the_module in

  let map_put_t = L.function_type i32_t [| map_t; str_t; str_t |] in
  let map_put_func = L.declare_function "put" map_put_t the_module in  

  let map_get_t = L.function_type str_t [|map_t; str_t|] in
  let map_get_func = L.declare_function "map_get" map_get_t the_module in 

  let map_remove_node_t = L.function_type i32_t [| map_t; str_t|] in
  let map_remove_node_func = L.declare_function "remove_node" map_remove_node_t the_module in

  let map_is_equal_t = L.function_type i32_t [| map_t; map_t|] in
  let map_is_equal_func = L.declare_function "is_equal" map_is_equal_t the_module in

  (* Function for graphs *)
  let graph_constructor_t = L.function_type graph_t [||] in
  let graph_constructor_f = L.declare_function "new_graph" graph_constructor_t the_module in

  let graph_add_vertex_t = L.function_type graph_t [|graph_t; map_t|] in
  let graph_add_vertex_f = L.declare_function "add_vertex" graph_add_vertex_t the_module in

  let graph_add_edge_t = L.function_type graph_t [|graph_t; map_t; map_t|] in
  let graph_add_edge_f = L.declare_function "add_edge" graph_add_edge_t the_module in

  let graph_add_wedge_t = L.function_type graph_t [|graph_t; map_t; str_t; map_t|] in
  let graph_add_wedge_f = L.declare_function "add_wedge" graph_add_wedge_t the_module in
  
  let graph_del_edge_t = L.function_type graph_t [|graph_t; map_t; map_t|] in
  let graph_del_edge_f = L.declare_function "delete_edge" graph_del_edge_t the_module in

  let graph_del_vertex_t = L.function_type graph_t [|graph_t; map_t|] in
  let graph_del_vertex_f = L.declare_function "delete_vertex" graph_del_vertex_t the_module in

  let graph_union_t = L.function_type graph_t [| graph_t; graph_t |] in
  let graph_union_f = L.declare_function "union_graph" graph_union_t the_module in

  let graph_intersection_t = L.function_type graph_t [| graph_t; graph_t |] in
  let graph_intersection_f = L.declare_function "intersection_graph" graph_intersection_t the_module in
 
  let graph_add_t = L.function_type graph_t [| graph_t; graph_t |] in
  let graph_add_f = L.declare_function "add" graph_add_t the_module in
  
  let graph_get_edges_t = L.function_type lst_t [|graph_t; map_t|] in 
  let graph_get_edges_f = L.declare_function "_get_edges" graph_get_edges_t the_module in

  let graph_get_nodes_t = L.function_type lst_t [|graph_t; map_t|] in
  let graph_get_nodes_f = L.declare_function "get_edge_neighbors" graph_get_nodes_t the_module in

  let graph_get_all_nodes_t = L.function_type lst_t [|graph_t|] in
  let graph_get_all_nodes_f = L.declare_function "get_all_vertices" graph_get_all_nodes_t the_module in

  (* Miscellanous functions, string ops, list concat, etc.*)
  let concat_string_t = L.function_type str_t [| str_t; str_t |] in
  let concat_string_func = L.declare_function "concat_string" concat_string_t the_module in

  let length_t = L.function_type i32_t [| str_t |] in
  let length_func = L.declare_function "length" length_t the_module in

  let get_char_t = L.function_type str_t [| str_t; i32_t |] in
  let get_char_func = L.declare_function "get_char" get_char_t the_module in

  let string_equals_t = L.function_type i32_t [| str_t; str_t |] in
  let string_equals_func = L.declare_function "str_comp" string_equals_t the_module in

  let concat_list_t = L.function_type lst_t [| lst_t; lst_t |] in
  let concat_list_func = L.declare_function "concat" concat_list_t the_module in

  (* Define each function (arguments and return type) so we can 
     call it even before we've created its body *)
  let function_decls : (L.llvalue * sfunc_decl) StringMap.t =
    let function_decl m fdecl =
      let name = fdecl.sfname
      and formal_types =
        Array.of_list (List.map (fun (t,_) -> ltype_of_typ t) fdecl.sformals)
      in let ftype = L.function_type (ltype_of_typ fdecl.styp) formal_types in
      StringMap.add name (L.define_function name ftype the_module, fdecl) m in
    List.fold_left function_decl StringMap.empty functions in

  (* Fill in the body of the given function *)
  let build_function_body fdecl =
    let (the_function, _) = StringMap.find fdecl.sfname function_decls in
    let builder = L.builder_at_end context (L.entry_block the_function) in

    let int_format_str = L.build_global_stringptr "%d\n" "fmt" builder
    and float_format_str = L.build_global_stringptr "%g\n" "fmt" builder
    and string_format_str = L.build_global_stringptr "%s\n" "fmt" builder 
    in

    (* Construct the function's "locals": formal arguments and locally
       declared variables.  Allocate each on the stack, initialize their
       value, if appropriate, and remember their values in the "locals" map *)
    let local_vars =
      let add_formal m (t, n) p =
        L.set_value_name n p;
        let local = L.build_alloca (ltype_of_typ t) n builder in
        ignore (L.build_store p local builder);
        StringMap.add n local m

      (* Allocate space for any locally declared variables and add the
       * resulting registers to our map *)
      and add_local m (t, n) =
        let local_var = L.build_alloca (ltype_of_typ t) n builder
        in StringMap.add n local_var m
      in

      (*let sformals = (List.map fst_snd_triple fdecl.sformals) in*)
      let formals = List.fold_left2 add_formal StringMap.empty fdecl.sformals
          (Array.to_list (L.params the_function)) in
      List.fold_left add_local formals fdecl.slocals
    in

    (* Return the value for a variable or formal argument.
       Check local names first, then global names *)
    let lookup n = try StringMap.find n local_vars
                   with Not_found -> StringMap.find n global_vars
    in

    (* Construct code for an expression; return its value *)
    let rec expr builder ((styp, e) : sexpr) = 
	
	match e with
        SLiteral i  -> L.const_int i32_t i
      | SBoolLit b  -> L.const_int i1_t (if b then 1 else 0)
      | SFliteral l -> L.const_float_of_string float_t l
      | SStrLit l    -> L.build_global_stringptr l "str" builder
      | SNoexpr     -> L.const_int i32_t 0
      | SId s       -> L.build_load (lookup s) s builder
      | SCharLit l -> L.const_int i8_t (C.code l)
      | SListLit l -> let rec list_fill lst = (function
		[] -> lst
		| sx :: rest ->
		let (t, _) = sx in 
		let data = (match t with
			  A.Map |A.Graph |A.List _ | A.String -> expr builder sx 
			| _ -> let data = L.build_malloc (ltype_of_typ t) "data" builder in
				let llvm =  expr builder sx 
				in ignore(L.build_store llvm data builder); data)
		in let data = L.build_bitcast data void_ptr_t "data" builder in
			ignore(L.build_call list_add_tail_func [| lst; data |] "list_add_tail" builder); list_fill lst rest) in
		let m = L.build_call make_list_func [||] "make_list" builder in
		list_fill m l
	  | SListSize(l) -> let l' = expr builder l in 
			L.build_call list_size_func [|l'|] "size" builder;   
      | SListGet(l, idx) ->
		let ltype = ltype_of_typ styp in
		let lst = expr builder l in
		let index = expr builder idx in
		let data = L.build_call list_get_func [| lst; index |] "index" builder in
		(match styp with 
			A.List _ | A.Graph | A.String | A.Map -> L.build_bitcast data ltype "data" builder
			| _ -> let data = L.build_bitcast data (L.pointer_type ltype) "data" builder in
				L.build_load data "data" builder)
      | SListSet(l, idx, e) -> 
			let r = (match check_list_type(l) with
			 A.Int -> let l' = expr builder l and idx' = expr builder idx and e' = expr builder e in
				L.build_call list_set_int_func [|l'; idx'; e'|] "list_set_int" builder;
			| A.Map -> let l' = expr builder l and idx' = expr builder idx and e' = expr builder e in
				L.build_call list_set_map_func [|l'; idx'; e'|] "list_set_map" builder;
			| A.String -> let l' = expr builder l and idx' = expr builder idx and e' = expr builder e in
				L.build_call list_set_str_func [|l'; idx'; e'|] "list_set_str" builder;
			| A.Float -> let l' = expr builder l and idx' = expr builder idx and e' = expr builder e in
				L.build_call list_set_dec_func [|l'; idx'; e'|] "list_set_dec" builder;
			| _ -> raise(Failure("Not Valid List Lit Type!"))) in
			r  
      | SList_Add_Head(l, e) -> 			
			let r = (match get_type(e) with
			 A.Int -> let l' = expr builder l and e' = expr builder e in
				 L.build_call list_add_head_int_func [|l'; e'|] "add_head_int" builder;
			| A.Map -> let l' = expr builder l and e' = expr builder e in
				 L.build_call list_add_head_map_func [|l'; e'|] "add_head_map" builder;
			| A.String -> let l' = expr builder l and e' = expr builder e in
				 L.build_call list_add_head_str_func [|l'; e'|] "add_head_str" builder;
			| A.Float -> let l' = expr builder l and e' = expr builder e in
				 L.build_call list_add_head_dec_func [|l'; e'|] "add_head_dec" builder;
			| _ -> raise(Failure("Not Valid List Lit Type!"))) in
			r
      | SList_Rm_Head(l) -> 
			let r = (match check_list_type(l) with
			 A.Int -> let l' = expr builder l in 
				L.build_call list_rm_head_int_func [|l'|] "remove_head_int" builder;
			| A.Map -> let l' = expr builder l in 
				L.build_call list_rm_head_map_func [|l'|] "remove_head_map" builder;
			| A.String -> let l' = expr builder l in 
				L.build_call list_rm_head_str_func [|l'|] "remove_head_str" builder;
			| A.Float -> let l' = expr builder l in 
				L.build_call list_rm_head_dec_func [|l'|] "remove_head_dec" builder;
			| _ -> raise(Failure("Not Valid List Lit Type!"))) in
			r
      | SList_Add_Tail(l, e) -> let r = (match get_type(e) with
			 A.Int -> let l' = expr builder l and e' = expr builder e in
				L.build_call list_add_tail_int_func [|l'; e'|] "add_tail_int" builder;
			| A.Map -> let l' = expr builder l and e' = expr builder e in
				L.build_call list_add_tail_map_func [|l'; e'|] "add_tail_map" builder;
			| A.String -> let l' = expr builder l and e' = expr builder e in
				L.build_call list_add_tail_str_func [|l'; e'|] "add_tail_str" builder;
			| A.Float -> let l' = expr builder l and e' = expr builder e in
				L.build_call list_add_tail_dec_func [|l'; e'|] "add_tail_dec" builder;
			| _ -> raise(Failure("Not Valid List Lit Type!"))) in
			r 	
      | SMapLit l ->
          let m = L.build_call make_map_func [||] "make_map" builder in
          List.iter (fun (k, v) -> ignore(
              let k' = expr builder k
              and v' = expr builder v in
              L.build_call map_put_func [| m; k'; v'|] "put" builder)) l;
          m
      | SGraphLit l ->
          let g = L.build_call graph_constructor_f [||] "new_graph" builder in
          List.iter (fun (_, e) -> ignore(
              match e with    
              | SGraphAddVertex(n) -> 
                  let n' = expr builder n in
                  L.build_call graph_add_vertex_f [|g; n'|] "add_vertex" builder
              | SGraphAddEdge (n1, n2) -> 
                  let n1' = expr builder n1 
                  and n2' = expr builder n2 in
                  L.build_call graph_add_edge_f [|g; n1'; n2'|] "add_edge" builder
              | SGraphAddWedge (n1, w, n2) ->
                  let n1' = expr builder n1 
                  and w' = expr builder w
                  and n2' = expr builder n2 in
                  L.build_call graph_add_wedge_f [|g; n1'; w'; n2'|] "add_wedge" builder
              | _ -> raise(Failure("Unsupported operation.")))) l;
          g

      | SGraphMod (g, l) -> 
          let g' = L.build_load (lookup g) g builder in 
          List.iter (fun (_,e) -> ignore(
              match e with    
                SGraphAddVertex(n) -> 
                  let n' = expr builder n in
                  L.build_call graph_add_vertex_f [|g'; n'|] "graph_add_vertex" builder
              | SGraphAddEdge (n1, n2) -> 
                  let n1' = expr builder n1 
                  and n2' = expr builder n2 in
                  L.build_call graph_add_edge_f [|g'; n1'; n2'|] "graph_add_edge" builder
              | SGraphAddWedge (n1, w, n2) ->
                  let n1' = expr builder n1 
                  and w' = expr builder w
                  and n2' = expr builder n2 in
                  L.build_call graph_add_wedge_f [|g'; n1'; w'; n2'|] "graph_add_wedge" builder
              | SGraphDelVertex (n) ->
                  let n' = expr builder n in
                  L.build_call graph_del_vertex_f [|g'; n'|] "graph_del_vertex" builder
              | SGraphDelEdge (n1, n2) ->
                  let n1' = expr builder n1
                  and n2' = expr builder n2 in
                  L.build_call graph_del_edge_f [|g'; n1'; n2'|] "graph_del_edge" builder
              | _ -> raise(Failure("Unsupported operation.")))) l;
          g'
      | SAssign (s, e) -> let e' = expr builder e in
          ignore(L.build_store e' (lookup s) builder); e'

      | SBinop ((A.List(_), _) as e1, op, e2) ->
		let e1' = expr builder e1 
		and e2' = expr builder e2 in
		(match op with 
		A.Add -> L.build_call concat_list_func [| e1'; e2' |] "concat" builder
                | _ -> raise(Failure("Invalid List operator " ^ A.string_of_op op)))

      | SBinop ((A.String, _) as e1, op, e2) ->
		let e1' = expr builder e1 
		and e2' = expr builder e2 in
		(match op with 
		A.Add -> L.build_call concat_string_func [| e1'; e2' |] "concat_string" builder
          	| A.Equal -> (L.build_icmp L.Icmp.Ne) (L.const_int i32_t 0)
			(L.build_call string_equals_func [| e1'; e2' |] "str_comp" builder) "tmp" builder
          	| A.Neq -> (L.build_icmp L.Icmp.Eq) (L.const_int i32_t 0)
			(L.build_call string_equals_func [| e1'; e2' |] "str_comp" builder) "tmp" builder
		| _ -> raise(Failure("Invalid string operator " ^ A.string_of_op op)))

      | SBinop ((A.Float,_ ) as e1, op, e2) ->
          let e1' = expr builder e1
          and e2' = expr builder e2 in
          (match op with
            A.Add     -> L.build_fadd
          | A.Sub     -> L.build_fsub
          | A.Mult    -> L.build_fmul
          | A.Div     -> L.build_fdiv
          | A.Mod     -> L.build_frem
          | A.Equal   -> L.build_fcmp L.Fcmp.Oeq
          | A.Neq     -> L.build_fcmp L.Fcmp.One
          | A.Less    -> L.build_fcmp L.Fcmp.Olt
          | A.Leq     -> L.build_fcmp L.Fcmp.Ole
          | A.Greater -> L.build_fcmp L.Fcmp.Ogt
          | A.Geq     -> L.build_fcmp L.Fcmp.Oge
          | A.And
          | A.Or ->
              raise (Failure "internal error: semant should have rejected and/or on float")
          | A.Union | A.Intersect  -> raise (Failure "only graph can be (union/intersect)ed")
          ) e1' e2' "tmp" builder
      | SBinop ((A.Graph, _) as e1, op, e2) ->
          let e1' = expr builder e1
          and e2' = expr builder e2 in
          (match op with
            A.Add -> L.build_call graph_add_f [|e1'; e2'|] "graph_add" builder
          | A.Union     -> L.build_call graph_union_f [| e1'; e2' |] "graph_union" builder 
          | A.Intersect -> L.build_call graph_intersection_f [| e1'; e2' |] "graph_intersection" builder
          | _ -> raise (Failure "graph can only be (union/intersect)ed")) 
      | SBinop (e1, op, e2) ->
          let e1' = expr builder e1
          and e2' = expr builder e2 in
          (match op with
            A.Add     -> L.build_add
          | A.Sub     -> L.build_sub
          | A.Mult    -> L.build_mul
          | A.Div     -> L.build_sdiv
          | A.Mod     -> L.build_srem
          | A.And     -> L.build_and
          | A.Or      -> L.build_or
          | A.Equal   -> L.build_icmp L.Icmp.Eq
          | A.Neq     -> L.build_icmp L.Icmp.Ne
          | A.Less    -> L.build_icmp L.Icmp.Slt
          | A.Leq     -> L.build_icmp L.Icmp.Sle
          | A.Greater -> L.build_icmp L.Icmp.Sgt
          | A.Geq     -> L.build_icmp L.Icmp.Sge
          | A.Union | A.Intersect -> raise (Failure "only graph can be (union/intersect)ed")
	  ) e1' e2' "tmp" builder
      | SUnop(op, ((t, _) as e)) ->
          let e' = expr builder e in
          (match op with
            A.Neg when t = A.Float -> L.build_fneg
          | A.Neg                  -> L.build_neg
          | A.Not                  -> L.build_not) e' "tmp" builder
      | SCall ("length", [e]) ->
		L.build_call length_func [| (expr builder e) |] "length" builder
      | SCall ("get_char", [str;index]) ->
                let index = expr builder index and
                str = expr builder str in
                L.build_call get_char_func [| str; index |] "get_char" builder
      | SCall ("printl", [e]) ->
                L.build_call printl_func [| (expr builder e) |] "printl" builder
      | SCall ("printi", [e]) | SCall ("printb", [e]) ->
          L.build_call printf_func [| int_format_str ; (expr builder e) |]
            "printf" builder
      | SCall ("printbig", [e]) ->
          L.build_call printbig_func [| (expr builder e) |] "printbig" builder
      | SCall ("printf", [e]) ->
          L.build_call printf_func [| float_format_str ; (expr builder e) |]
            "printf" builder
      | SCall ("print", [e]) ->
          L.build_call printf_func [| string_format_str ; (expr builder e) |] "printf" builder
      (* Built-in print functions for maps and graphs *)
	  | SCall ("printm", [e]) ->
          L.build_call printm_func [| (expr builder e) |] "printm" builder
      | SCall ("printg", [e]) ->
          L.build_call printg_func [| (expr builder e) |] "printg" builder
      | SCall (f, args) ->
         let (fdef, fdecl) = StringMap.find f function_decls in
         let llargs = List.rev (List.map (expr builder) (List.rev args)) in
         let result = (match fdecl.styp with
                        A.Void -> ""
                      | _ -> f ^ "_result") in
         L.build_call fdef (Array.of_list llargs) result builder
      | SGraphEdges (g, n) ->
        let graph = expr builder g
        and node = expr builder n in
        L.build_call graph_get_edges_f [|graph; node|] "_get_edges" builder
      | SGraphNodes (g, n) -> 
        let graph = expr builder g 
        and node = expr builder n in 
        L.build_call graph_get_nodes_f [|graph; node|] "get_edge_neighbors" builder
      | SGraphAllNodes (g) ->
        let graph = expr builder g in
        L.build_call graph_get_all_nodes_f [|graph|] "get_all_nodes" builder
     | SGraphAll (g) ->
        let graph = expr builder g in
        L.build_call graph_get_all_nodes_f [|graph|] "get_all_vertices" builder

      (* Map Methods*) 
      | SMapPut (m, k, v) -> 
        let map = expr builder m 
        and key = expr builder k
        and value = expr builder v in 
        L.build_call map_put_func [|map; key; value|] "put" builder;
      | SMapGet (m, k) -> 
        let map = expr builder m
        and key = expr builder k in
        L.build_call map_get_func [|map;key|] "map_get" builder; 
      | SMapContainsKey (m, k) -> 
        let map = expr builder m     
        and key = expr builder k in
        L.build_call map_contains_key_func [|map; key|] "contains_key" builder;  
      | SMapContainsValue (m, v) -> 
        let map = expr builder m     
        and value = expr builder v in
        L.build_call map_contains_value_func [|map; value|] "contains_value" builder;  
      | SMapRemoveNode(m, k) -> 
        let map = expr builder m     
        and key = expr builder k in
        L.build_call map_remove_node_func [|map; key|] "remove_node" builder;
      | SMapIsEqual(m1, m2) ->
                let map1 = expr builder m1
                and map2 = expr builder m2 in
                L.build_call map_is_equal_func [|map1; map2|] "is_equal" builder;
    
	  | _ -> raise(Failure("Unsupported operation."))
	  in 

    (* LLVM insists each basic block end with exactly one "terminator"
       instruction that transfers control.  This function runs "instr builder"
       if the current block does not already have a terminator.  Used,
       e.g., to handle the "fall off the end of the function" case. *)
    let add_terminal builder instr =
      match L.block_terminator (L.insertion_block builder) with
        Some _ -> ()
      | None -> ignore (instr builder) in

    (* Build the code for the given statement; return the builder for
       the statement's successor (i.e., the next instruction will be built
       after the one generated by this call) *)

    let rec stmt builder = function
        SBlock sl -> List.fold_left stmt builder sl
      | SExpr e -> ignore(expr builder e); builder
      | SReturn e -> ignore(match fdecl.styp with
                              (* Special "return nothing" instr *)
                              A.Void -> L.build_ret_void builder
                              (* Build return statement *)
                            | _ -> L.build_ret (expr builder e) builder );
                     builder
      | SIf (predicate, then_stmt, else_stmt) ->
         let bool_val = expr builder predicate in
         let merge_bb = L.append_block context "merge" the_function in
         let build_br_merge = L.build_br merge_bb in (* partial function *)

         let then_bb = L.append_block context "then" the_function in
         add_terminal (stmt (L.builder_at_end context then_bb) then_stmt)
           build_br_merge;

         let else_bb = L.append_block context "else" the_function in
         add_terminal (stmt (L.builder_at_end context else_bb) else_stmt)
           build_br_merge;

         ignore(L.build_cond_br bool_val then_bb else_bb builder);
         L.builder_at_end context merge_bb

      | SWhile (predicate, body) ->
          let pred_bb = L.append_block context "while" the_function in
          ignore(L.build_br pred_bb builder);

          let body_bb = L.append_block context "while_body" the_function in
          add_terminal (stmt (L.builder_at_end context body_bb) body)
            (L.build_br pred_bb);

          let pred_builder = L.builder_at_end context pred_bb in
          let bool_val = expr pred_builder predicate in

          let merge_bb = L.append_block context "merge" the_function in
          ignore(L.build_cond_br bool_val body_bb merge_bb pred_builder);
          L.builder_at_end context merge_bb
         in     
    (* Build the code for each statement in the function *)
    let builder = stmt builder (SBlock fdecl.sbody) in

    (* Add a return if the last block falls off the end *)
    add_terminal builder (match fdecl.styp with
        A.Void -> L.build_ret_void
      | A.Float -> L.build_ret (L.const_float float_t 0.0)
      | t -> L.build_ret (L.const_int (ltype_of_typ t) 0))
  in
      
  List.iter build_function_body functions;
  the_module
