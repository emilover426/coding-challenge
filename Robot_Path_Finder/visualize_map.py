# usage:  python visualize_map.py obstacles_file start_goal_file

from __future__ import division
import matplotlib.pyplot as plt
from matplotlib.path import Path
import matplotlib.patches as patches
import matplotlib.lines as lines
import numpy as np
import random, math
from shapely.geometry import LineString
from shapely.geometry.polygon import Polygon
from shapely.geometry import Point
from sklearn.neighbors import NearestNeighbors
from scipy import spatial
from scipy.sparse.csgraph import shortest_path

'''
Visualize the map:
obstacle_path is a file containing vertices. ax is the plot.
'''
def build_obstacle_course(obstacle_path, ax):
    vertices = list()
    codes = [Path.MOVETO]
    with open(obstacle_path) as f:
        quantity = int(f.readline())
        lines = 0
        for line in f:
            coordinates = tuple(map(int, line.strip().split(' ')))
            if len(coordinates) == 1:
                codes += [Path.MOVETO] + [Path.LINETO]*(coordinates[0]-1) + [Path.CLOSEPOLY]
                vertices.append((0,0)) #Always ignored by closepoly command
            else:
                vertices.append(coordinates)
    vertices.append((0,0))
    vertices = np.array(vertices, float)
    path = Path(vertices, codes)
    pathpatch = patches.PathPatch(path, facecolor='None', edgecolor='xkcd:violet')

    ax.add_patch(pathpatch)
    ax.set_title('Sample-Based Motion Planning')

    ax.dataLim.update_from_data_xy(vertices)
    ax.autoscale_view()
    ax.invert_yaxis()

    return path

'''
Draws start and goal points to the plot:
    start_goal_path is a file containing start and goal coordinates.
    ax is the plot.
Returns the start and goal coordinates
'''
def add_start_and_goal(start_goal_path, ax):
    start, goal = None, None
    with open(start_goal_path) as f:
        start = tuple(map(int, f.readline().strip().split(' ')))
        goal  = tuple(map(int, f.readline().strip().split(' ')))

    ax.add_patch(patches.Circle(start, facecolor='xkcd:bright green'))
    ax.add_patch(patches.Circle(goal, facecolor='xkcd:fuchsia'))

    return start, goal

'''
Create a 3D list of vertices. Each item in the list is an obstacle,
and each coordinate pair in an obstacle is a vertex.
'''
def load_obstacles(object_path):
    obstacles = []
    obstacle = []
    with open(object_path) as f:
        numObstacles = int(f.readline())
        coordinates = int(f.readline())
        for i in range(coordinates):
            line = f.readline()
            obstacle.append(tuple(map(int, line.strip().split(' '))))
        for line in f:
            coordinates = tuple(map(int, line.strip().split(' ')))
            if len(coordinates) == 1:
                obstacles.append(obstacle)
                obstacle = []
            else:
                obstacle.append(coordinates)
    obstacles.append(obstacle)
    assert len(obstacles)==numObstacles, "number of obstacles does not match the first line"
    return obstacles

'''
Returns True if a line intersects an obstacle. Else False.
'''
def hasCollision(line, obstacles):
    line_string = LineString([(line[0][0],line[0][1]),(line[1][0],line[1][1])])
    for obstacle in obstacles:
        polygon = Polygon(obstacle)
        polygon_small = polygon.buffer(-.01)
        if line_string.intersects(polygon_small):
	        return True
    return False

''' Returns a node's K Nearest Neighbors from a set of candidate nodes'''
def kNeighbors(q, V_2d, k):
    if len(V_2d) < k: raise ValueError
    q = list(q)
    n_obj = NearestNeighbors(n_neighbors=k)
    n_obj.fit(V_2d)
    k_indexes = n_obj.kneighbors([q], return_distance=False).tolist()
    return [tuple(V_2d[x]) for x in k_indexes[0] if V_2d[x]!=q]

''' Returns lines that represent the shortest path from start to goal.'''
def get_shortest_path(vertices, edges,start,goal):
  #build adjacency matrix
    vertices = list(vertices)
    vertices.append(start)
    vertices.append(goal)
    edges = list(edges)
    v_len = len(vertices)
    m = np.zeros(shape=(v_len,v_len))
    for i in range(v_len):
    	for j in range(v_len):
    		u = vertices[i]
    		v = vertices[j]

    		if (u,v) in edges or (v,u) in edges:
    			m[i][j] = spatial.distance.euclidean(u,v)
    		else:
    			m[i][j] = 0
    D, Pr = shortest_path(m,directed=False,method='D', return_predecessors=True)
    path = get_path(Pr,v_len-2,v_len-1)
    path_vs = [vertices[i] for i in path]
    line_array = make_lines(path_vs,connect=False)
    return line_array

'''Returns a list of nodes that describe the path between i and j '''
def get_path(Pr,i,j):
	path = [j]
	k = j
	while Pr[i,k] != -9999:
		path.append(Pr[i,k])
		k = Pr[i,k]

	return path[::-1]

def make_lines(obstacle_vertices,connect=True):
    lines = []
    for i,vertex in enumerate(obstacle_vertices):
        if i < len(obstacle_vertices)-1:
            lines.append([obstacle_vertices[i],obstacle_vertices[i+1]])
        else:
            if connect:
                lines.append([obstacle_vertices[i],obstacle_vertices[0]])
    return lines

'''
Builds the PRM given obstacles, start, goal, number of nodes, k-Nearest
neighbors, and a plot.
Draws the shortest path from start to goal.
Returns the set of nodes V and set of edges E.
'''
def build_prm(obstacles,start,goal,n,k,ax):
    #prm algo
    v = set()
    e = set()
    while len(v) < n:
        x = random.randint(0,600)
        y = random.randint(0,600)
        point = Point(x,y)
        #delect collisions
        no_collisions = []
        for obstacle in obstacles:
            polygon = Polygon(obstacle)
            if not polygon.contains(point):
                no_collisions.append(True)
            else:
                no_collisions.append(False)
        if all(no_collisions):
            v.add((x,y))
    #find neighbors
    V_2d = [list(coord) for coord in v]
    for q in v:
        n_q = kNeighbors(q,V_2d,k)
        for q_prime in n_q:
            if (q,q_prime) not in e and hasCollision([q,q_prime],obstacles)==False:
                e.add((q,q_prime))

    #connect start and goal points to nearest q in v
    closest_to_start = kNeighbors(start,V_2d,len(V_2d))
    closest_to_goal = kNeighbors(goal,V_2d,len(V_2d))
    for q in closest_to_start:
        if hasCollision([q,start],obstacles)==False:
            e.add((q,start))
            break
    for q in closest_to_goal:
        if hasCollision([q,goal],obstacles)==False:
            e.add((q,goal))
            break

    #draw the graph
    for edge in e:
        (line_xs,line_ys) = zip(*edge)
        ax.add_line(lines.Line2D(line_xs,line_ys,linewidth=1,color='red'))

    #find shortest path and highlight it
    shortest_path = get_shortest_path(v,e,start,goal)
    for edge in shortest_path:
        (line_xs,line_ys) = zip(*edge)
        ax.add_line(lines.Line2D(line_xs,line_ys,linewidth=3,color='blue'))

    return v,e



if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('obstacle_path',
                        help="File path for obstacle set")
    parser.add_argument('start_goal_path',
                        help="File path for obstacle set")
    args = parser.parse_args()

    fig, ax = plt.subplots()
    path = build_obstacle_course(args.obstacle_path, ax)
    start, goal = add_start_and_goal(args.start_goal_path, ax)
    obstacles = load_obstacles(args.obstacle_path)
    n = 200
    k = 50
    v, e = build_prm(obstacles,start,goal,n,k,ax)
    plt.plot()
    title = "prm: n="+str(n)+" k="+str(k)
    ax.set_title(title)
    plt.show()
