#include <stdio.h>
#include "graph.h"

int main(int arg, char **argv) {

	/*
	 * TESTING FOR MAPS
	 */

	struct map *m1 = make_map();

	// testing put
	printf("\nTesting put:\n");
	put(m1, "alice1", "1");
	put(m1, "alice2", "2");
	put(m1, "alice3", "3");
	put(m1, "alice4", "4");
	put(m1, "alice5", "5");
	put(m1, "alice5", "5");
	printm(m1);

	// testing get
	printf("\nTesting get:\n");
	printf("Value for 'alice1': %s\n", map_get(m1, "alice1"));
	printf("Value for 'alice2': %s\n", map_get(m1, "alice2"));
	printf("Value for 'alice3': %s\n", map_get(m1, "alice3"));
	printf("Value for 'alice4': %s\n", map_get(m1, "alice4"));
	printf("Value for 'alice5': %s\n", map_get(m1, "alice5"));

	// testing contains_key
	printf("\nTesting contains_key:\n");
	printf("Contains key 'alice1': %d\n", contains_key(m1, "alice1"));
	printf("Contains key 'alice5': %d\n", contains_key(m1, "alice5"));
	printf("Contains key 'michal': %d\n", contains_key(m1, "michal"));
	printf("Contains key 'emily': %d\n", contains_key(m1, "emily"));
	printf("Contains key 'sydney': %d\n", contains_key(m1, "sydney"));

	// testing contains_value
	printf("\nTesting contains_value:\n");
	printf("Contains value '1': %d\n", contains_value(m1, "1"));
	printf("Contains value '2': %d\n", contains_value(m1, "2"));
	printf("Contains value 'at3061': %d\n", contains_value(m1, "at3061"));
	printf("Contains value 'esh2160': %d\n", contains_value(m1, "esh2160"));
	printf("Contains value 'stl2121': %d\n", contains_value(m1, "stl2121"));

	// testing remove_node
	printf("\nTesting remove_node:\n");
	printf("Removing node ('alice1', '1'):\n");
	remove_node(m1, "alice1");
	printf("Removing node ('alice2', '2'):\n");
	remove_node(m1, "alice2");
	printf("Removing node ('alice3', '3'):\n");
	remove_node(m1, "alice3");
	printf("Removing node ('dummy', 'entry'):\n");
	remove_node(m1, "dummy");
	printf("Removing node ('alice4', '4'):\n");
	remove_node(m1, "alice4");
	printf("Removing node ('alice5', '5'):\n");
	remove_node(m1, "alice5");
	printm(m1);
	free_map(m1);

	// testing map comparison
	printf("\nTesting is_equal:\n");

	struct map *ma = make_map();
	put(ma, "a", "a1");
	put(ma, "b", "b2");
	put(ma, "c", "c3");
	printm(ma);
	struct map *mb = make_map();
	put(mb, "a", "a1");
	put(mb, "b", "b2");
	put(mb, "c", "c3");
	printm(mb);
	printf("Maps are equal: %d\n", is_equal(ma, mb));

	remove_node(mb, "c");
	printm(ma);
	printm(mb);
	printf("Maps are equal: %d\n", is_equal(ma, mb));

	put(mb, "c", "c4");
	printm(ma);
	printm(mb);
	printf("Maps are equal: %d\n", is_equal(ma, mb));

	free_map(ma);
	free_map(mb);

	// freeing map
	printf("\nFreeing map:\n");

	struct map *m2 = make_map();
	put(m2, "a", "1");
	put(m2, "b", "2");
	put(m2, "c", "3");
	put(m2, "d", "4");
	put(m2, "e", "5");
	printm(m2);
	free_map(m2);

     /*
     * TESTING FOR GRAPHS
     */

    /*struct graph *g = new_graph();

    struct map *v1 = make_map();
    struct map *v2 = make_map();
    put(v1, "alice1", "1");
    put(v2, "alice2", "2");

	printf("\nTesting add_vertex():\n");
    add_vertex(g, v1);
    add_vertex(g, v2);
    printf("Number of nodes in graph 'g': %d\n", g -> vertex_count);

    struct vertex *c = g -> vertex_head;
    while (c)
    {
        struct map_node *tmp = (c->data)->node_head;
        printf("%s\n", tmp -> key);
        c = c-> next_vertex;
    }


	printf("\nTesting get_vertex():\n");
    struct vertex *v = get_vertex(g, v1);
    printf("Number of nodes in graph 'g': %d\n", g -> vertex_count);


	printf("\nTesting delete_vertex():\n");
    delete_vertex(g, v1);
    printf("Number of nodes in graph 'g': %d\n", g -> vertex_count);
    struct vertex *c2 = g -> vertex_head;
    while (c2)
    {
        struct map_node *tmp = (c2->data)->node_head;
        printf("%s\n", tmp -> key);
        c2 = c2-> next_vertex;
    }

    printf("\nTesting add_edge():\n");
    struct map *v3 = make_map();
    struct map *v4 = make_map();
    put(v3, "alice3", "3");
    put(v4, "alice4", "4");
    add_vertex(g, v3);
    add_vertex(g, v4);

    char *data = "Hello";
    add_edge(g, v3, v4, data);
    add_edge(g, v4, v3, data);
    printf("Number of edges in graph 'g': %d\n", g -> edge_count);
    struct vertex *c3 = g -> vertex_head;
    while (c3)
    {
        struct edge *tmp = c3 -> connected_edges;
        while (tmp){
            printf("%s\n", tmp -> data);
            tmp = tmp -> next;
        }
        c3 = c3 -> next_vertex;
    }

    printf("\nTesting _find_edge():\n");
    int i = _find_edge(g, v3, v4);
    if(i == 1){
        printf("Edge found!\n");
    }
    else{
        printf("Edge not found!\n");
    }

    int k = _find_edge(g, v4, v3);
    if(k == 1){
        printf("Edge found!\n");
    }
    else{
        printf("Edge not found!\n");
    }

    int j = _find_edge(g, v3, v2);
    if(j == 1){
        printf("Edge found!\n");
    }
    else{
        printf("Edge not found!\n");
    }

     printf("\nTesting _modify_edge():\n");
     char *data2 = "Goodbye";
     _modify_edge(g, v3, v4, data2);
     struct vertex *c4 = g -> vertex_head;
     while (c4){
        struct edge *tmp = c4 -> connected_edges;
        while (tmp){
            printf("%s\n", tmp -> data);
            tmp = tmp -> next;
        }
        c4 = c4 -> next_vertex;
     }*/

    /* testing intersection, union, and add*/

    /*struct graph *g2 = new_graph();
    struct graph *g3 = new_graph();


    struct map *t1 = make_map();
    struct map *t2 = make_map();
    struct map *t3 = make_map();
    struct map *t4 = make_map();
    put(t1, "sydney1", "1");
	put(t2, "sydney2", "2");
	put(t3, "sydney3", "3");
	put(t4, "sydney4", "4");

    add_vertex(g2, t1);
    add_vertex(g2, t2);
    add_vertex(g3, t1);
    add_vertex(g3, t3);
    add_vertex(g3, t4);

    printf("\nTesting intersection_graphs():\n");
    struct graph *inter = intersection_graph(g2, g3);
    struct vertex *ig = inter -> vertex_head;
    while (ig)
    {
        struct map_node *tmp = (ig->data)->node_head;
        printf("%s\n", tmp -> key);
        ig = ig-> next_vertex;
    }


    printf("\nTesting union_graphs():\n");
    struct graph *un = union_graph(g2, g3);
    struct vertex *ip = un -> vertex_head;
    while (ip)
    {
        struct map_node *tmp = (ip->data)->node_head;
        printf("%s\n", tmp -> key);
        ip = ip -> next_vertex;
    }

    printf("\nTesting add():\n");
    struct graph *a = add(g2, g3);
    struct vertex *ad = a -> vertex_head;
    while (ad)
    {
        struct map_node *tmp = (ad->data)->node_head;
        printf("%s\n", tmp -> key);
        ad = ad -> next_vertex;
    }

    printf("\nTesting clean_graph():\n");
    struct graph *fr = new_graph();
    struct map *f1 = make_map();
    struct map *f2 = make_map();
    put(f1, "lee1", "1");
	put(f2, "lee2", "2");
    add_vertex(fr, f1);
    add_vertex(fr, f1);

    printf("\nTesting modify_graph():\n");
    struct graph *mg = new_graph();
    struct map *e = make_map();
    put(e, "taylor1", "1");
    struct map *b = make_map();
    put(b, "taylor2", "2");

    char *data3 = "test";
    modify_graph(mg, e, data3, b, 0);
    struct vertex *ii = mg -> vertex_head;
    while (ii)
    {
        struct map_node *tmp = (ii->data)->node_head;
        printf("%s\n", tmp -> key);
        ii = ii -> next_vertex;
    }
    struct vertex *c5 = mg -> vertex_head;
    while (c5){
        struct edge *tmp = c5 -> connected_edges;
        while (tmp){
            printf("%s\n", tmp -> data);
            tmp = tmp -> next;
        }
        c5 = c5 -> next_vertex;
     }

    _clean_graph(fr); */

    struct graph *g = new_graph();
    struct map *e1 = make_map();
    struct map *e2 = make_map();
    struct map *e3 = make_map();
    put(e1, "a", "a1");
	put(e2, "b", "b2");
	put(e3, "c", "c3");

    add_vertex(g, e1);
    add_vertex(g, e2);
    add_vertex(g, e3);

    _add_edge(g, e1, e2, "five");
    _add_edge(g, e1, e3, "six");

    struct list *k = get_all_vertices(g);
    struct list_node *cur = k->head;
    while(cur){

        struct map *tmp = (struct map *)cur->data;
        printf("%s\n", tmp->node_head->key);
        cur = cur -> next;
    }

    struct list *bn = _get_edges(g, e1);
    struct list_node *cur1 = bn->head;
    while(cur1){

        char *tmp1 = (char *)cur1->data;
        printf("%s\n", tmp1);
        cur1 = cur1 -> next;
    }

    struct list *gn = get_edge_neighbors(g, e1);
    struct list_node *cur2 = gn->head;
    while(cur2){
        struct map *tmp2 = (struct map *)cur2->data;
        if(tmp2){
            printf("%s\n", tmp2->node_head->key);
        }
        cur2 = cur2 -> next;

    }

    printg(g);







	/*
	 * TESTING FOR LISTS
	 */

	struct list *l = make_list();
        int x = 1;
	// testing for add_head and add_tail
	add_tail_int(l, x);
        ++x;
	add_tail_int(l, x);
	++x;
        add_tail_int(l, x);
	++x;
        add_tail_int(l, x);
	++x;
        add_tail_int(l, x);
        printl(l);

	// testing for get and set
	/*
        set(l, 0, (int*)10);
	set(l, 1, (int*)20);
	set(l, 2, (int*)30);
	list_get(l, 0);
	list_get(l, 1);
	printf("list size: %d\n", l->size);
        */
	// testing for remove_head and remove_tail

	remove_head(l);
	//remove_tail(l);
	remove_head(l);
	//remove_tail(l);
	printf("list size: %d\n", l->size);

}
