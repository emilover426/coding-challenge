from __future__ import division
import visualize_map
import matplotlib.pyplot as plt
from matplotlib.path import Path
import matplotlib.patches as patches
import matplotlib.lines as lines
import matplotlib.animation as animation
import numpy as np
import random, math
from shapely.geometry import LineString
from shapely.geometry.polygon import Polygon
from shapely.geometry import Point
from sklearn.neighbors import NearestNeighbors
from scipy import spatial
from scipy.sparse.csgraph import shortest_path


class RRT():

    def __init__(self,obstacles,start,goal,n,ax,fig,sigma):

        self.obstacles = obstacles
        self.start = start
        self.goal = goal
        self.n = n
        self.sigma = sigma

        # set default to tree 1
        self.whichTree = 1

        self.v1 = set()
        self.v2 = set()
        self.e1 = set()
        self.e2 = set()



        self.ax = ax
        self.fig = fig

        self.v1.add(start)
        self.v2.add(goal)

        self.stop = False

        self.path_lines = []

        self.nearest_to_goal = start
        self.dist_to_goal = math.inf

        self.q_connect = None

        self.last_new = None

        self.color = "red"

    def getNearest(self,x_rand,x_last_new=None):
        ##print("in get nearest)")
        ##print("x_rand is: ", x_rand)
        #x_nearest = nearest node in G to x_rand
        x_nearest = None
        dist = math.inf
        ##print("v is: ",v)
        x_expand_towards = x_rand
        if x_last_new != None:
           # print("last new exists")
            x_expand_towards = x_last_new
        else:
           # print("no last new")
            x_expand_towards = x_rand

        vertices = self.v1 if self.whichTree == 1 else self.v2

        for node in vertices:
            ##print("node is: ", node)
            if spatial.distance.euclidean(node,x_expand_towards) < dist:
                x_nearest = node
                dist = spatial.distance.euclidean(node,x_expand_towards)
                # dist_to_goal = spatial.distance.euclidean(node,goal)
                # if dist_to_goal < self.dist_to_goal:
                #     self.dist_to_goal = dist_to_goal
                #     self.nearest_to_goal = node


            ##print("distance is: ",spatial.distance.euclidean(node,x_rand))
        #x_new is node a distance of sigma away from near in direction of qrand
        ##print("x_nearest is: ",x_nearest)
        delta_y = x_expand_towards[1] - x_nearest[1]
        delta_x = x_expand_towards[0] - x_nearest[0]
        ##print("slope :", delta_y/delta_x)
        theta = math.atan2(delta_y,delta_x)
        new_x = self.sigma*math.cos(theta)
        new_y = self.sigma*math.sin(theta)

        return (x_nearest[0]+new_x,x_nearest[1]+new_y), x_nearest

    def draw_shortest(self,point):
        self.path_lines = []
        #find shortest path and highlight it

       # print("calculating shortes path")

        vertices = self.v1 if self.whichTree == 1 else self.v2
        edges = self.e1 if self.whichTree == 1 else self.e2

        ## print(vertices, edges)

        if self.whichTree == 2:
            
            vertices = self.v1.union(self.v2)
            edges = self.e1.union(self.e2)

        short_path = visualize_map.get_shortest_path(vertices,edges,self.start,point)
        for edge in short_path:
           # print("HERE")
            line_xs,line_ys = zip(*edge)
            line = self.ax.add_line(lines.Line2D(line_xs,line_ys,linewidth=2,color='blue'))
            self.path_lines.append(line)

    def clean(self):
        if self.path_lines != []:
            for line in self.path_lines:
                line.remove()

    def build_rrt(self,i):

        if self.stop: return
        self.whichTree = (len(self.v1) + len(self.v2))%2

        vertices = self.v1 if self.whichTree == 1 else self.v2
        edges = self.e1 if self.whichTree == 1 else self.e2


        x = np.random.uniform(0,600)
        y = np.random.uniform(0,600)

        #bias
        x_rand = (x,y)
        # l = [point,goal]
        # index = np.random.choice([0,1],p=[.9,.1])
        # x_rand = l[index]
        x_new,x_nearest = self.getNearest(x_rand,self.last_new)

        ##print("x_new is : ", x_new)
        if not visualize_map.hasCollision([x_nearest,x_new],self.obstacles):
           # print("in hasCollision")
            if self.whichTree == 1:
                self.color = "red"
                self.v1.add(x_new)
                self.e1.add((x_nearest,x_new))
                self.whichTree = 0

                tmp_new, tmp_nearest = self.getNearest(x_new)
                self.whichTree = 1
                if spatial.distance.euclidean(x_new,tmp_nearest)<self.sigma:
                   # print("CONNECT")
                    if not visualize_map.hasCollision([tmp_nearest,x_new],self.obstacles):
                        self.v1.add(tmp_new)
                        self.e1.add((tmp_nearest,x_new))
                        
                        (line_xs,line_ys) = zip(*(tmp_nearest,x_new))
                        self.ax.add_line(lines.Line2D(line_xs,line_ys,linewidth=1,color=self.color))
                        self.whichTree = 2
                        self.draw_shortest(self.goal)
                        self.stop = True



            else:
                self.color = "green"
                self.v2.add(x_new)
                self.e2.add((x_nearest,x_new))

                self.whichTree = 1
                
                tmp_new, tmp_nearest = self.getNearest(x_new)
                self.whichTree = 0
                if spatial.distance.euclidean(x_new,tmp_nearest)<self.sigma:
                   # print("CONNECT")
                    if not visualize_map.hasCollision([tmp_nearest,x_new],self.obstacles):
                        self.v2.add(tmp_new)
                        self.e2.add((tmp_nearest,x_new))
                        
                        (line_xs,line_ys) = zip(*(tmp_nearest,x_new))
                        self.ax.add_line(lines.Line2D(line_xs,line_ys,linewidth=1,color=self.color))
                        self.whichTree = 2
                        self.draw_shortest(self.goal)
                        self.stop = True



            self.last_new = x_new
           # print(x_new)
            #draw new edge

            (line_xs,line_ys) = zip(*(x_nearest,x_new))
            self.ax.add_line(lines.Line2D(line_xs,line_ys,linewidth=1,color=self.color))
            #check if node is close enough to goal
            # if spatial.distance.euclidean(x_new,self.goal)<30:
            #     ##print("close to goal!")
            #     # self.stop = True
            #     # avoid calculation of shortest path on every iteration
            #     self.clean()
            #     self.draw_shortest(x_new)
        else:
            self.last_new = None

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('obstacle_path',help="File path for obstacle set")
    parser.add_argument('start_goal_path',help="File path for obstacle set")
    args = parser.parse_args()


    fig, ax = plt.subplots()

    path = visualize_map.build_obstacle_course(args.obstacle_path, ax)
    start, goal = visualize_map.add_start_and_goal(args.start_goal_path, ax)
    obstacles = visualize_map.load_obstacles(args.obstacle_path)
    rrt_obj = RRT(obstacles,start,goal,1100,ax,fig,50)
    ani = animation.FuncAnimation(rrt_obj.fig, rrt_obj.build_rrt,frames=range(1,rrt_obj.n+1),interval = 1)
    ax.set_title("2.4 Bidirectional RRT")
    plt.show()
