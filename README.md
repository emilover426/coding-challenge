
# Critical Mass Developer Interview Assignment
Emily Hao

## Work and Project Examples
Here are three examples of programming projects I have worked on and completed recently.

### Guess the Word!
As a final project for User Interface Design, my team and I created a word guessing game. Two players take turns writing a sentence, choosing three gifs to replace a word with, and guessing what the hidden word is based on the gif. We used the GIPHY API and bootstrapping templates. The focus of the assignment was creating a user-friendly interface that followed Nielson's 10 Usability Heuristics. For example, to prevent user error, if a player tries to select less than 3 gifs, the "Select" button will shake, indicating system status and preventing error. Game instructions are in the User Manual. The user scenarios, prototype design, and implementation process are detailed in the Development Document. The Development Document also contains a heuristic evaluation and more information about design choices.  

To play the game yourself, download the GuessTheWord directory and open 'welcome.html'.

My role in this project was to create a prototype on myBalsamiq, conduct testing with the prototype, and implement the second, or guessing, player's actions. More specifically, I focused on displaying the gifs one at a time, allowing the second player to guess the hidden word, and determining if the guess is right. This task required me to learn more about Javascript and how I can use it make interactive elements on an HTML webpage. Some challenges I encountered were asynchronous calls to the API and code organization. Also, this project demanded good communication; multiple components implemented by each teammate had to be integrated properly.

### Compiler for Graphiti
Graphiti is a programming language designed to support graph algorithms. It seeks to simplify initializing graphs, creating and removing edges and nodes, and traverse the graph, and conduct queries. My team and I designed Graphiti. We wrote a compiler in OCAML that compiles programs written in Graphiti for them to be run. The compiler consisted of a Scanner, Parser, AST, SAST, Semantic Checker, Code Generation, and C Library. After Code Generation outputted an LLVM module that could then be interpreted by the machine. Extensive testing was implemented.

In the Graphiti directory, there is a Language Proposal, a Final Report, folders containing code samples, and a folder named 'semantics' that contains all of our code. In 'semantics', there is a 'test' folder containing Graphiti programs that were used for testing. Compiling your own Graphiti program is not possible right now, but example programs are included in the Language Proposal.

My role was the Tester. My main responsibility was to write a testing script and test programs. In addition, I implemented Maps in Graphiti from the Scanner/Parser stages to Code Generation. For comprehensive testing, I sought to include every element in Graphiti. To implement Maps, I had to become familiar with OCAML, a language that was very different from languages I knew. Also, writing a compiler entailed understanding the semantic construction and the theory behind programming languages. Because this project was semester long and involved many components, challenges included team communication, GitHub, and working through a virtual machine.

Excerpts of code I contributed towards are in the directory named 'code samples'. However, none of these samples are executable.

### Probabilistic Planning
For a robotics assignment, my partner and I implemented four sampling-based methods of constructing valid configurations in a configuration space. Two of them were the basic PRM algorithm and the Bi-Directional RRT algorithm. Given start and goal states (or poses), PRM and RRT finds a valid path (or sequence of robot poses). Then, using shortest-path algorithms, we found the shortest path from start to goal.

To visualize the PRM algorithm, go to the directory named RobotPathFinder write the following in Terminal (Python 3):
```
$ python visualize_map.py world_obstacles.txt start_goal.txt
```
To visualize the bi-directional RRT algorithm, write the following:
```
$ python rrt_2.py world_obstacles.txt start_goal.txt
```

My partner and I mostly worked together on every element of the assignment. I wrote functions that built obstacle representations, detected collisions, connecting nearest nodes, as well as the general PRM and RRT functions.
In visualize_map.py:
  ```
  load_obstacles(), hasCollision(), build_prm()
  ```
In rrt_2.py:
  ```
  RRT.build_rrt(), RRt.get_nearest().
  ```

A large component of this assignment was the most efficient and simplest ways to implement certain behaviors. This entailed finding existing libraries and experimenting with parameters. For example, to detect collisions, we used Shapely to build representations of obstacles and paths. We also used Scikit-learn to find neighboring nodes and Matlotlib to visualize paths. A challenge we dealt with was animating the RRT tree. This led us to create an RRT class in order to use an existing function in the Matplotlib.


## Inspiration
###

## Focus


## Coding Challenge
https://codesandbox.io/embed/kqp85932v  
