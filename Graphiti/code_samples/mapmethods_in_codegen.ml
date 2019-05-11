(* Excerpt of Codegen related to Map Methods*)
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
