#ifndef GRAPH_H
#define GRAPH_H

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

/*
 * MAP METHODS
 */

/*
 * Map node declaration.
 */
struct map_node {
	char *key;
	char *value;
	struct map_node *next;
};

/*
 * Map declaration.
 */
struct map {
	struct map_node *node_head;
	int size;
};

/*
 * Initializes a map.
 */
struct map * make_map();

/*
 * Puts a key-value pair into a map.
 * Returns a 1 if successful and 0 otherwise.
 */
int put(struct map *m, char *key, char *value);

/*
 * Gets a value from a map given a key.
 */
char * map_get(struct map *m, char *key);

/*
 * Returns 1 if a key is found in a map
 * and 0 otherwise.
 */
int contains_key(struct map *m, char *key);

/*
 * Returns 1 if a value is found in a map
 * and 0 otherwise.
 */
int contains_value(struct map *m, char *value);

/*
 * Removes a node from a map.
 * Returns a 1 if successful and 0 otherwise.
 * (e.g. empty list, list does not contain key)
 */
int remove_node(struct map *m, char *key);

/*
 * Compares two maps for equality.
 */
int is_equal(struct map *m1, struct map *m2);

/*
 * Frees allocated memory for a map.
 */
void free_map(struct map *m);

/*
 * Prints out map in specified format:
 * {
 *	"michal" : "language guru",
 * 	"emily" : "tester"
 * }
 */
void printm(struct map *m);


/*
 * GRAPH METHODS
 */

struct edge {

    struct vertex *from;
    struct vertex *to;
    struct edge *next;
    char *data;

};

struct vertex {

    struct edge *connected_edges;
    struct vertex *next_vertex;
    struct map *data; /*should this be a void pointer or a struct map pointer */

};

struct graph {

    int vertex_count;
    int edge_count;
    struct vertex *vertex_head;

};


/*
 * creates a new graph
 */
struct graph * new_graph();

/*
 * makes and returns new vertex with data passed in
 */
struct vertex * new_vertex(struct map *data);

/*
 * creates new struct from a to b with the input data
 */
struct edge * new_edge(struct vertex *a, struct vertex *b, char *data);

/*
 * decides whether to call modify vertext or delete vertex *
 */
void modify_graph(struct graph *g, struct map *from, char *data, struct map *to, int dec);

/*
 * create a new vertex with map data and adds it to g, returns vertex created
 */
void add_vertex(struct graph *g, struct map *data);

/*
 * removes the vertex from graph g and returns it
 */
void delete_vertex(struct graph *g, struct map *data);

/*
 * finds the vertex given the map and returns it, returns null if nothing found
 */
struct vertex * get_vertex(struct graph *g, struct map *data);

/*
 * modifies the vertx given the new data –
 * deletes the old node from graph g and adds new graph into g
 */
void modify_vertex(struct graph *g, struct map *old, struct map *new);


/*
 * adds new edge of given data between two given nodes
 */
void _add_edge(struct graph *g, struct map *a, struct map *b, char *data);

/*
 * adds new edge with empty data
 */
void add_edge(struct graph *g, struct map *a, struct map *b);

/*
 * adds new edge with given data
 */
void add_wedge(struct graph *g, struct map *a, char *data, struct map *b);

/*
 * deletes an edge given the two nodes the edge is between
 */
void delete_edge(struct graph *g, struct map *from, struct map *to);

/*
 * checks if the edge between two given verticies in graph g exists
 * returns a boolean – 1 if yes, 0 if no
 */
int _find_edge(struct graph *g, struct map *from, struct map *to);

/*
 * modifies edge between two verticies in graph g by deleting the edge
 * and creating a new edge for it to be in between
 */
void _modify_edge(struct graph *g, struct map *v, struct map *f, char *data);

/*
 * intersection
 */
struct graph * intersection_graph(struct graph *g, struct graph *h);

/*
 * union
 * */
struct graph * union_graph(struct graph *g, struct graph *h);

/*
 * adds the two given graphs together and returns resulting graph
 */
struct graph * add (struct graph *g, struct graph *h);

/*
 * given a graph and a node, return all the edges given that node
 */
struct list * _get_edges(struct graph *g, struct map *data);

/*
 * get all the nodes of a graph
 */
struct list * get_all_vertices(struct graph *g);

struct list * get_edge_neighbors(struct graph *g, struct map *data);

/*
 * print functions
 */
void printg(struct graph *g);
void _print_edge(struct edge *e);
void print_vertex(struct map *m);


/* Clean up methods */
void _clean_graph(struct graph *G);
void _free_adjacency_row(struct vertex *V);
void _free_all_vertex(struct graph *g);
void _free_vertex(struct vertex *v);
void _free_edge(struct edge *e);

/*
char * to_string(int i) {
    char buffer[20];
    sprintf(buffer,"%d",i);
    return buffer;
}

int to_int(char *s) {
    return atoi(s);
}

int randint(int low, int high) {
    return rand() % (high + 1 - low) + low
}
*/

/*
 * LIST METHODS
 */

/*
 * A node in a linked list.
 */

union data_type {
    int i;
    float f;
    char * s;
    struct map * m;
};

struct list_node {
    void * data;
    //union data_type d;
    struct list_node * next;
};

/*
 * A linked list.
 * 'head' points to the first node in the list.
 *
 * This will be called generically as in
 * list<int> data;
 * list<map> data;
 */
struct list {
    int size;
    struct list_node * head;
};

/*
 * Initializes an empty list.
 */
struct list * make_list();

/*
 * Returns the size of a list.
 */
int size(struct list *l);

/*
 * Returns the data of element at index i of the list.
 */
void * list_get(struct list *l, int i);

/*
 * Sets the element at index i to data.
 * Will return 1 if successful (valid i)
 * and 0 otherwise.
 */
int set(struct list *l, int i, void *data);

/*
 * Adds to the front of the list.
 * Returns a 1 if successful and 0 otherwise.
 */
int add_head(struct list *l, void *data);

/*
 * Adds to the end of the list.
 * Returns a 1 if successful and 0 otherwise.
 */
int add_tail(struct list *l, void *data);

/*
 * Returns data from the head of the list and removes it.
 */
void * remove_head(struct list *l);

/*
 * Returns data from the tail of a list and removes it.
 */
void * remove_tail(struct list *l);

/*
 * Frees allocated memory for a list.
 */
void free_list(struct list *l);

/*
 * Prints out list of elements in a list.
 */
void printl(struct list *l);

/*
 * Build a new list that is concatenating two lists
 */
struct list * concat(struct list * a, struct list * b);

/* Testing the int casting to void!*/
int list_get_int (struct list * l, int index);
int list_set_int (struct list * l, int index, int E);
int add_head_int (struct list * l, int data);
int remove_head_int (struct list * l);
int add_tail_int (struct list * l, int data);
int remove_tail_int (struct list * l);

/* Use for double/decimals */
double list_get_dec (struct list * l, int index);
double list_set_dec (struct list * l, int index, double E);
int add_head_dec (struct list * l, double data);
double remove_head_dec (struct list * l);
int add_tail_dec (struct list * l, double data);
double remove_tail_dec (struct list * l);

/* Use for strings */
char * list_get_str (struct list * l, int index);
char * list_set_str (struct list * l, int index, char * E);
int add_head_str (struct list * l, char * data);
char * remove_head_str (struct list * l);
int add_tail_str (struct list * l, char * data);
char * remove_tail_str (struct list * l);

/* Use for maps */
struct map * list_get_map (struct list * l, int index);
struct map * list_set_map (struct list * l, int index, struct map * E);
int add_head_map (struct list * l, struct map * data);
struct map * remove_head_map (struct list * l);
int add_tail_map (struct list * l, struct map * data);
struct map * remove_tail_map (struct list * l);

/* Misc Methods. Strops, atoi, etc. */
int * random_int(int minimum_number, int max_number);
char * myItoa(int num);
int * myAtoi(char * str);
char * concat_string(char * a, char * b);
int length(char * s);
int str_comp(char * a, char * b);

// Ocaml views chars as ints. Ocaml should have a convert back! C.decode()?
// See Ocaml Char module!
char * get_char(char * s, int idx);

#endif
