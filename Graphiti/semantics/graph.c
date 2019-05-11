/*
 * Authors: Alice Thum, Sydney Lee, Michal Porubcin
 */

#include "graph.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/*
 * MAP METHODS
 */

/*
 * Initializes an empty map.
 */
struct map * make_map() {

	struct map *m;
	m = malloc(sizeof(struct map));
	if (m == NULL)
		return NULL;

	m->node_head = NULL;
	m->size = 0;
	return m;
}

/*
 * Puts a key-value pair into a map.
 * Returns a 1 if successful and 0 otherwise.
 */
int put(struct map *m, char *key, char *value) {

	/* no duplicate keys allowed */
	if (contains_key(m, key))
		return 0;

	struct map_node *node;
	node = malloc(sizeof(struct map_node));
	if (node == NULL)
		return 0;

	node->key = key;
	node->value = value;

	if (m->node_head == NULL) {
		node->next = NULL;
		m->node_head = node;
	} else {
		node->next = m->node_head;
		m->node_head = node;
	}

	m->size += 1;
	return 1;
}

/*
 * Gets a value from a map given a key.
 */
char * map_get(struct map *m, char *key) {

	if (m->node_head == NULL)
		return NULL;

	struct map_node *current = m->node_head;
	while (current != NULL) {
		if (strcmp(current->key, key) == 0)
			return current->value;
		current = current->next;
	}
	return NULL;
}

/*
 * Returns 1 if a key is found in a map
 * and 0 otherwise.
 */
int contains_key(struct map *m, char *key) {

	if (m->node_head == NULL)
		return 0;

	struct map_node *current = m->node_head;
	while (current != NULL) {
		if (strcmp(current->key, key) == 0)
			return 1;
		current = current->next;
	}
	return 0;
}

/*
 * Returns 1 if a value is found in a map
 * and 0 otherwise.
 */
int contains_value(struct map *m, char *value) {

	if (m->node_head == NULL)
		return 0;

	struct map_node *current = m->node_head;
	while (current != NULL) {
		if (strcmp(current->value, value) == 0)
			return 1;
		current = current->next;
	}
	return 0;
}

/*
 * Removes a node from a map.
 * Returns a 1 if successful and a 0 otherwise.
 * (e.g. empty list, list does not contain key)
 */
int remove_node(struct map *m, char *key) {

	if (m->node_head == NULL)
		return 0;

	if (contains_key(m, key) == 0)
		return 0;

	struct map_node *current = m->node_head;
	struct map_node *prev = NULL;

	while (current != NULL) {

		if (strcmp(current->key, key) == 0) {
			/* removing the head of the list */
			if (current == m->node_head) {
				m->node_head = current->next;
				m->size -= 1;
				return 1;
			}
			prev->next = current->next;
			m->size -= 1;
			return 1;
		}

		if (prev == NULL) prev = m->node_head;
		else prev = prev->next;
		current = current->next;
	}
	return 1;
}

/*
 * Compares two maps for equality.
 */
int is_equal(struct map *m1, struct map *m2) {

	if (m1->size != m2->size)
		return 0;

	struct map_node *c1 = m1->node_head;
	while (c1 != NULL) {
		if (contains_key(m2, c1->key) == 0)
			return 0;
		if (map_get(m2, c1->key) != c1-> value)
			return 0;
		c1 = c1->next;
	}
	return 1;
}

/*
 * Frees allocated memory for a map.
 */
void free_map(struct map *m) {

	if (m->node_head != NULL) {
		/* free all individual nodes */
		struct map_node *current = m->node_head;
		struct map_node *after;

		while (current != NULL) {
			after = current->next;
			free(current);
			current = after;
		}
	}
	free(m);
}

/*
 * Prints out map in specified format:
 * {
 *  "michal" : "language guru",
 *  "emily" : "tester"
 * }
 */
 void printm(struct map *m) {
 	printf("{\n");

	struct map_node *current = m->node_head;
	while (current != NULL) {

		printf("\t\"%s\" : \"%s\"", current->key, current->value);
		if (current->next != NULL)
			printf(",\n");
		else
			printf("\n");
		current = current->next;
	}

	printf("}\n");
 }

/*
 * GRAPH METHODS
 */

/*
 * decides whether a graph should be modified or a node/edge should be deleted
 */

struct graph *new_graph()
{

    // Make sure you get correct parameters...
    struct graph * n = malloc(sizeof(struct graph));
    if(n == NULL)
    {
        printf("malloc failed!\n");
        return NULL;
    }
    n -> vertex_count = 0;
    n -> edge_count = 0;
    n -> vertex_head = NULL;
    return n;

}


struct vertex * _new_vertex(struct map *data)
{

	struct vertex * new_vertex = malloc(sizeof(struct vertex));
    if(new_vertex == NULL){
        printf("malloc failed at build new node\n");
        return NULL;
    }

	//do we need a void star cast??
    new_vertex -> connected_edges = NULL;
    new_vertex -> next_vertex = NULL;
    new_vertex -> data = data;

	return new_vertex;

}

struct edge * _new_edge(struct vertex *a, struct vertex *b, char *data)
{

    struct edge *current = malloc(sizeof(struct edge));

    if(current == NULL){
        printf("malloc failed at build new node\n");
        return NULL;
    }

    current -> from = a;
    current -> to = b;
    current -> next = 0;
    current -> data = data;

    return current;

}

void modify_graph(struct graph *g, struct map * a, char *w, struct map *b, int d) {
    if(d == 0){
    /*checks to see if B has data in it, if it does:*/
        if(b){
        //add vertices into graph if they are not already in it
            if(!get_vertex(g,a)) { add_vertex(g,a); }
	    if(!get_vertex(g,b)) { add_vertex(g,b); }

        //if the edge doens't exist then add the edge, otherwise modify it
            if(_find_edge(g,a,b) == 0){
                if(w == 0) { w = ""; }
                _add_edge(g,a,b,w);
            }
	    else {
                if(w == 0) { w = ""; }
                _modify_edge(g,a,b,w);
            }
        }
	else {
            add_vertex(g,a);
        }
    }
    else{
        if(b){
	    delete_edge(g,a,b);
        }
	else{
            delete_vertex(g,a);
        }
    }
}

void add_vertex(struct graph *g, struct map *data){

	if(g == 0){
		printf("graph not found! add_new_vertex()\n");
        return ;
	}

	if (data == 0){
        printf("vertex not found! add_new_vertex()\n");
        return ;
    }

	//create a new vertex with the data
	struct vertex *v = _new_vertex(data);

	++(g -> vertex_count);

	//traverse list until end, then add new node to the end
	struct vertex *current = g -> vertex_head;

    //if we have no verices yet, then add the first vertex to the list
    if (g -> vertex_head == 0){
        g -> vertex_head = v;
        return;
    }

    //otherwise traverse until we can't and then add
	while(current -> next_vertex){
		current = current -> next_vertex;
	}

	current -> next_vertex = v;
	return ;
}

void delete_vertex(struct graph *g, struct map *data)
{

	if(g == 0){
        printf("graph not found: delete_vertex()!\n");
        return;
    }
    if(g -> vertex_count == 0){
        printf("no vertex to delete in: delete_vertex()\n");
        return;
    }

	//get the vertex to be deleted
	struct vertex *to_delete = get_vertex(g, data);
	struct vertex * prev; //used to fix vertices list in graphs later

	if(!to_delete){
		printf("vertex not found\n");
		return;
	}

	//traverse and try to find the node needed to delete
	struct vertex *current = g -> vertex_head;

	//accounts for if the deleted node is the head of the vertex
	if((g -> vertex_head) == to_delete){
        struct vertex *tmp = (g -> vertex_head) -> next_vertex;
		g -> vertex_head = tmp;
	}

	//otherwise traverse the list until we see the delete node as our next node
	else {
		while (current -> next_vertex){
			/*if we found the node that we are looking for, make current skip its next node and point to the node after*/
			//how do we compare these two?
			if (current -> next_vertex == to_delete){
			    struct vertex *tmp = current -> next_vertex;
				struct vertex *next_node = tmp -> next_vertex;
				current -> next_vertex = next_node;
				break;
			}

			current = current -> next_vertex;
		}
	}

	//go through the list and delete the nodes from each edge list
	//remove like how we did above where we just redirect the next pointer
    struct vertex *current2 = g -> vertex_head;

    while(current2){

        struct edge *current_edge = current2 -> connected_edges;
        if(current_edge != 0){
            if (current_edge -> to == to_delete){
                struct edge *tmp = current_edge -> next;
                current_edge = tmp;
            }
            else{
                while (current_edge -> next){
                    struct edge *tmp = current_edge -> next;
                    if(tmp -> from  == to_delete){
                        current_edge -> next = tmp -> next;
                        _free_edge(tmp);
                    }

                    current_edge = current_edge -> next;

                }
            }
        }


        current2 = current2 -> next_vertex;
    }

    _free_vertex(to_delete);
    --(g -> vertex_count);

    return;

}


/*
 * finds a vertex given the data and the graph teh vertex  should be in
 * returns null if no vertex found
 */

struct vertex * get_vertex(struct graph *g, struct map *data)
{

    if (g == 0){
        printf("graph not found. get_vertex() failed.");
    }

    if (data == 0){
        printf("data doesn't exist. get_vertex() failed.");

    }

    //traverse the graph's list of vertices until we find the node, return it
    struct vertex *current = g -> vertex_head;
    while(current){

        if (current -> data == data){
            return current;
        }

        current = current -> next_vertex;

    }

    return 0;

}

/*
 * modifies the vertex given the new data, deletes old node from graph g and adds new one to g
 */
void modify_vertex(struct graph *g, struct map *old, struct map *new)
{

    if(g == 0){
        printf("graph not found. modify_vertex() failed.");
        return ;
    }

    if(old == 0){
        printf("no old data. modify_vertex() failed.");
        return ;
    }

    if (new == 0){
        printf("no new data. modify_vertex() failed.");
        return ;
    }

    delete_vertex(g, old);
    add_vertex(g, new);

    return;

}

/*
 * add edge function, creates a new edge between two edges, only does it one way
 * it will make the edge from g to v
 *
 */
void _add_edge(struct graph *g, struct map *v, struct map *f, char *data)
{

    if (g == 0){
        printf("graph not found. failed at add_edge().");
        return;
    }
    if (v == 0 || f == 0){
        printf("map not found, invalid data. failed at add_edge().");
        return;

    }


    if(!get_vertex(g,v)) { add_vertex(g,v); }
    if(!get_vertex(g,f)) { add_vertex(g,f); }

    //this will find the edges in the graph and return them
    struct vertex *v_vertex = get_vertex(g, v);
    struct vertex *f_vertex = get_vertex(g, f);

    int i = _find_edge(g, v, f);
    if (i == 0){
        //go through each of the edge lists
        struct edge *new_edge_v = _new_edge(v_vertex, f_vertex, data);
        //all the edges for that vertex
        struct edge *v_edges = v_vertex -> connected_edges;

        if(v_vertex -> connected_edges == 0){
            v_vertex -> connected_edges  = new_edge_v;
            ++ (g -> edge_count);
            return;
        }

        while(v_edges -> next != NULL){
            v_edges = v_edges -> next;
        }

        v_edges -> next = new_edge_v;
        }

    else{
        printf("There is already an edge between the two vertices!\n");
    }

}

void add_wedge(struct graph *g, struct map *v, char *data, struct map *f) {
    _add_edge(g, v, f, data);
}

void add_edge(struct graph *g, struct map *v, struct map *f) {
    _add_edge(g, v, f, "");
}
/*
 * deletes an edge between the two given vertices in graph g
 */
void delete_edge(struct graph *g, struct map *v, struct map *f)
{

    if (g == 0){
        printf("Graph not found. delete_edge() failed.");
        return;
    }

    if(v ==  0 || f == 0){
        printf("Maps don't exist. delete_edge() failed.");
        return;
    }

    struct vertex *v_vertex = get_vertex(g, v);
    struct vertex *f_vertex = get_vertex(g, f);

    //if either of the edges are in the graph then fail
    if (v_vertex == 0 || f_vertex == 0){
        printf("vertex not found. failed at add_edge()");
        return;
    }

    struct edge *v_edges = v_vertex -> connected_edges;
    while (v_edges -> next != 0){
        struct edge *tmp = v_edges -> next;
        if (tmp -> to == f_vertex){
            v_edges -> next = tmp -> next;
            _free_edge(tmp);
            return;
        }
        v_edges = v_edges -> next;
    }

}

int _find_edge(struct graph *g, struct map *v, struct map *f)
{

    if (g == 0){
        printf("Graph not found. find_edge() failed.");
        return 0;
    }

    if(v ==  0 || f == 0){
        printf("Maps don't exist. find_edge() failed.");
        return 0;
    }

    struct vertex *v_vertex = get_vertex(g, v);
    struct vertex *f_vertex = get_vertex(g, f);

    //if either of the vertex are in the graph then fail
    if (v_vertex == 0 || f_vertex == 0){
        printf("vertex not found. failed at find_edge()\n");
        return 0;
    }

    struct edge *v_edges = v_vertex -> connected_edges;
    while(v_edges != 0){

        if (v_edges -> to == f_vertex){
            return 1;
        }

        v_edges = v_edges -> next;

    }

    return 0;

}

void _modify_edge(struct graph *g, struct map *v, struct map *f, char *data)
{

    if (g == 0){
        printf("Graph not found. find_edge() failed.");
        return ;
    }

    if(v ==  0 || f == 0){
        printf("Maps don't exist. find_edge() failed.");
        return ;
    }

    struct vertex *v_vertex = get_vertex(g, v);
    struct vertex *f_vertex = get_vertex(g, f);

    //if either of the edges are in the graph then fail
    if (v_vertex == 0 || f_vertex == 0){
        printf("vertex not found. failed at add_edge()");
        return ;
    }

    struct edge *v_edges = v_vertex -> connected_edges;
    while(v_edges != 0){

        if (v_edges -> to == f_vertex){
            v_edges -> data = data;
            return;
        }

        v_edges = v_edges -> next;

    }

}

/*
 * This will create a new graph that has the nodes that are in both
 * g and h. The nodes are not connected.
 */
struct graph * intersection_graph(struct graph *g, struct graph *h)
{

    if (g == 0 || h == 0){
        printf("Graph doesn't exist. intersection_graphs() failed.");
        return 0;
    }

    struct graph *i = new_graph();

    // if either graphs are empty, return the new empty graph
    if (g -> vertex_count == 0 ||  h -> vertex_count == 0){
        return i;
    }

    struct vertex *current = g -> vertex_head;

    while (current){

        struct map *d = current -> data;

        if (get_vertex(h, d)){
            add_vertex(i, d);
        }

        current = current -> next_vertex;
    }

    return i;
}

/*
 * Union of two graphs, returns a new graph with all the nodes in both graphs,
 * unconnected.
 */
struct graph * union_graph(struct graph *g, struct graph *h)
{

    if (g == 0 || h == 0){
        printf("Graph doesn't exist. union_graphs() failed.");
        return 0;
    }

    struct graph *i = new_graph();

    //if both graphs are empty, return the new empty graph
    if (g -> vertex_count == 0 && h -> vertex_count == 0){
        return i;
    }

    struct vertex *current_g = g -> vertex_head;
    struct vertex *current_h = h -> vertex_head;

    while (current_g){
        add_vertex(i, current_g -> data);
        current_g = current_g -> next_vertex;
    }

    while (current_h){
        if (!get_vertex(i, current_h -> data)){
            add_vertex(i, current_h -> data);
        }
        current_h = current_h -> next_vertex;

    }

    return i;
}

/*
 * Adds the two given graphs together and returns resulting graph.
 */
struct graph * add (struct graph *g, struct graph *h){

    if (g == 0 || h == 0){
        printf("Graph doesn't exist. union_graphs() failed.");
        return 0;
    }

    struct graph *i = new_graph();

    //if both graphs are empty, return the new empty graph
    if (g -> vertex_count == 0 && h -> vertex_count == 0){
        return i;
    }

    struct vertex *current_g = g -> vertex_head;
    struct vertex *current_h = h -> vertex_head;

    while (current_g){
        add_vertex(i, current_g -> data);
        current_g = current_g -> next_vertex;
    }

     while (current_h){
        add_vertex(i, current_h -> data);
        current_h = current_h -> next_vertex;
    }

    return i;

}


/*
 * Given a graph and a node, return all the edges given that node.
 */
struct list *_get_edges(struct graph *g, struct map *data){

    if (g == 0){
        printf("Graph doesn't exist. union_graphs() failed.");
        return 0;
    }

    if (data == 0){
        printf("Data doesn't exist. get_edges() failed.");
    }

    struct vertex *current_vertex = get_vertex(g, data);

    struct list *edges_queue = make_list();
    struct edge *current_edge = current_vertex -> connected_edges;
    while(current_edge){
        add_tail(edges_queue, current_edge -> data);
        current_edge = current_edge -> next;
    }
    return edges_queue;
}

/*
 * Given a graph and a node, return the list of vertices that the vertex given connected to.
 */
struct list *get_edge_neighbors(struct graph *g, struct map *data){

    if (g == 0){
        printf("Graph doesn't exist. union_graphs() failed.");
        return 0;
    }
    if (data == 0){
        printf("Data doesn't exist. get_edges() failed.");
    }

    struct vertex *current_vertex = get_vertex(g, data);

    struct list *edges_queue = make_list();
    struct edge *current_edge = current_vertex -> connected_edges;
    while(current_edge){
        add_tail(edges_queue, current_edge->to->data);
        current_edge = current_edge -> next;
    }
    return edges_queue;

}

struct list *get_all_vertices(struct graph *g){

    struct list *all_vertices = make_list();

    struct vertex *v = g -> vertex_head;

    while(v != 0){
        add_tail(all_vertices, v->data);
        v = v -> next_vertex;
    }

    return all_vertices;

}

/*
 * prints out all the edges and nodes of a graph
 */
void printg(struct graph *g){


    struct vertex *v = g -> vertex_head;

    while (v){
        struct map *tmp = v->data;

        printf("%s", "vertex data:\n");
        print_vertex(tmp);


        _print_edge(v -> connected_edges);

        v = v -> next_vertex;

        printf("\n");

    }

}

void print_vertex(struct map *m){

	struct map_node *current = m->node_head;
	while (current != NULL) {

		printf("\"%s\" : \"%s\"", current->key, current->value);
		if (current->next != NULL)
			printf(" , ");
		else
			printf("\n");
		current = current->next;
	}

}

void _print_edge(struct edge *e){

    if (e){
        while(e != 0){
            printf("%s: %s\n", "Edge data", e->data);
            printf("Connected to: ");
            print_vertex(e->to->data);

            e = e -> next;

        }
    }
}


/*
 * Graph clean up functions.
 */

void _clean_graph(struct graph *G){
    if(G == NULL)
    {
        printf("Are you seriously trying to free a null graph?\n");
        return;
    }
    _free_all_vertex(G);
    free(G);

}

void _free_vertex(struct vertex *v){
    if(v){
        v -> next_vertex = 0;
        _free_edge(v -> connected_edges);
        free_map(v -> data);
        free(v);
    }

}


void _free_edge(struct edge* e){

    if(e){

        e -> to = 0;
        e -> from = 0;
        free(e);

    }
}

void _free_all_vertex(struct graph *g)
{

    struct vertex * current = g -> vertex_head;
    while(current)
    {
        struct vertex *tmp = current;
        _free_adjacency_row(current);
        current = current -> next_vertex;
        _free_vertex(tmp);
    }

}


void _free_adjacency_row(struct vertex *V)
{

    struct edge * current = V -> connected_edges;
    while(current)
    {
        struct edge *tmp = current;
        current = current -> next;
        _free_edge(tmp);

    }
}


/*
 * LIST METHODS
 */

/*
 * Initializes an empty list.
 */
struct list * make_list() {

	struct list *l;
	l = malloc(sizeof(struct list));
	if (l == NULL)
		return NULL;

	l->size = 0;
        l->head = 0;
	return l;
}

/*
 * Returns the size of a list.
 */
int size(struct list *l) {

	return l->size;
}

/*
 * Returns the element at index i of the list.
 */
void * list_get(struct list *l, int i) {

	if (l->head == NULL || i >= l->size || i < 0)
		return NULL;

	struct list_node *current = l->head;
	int j = 0;
	while (j != i) {
		current = current->next;
                ++j;
	}

	return current->data;
}

/*
 * Sets the element at index i to data.
 * Will return 1 if successful (valid i)
 * and 0 otherwise.
 */
int set(struct list *l, int i, void *data) {

	if (l->head == NULL || i >= l->size || i < 0)
		return 0;

	struct list_node *current = l->head;
	int j = 0;
	while (j != i) {
		current = current->next;
        ++j;
	}

	current->data = data;
	return 1;
}

/*
 * Adds to the front of the list.
 * Returns a 1 if successful and 0 otherwise.
 */
int add_head(struct list *l, void *data) {

	struct list_node *node = (struct list_node *)malloc(sizeof(struct list_node));
	if (node == NULL)
		return 0;

	node->data = data;
	node->next = l->head;
	l->head = node;
	++l->size;
	return 1;
}

/*
 * Adds to the end of the list.
 * Returns a 1 if successful and 0 otherwise.
 */
int add_tail(struct list *l, void *data) {

	struct list_node *node = (struct list_node *)malloc(sizeof(struct list_node));
	if (node == NULL) {
		return 0;
	}
	node->data = data;
	node->next = NULL;

	/* if the list is empty, this node is the head */
  if (l->head == NULL) {
      ++l->size;
		  l->head = node;
		  return 1;
  }
	struct list_node *current = l->head;
	while (current->next != NULL) {
		current = current->next;
	}

	/* current is now the last node in the list */
	current->next = node;
	++l->size;
	return 1;
}

/*
 * Returns data from the head of the list and removes it.
 */
void * remove_head(struct list *l) {

	if (l->head == NULL)
		return NULL;

	struct list_node *oldHead = l->head;
	l->head = oldHead->next;
	void *data = oldHead->data;
	free(oldHead);
	l->size -= 1;
	return data;
}

/*
 * Returns data from the tail of a list and removes it.
 */
void * remove_tail(struct list *l) {

	if (l->head == NULL)
		return NULL;

	if (l->head->next == NULL) {
		return remove_head(l);
	}

	struct list_node *slow = l->head;
	struct list_node *fast = l->head->next;

	while (fast->next != NULL) {
		slow = fast;
		fast = fast->next;
	}

	/* slow is now the second to last node in the list */
	void *data = fast->data;
	slow->next = NULL;
	l->size -= 1;
	free(fast);
	return data;
}

/*
 * Prints out list of elements in a list.
 * Used for testing.
 */
void printl(struct list *l) {

	printf("[");
	struct list_node *current = l->head;
	while (current != NULL)
        {
            if(current -> next == NULL)
            {
                printf("%d", *(int *) current -> data);
            }
            else
            {
                printf("%d,", *(int *)current->data);
            }
            current = current->next;
	}

	printf("]\n");
}

/*
 * Build a new list that is concatenating two lists.
 */
struct list * concat(struct list * a, struct list * b) {
	struct list *  new_list = make_list();
	struct list_node * current = a -> head;
	while (current) {
		add_tail(new_list, current -> data);
		current = current -> next;
	}
	current = b -> head;
	while(current) {
		add_tail(new_list, current -> data);
		current = current -> next;
	}
	return new_list;

}

/* For use of primitive int casted to void * for generic linked list*/
int add_head_int (struct list * l, int data)
{
    int * d = malloc(sizeof(int));
    *d = data;
    return add_head(l, d);
}

int add_tail_int (struct list * l, int data)
{
    int * d = malloc(sizeof(int));
    *d = data;
    return add_tail(l, d);
}

int list_get_int(struct list * l, int index)
{
    void * answer = list_get(l, index);
    return *(int *) answer;
}

int list_set_int(struct list * l, int index, int E)
{
    int answer = list_get_int(l, index);
    int * d = malloc(sizeof(int));
    *d = E;
    set(l, index, (void *) d);
    return answer;
}

int remove_head_int(struct list * l)
{
    void * answer = remove_head(l);
    return *(int *) answer;
}

int remove_tail_int(struct list * l)
{
    void * answer = remove_tail(l);
    return *(int *) answer;
}

/* For use of linked list using doubles*/
int add_head_dec (struct list * l, double data)
{
    double * d = malloc(sizeof(double));
    *d = data;
    return add_head(l, d);
}

int add_tail_dec (struct list * l, double data)
{
    double * d = malloc(sizeof(double));
    *d = data;
    return add_tail(l, d);
}

double list_get_dec(struct list * l, int index)
{
    void * answer = list_get(l, index);
    return *(double *) answer;
}

double list_set_dec(struct list * l, int index, double E)
{
    double answer = list_get_dec(l, index);
    double * d = malloc(sizeof(double));
    *d = E;
    set(l, index, (void *) d);
    return answer;
}

double remove_head_dec(struct list * l)
{
    void * answer = remove_head(l);
    return *(double *) answer;
}

double remove_tail_dec(struct list * l)
{
    void * answer = remove_tail(l);
    return *(double *) answer;
}

/* For use of linked list using strings*/
int add_head_str (struct list * l, char * data)
{
    /*char * d = malloc(strlen(data));
    d = data;*/
    return add_head(l, (void *) data);
}

int add_tail_str (struct list * l, char * data)
{
    /*char * d = malloc(strlen(data));
    d = data;*/
    return add_tail(l, (void *) data);
}

char * list_get_str(struct list * l, int index)
{
    void * answer = list_get(l, index);
    return (char *) answer;
}

char * list_set_str(struct list * l, int index, char * E)
{
    char * answer = list_get_str(l, index);
    /*char * d = malloc(strlen(E));
    d = E;*/
    set(l, index, (void *) E);
    return answer;
}

char * remove_head_str(struct list * l)
{
    void * answer = remove_head(l);
    return (char *) answer;
}

char * remove_tail_str(struct list * l)
{
    void * answer = remove_tail(l);
    return (char *) answer;
}

/* For use of linked list using maps*/
int add_head_map (struct list * l, struct map * data)
{
    return add_head(l, (void *) data);
}

int add_tail_map (struct list * l, struct map * data)
{
    return add_tail(l, (void *) data);
}

struct map * list_get_map(struct list * l, int index)
{
    void * answer = list_get(l, index);
    return (struct map *) answer;
}

struct map *list_set_map(struct list * l, int index, struct map * E)
{
    struct map * answer = list_get_map(l, index);
    set(l, index, (void *) &E);
    return answer;
}

struct map * remove_head_map(struct list * l)
{
    void * answer = remove_head(l);
    return (struct map *) answer;
}

struct map *remove_tail_map(struct list * l)
{
    void * answer = remove_tail(l);
    return (struct map *) answer;
}

/* Misc functions: strops, random numbers, atoi, etc.*/
int * random_int(int minimum_number, int max_number)
{
    int * answer = malloc(sizeof(int));
    *answer = rand() % (max_number + 1 - minimum_number) + minimum_number;
    return answer;
}

char * myItoa(int num)
{
    char * result = malloc(sizeof(char) * 50);
    sprintf(result, "%d", num);
    return result;
}

int * myAtoi(char * str)
{
    int * result = malloc(sizeof(int));
    int res = 0;  // Initialize result
    int sign = 1;  // Initialize sign as positive
    int i = 0;  // Initialize index of first digit

    // If number is negative, then update sign
    if (str[0] == '-')
    {
        sign = -1;
        i++;  // Also update index of first digit
    }

    // Iterate through all digits and update the result
    for (; str[i] != '\0'; ++i)
    {
        if(str[i] == '0' || str[i] == '1' || str[i] == '2' || str[i] == '3'
                || str[i] == '4' || str[i] == '5' || str[i] == '6' ||
                str[i] == '7' || str[i] == '8' || str[i] == '9')
        {
            res = res*10 + str[i] - '0';
        }
        else
        {
            result = NULL;
        }
    }
    // Return result with sign
    *result = sign*res;
    return result;
}

char * concat_string(char * a, char * b)
{
    char * c = malloc(strlen(a) + strlen(b) + 1);
    sprintf(c, "%s%s", a, b);
    c[strlen(a) + strlen(b)] = '\0';
    return c;
}

int length(char * s)
{
    return strlen(s);
}

int str_comp(char * a, char * b)
{
    int ans = strcmp(a, b);
    //fprintf(stderr, "Didn't seg yet: %d\n", ans);
    return (ans == 0);
}

// Ocaml views chars as ints. Ocaml should have a convert back! C.decode()?
// See Ocaml Char module!
char * get_char(char * s, int idx)
{
    int size = strlen(s);
    if(idx < 0 || idx > size)
    {
        return NULL;
    }
    else
    {
	char * i = malloc(sizeof(char) * 2);
	i[0] = s[idx];
	i[1] = '\0';
        return i;
    }
}

