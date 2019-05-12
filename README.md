
# Critical Mass Developer Interview Assignment
Emily Hao

## Work and Project Examples
Here are three examples of programming projects I have worked on and completed recently.
### 1) Guess the Word!
As a final project for User Interface Design, my team and I created a word guessing game. Two players take turns writing a sentence, choosing three gifs to replace a word with, and guessing what the hidden word is based on the gif. We used the GIPHY API and bootstrapping templates. The focus of the assignment was creating a user-friendly interface that followed Nielson's 10 Usability Heuristics. For example, to prevent user error, if a player tries to select less than 3 gifs, the "Select" button will shake, indicating system status and preventing error. Game instructions are in the User Manual. The user scenarios, prototype design, and implementation process are detailed in the Development Document. The Development Document also contains a heuristic evaluation and more information about design choices.  

To play the game yourself, download the GuessTheWord directory and open 'welcome.html'.

My role in this project was to create a prototype on myBalsamiq, conduct testing with the prototype, and implement the second, or guessing, player's actions. More specifically, I focused on displaying the gifs one at a time, allowing the second player to guess the hidden word, and determining if the guess is right. This task required me to learn Javascript and how I can use it to make interactive elements on an HTML webpage. Some challenges I encountered were asynchronous calls to the API and code organization. Also, this project demanded good communication; multiple components implemented by each teammate had to be properly integrated in a short timeframe.
### 2) Compiler for Graphiti
Graphiti is a programming language designed to support graph algorithms. It seeks to simplify graph initialization, graph and node operations, graph traversal, and queries. My team and I designed Graphiti and wrote a compiler in OCAML that compiles programs written in Graphiti. The compiler consisted of a Scanner, Parser, AST, SAST, Semantic Checker, Code Generation, and C Library. Code Generation outputs an LLVM module that could then be interpreted by the machine. We also tested extensively.

In the Graphiti directory, there is a Language Proposal, a Final Report, folders containing code samples, and a folder named 'semantics' that contains all of our code. In 'semantics', there is a 'test' folder containing Graphiti programs that were used for testing. Compiling your own Graphiti program is not possible right now, but example programs are included in the Language Proposal.

My role was the Tester. My main responsibility was to write the testing script and test programs. In addition, I implemented Maps in Graphiti from the Scanner/Parser stages to Code Generation. For comprehensive testing, I sought to include every element in Graphiti. To implement Maps, I had to become familiar with OCAML, a language that was very different from the languages I knew. Also, writing a compiler entailed understanding the semantic construction and the theory behind programming languages. Because this project was semester long and involved many components, challenges included team communication, GitHub, and working through a virtual machine.

Excerpts of code I wrote are in the directory named 'code samples'. However, none of these samples are executable.
### 3) Probabilistic Planning
For a robotics assignment, my partner and I implemented four sampling-based methods of constructing valid configuration paths in a configuration space. Two of them were the basic PRM algorithm and the Bi-Directional RRT algorithm. Given start and goal states (or poses), PRM and RRT finds a valid path (or sequence of robot poses). Then, using shortest-path algorithms, we found the shortest path from start to goal.

To visualize the PRM algorithm, go to the directory named RobotPathFinder and write the following in Terminal (Python 3):
```
$ python visualize_map.py world_obstacles.txt start_goal.txt
```
To visualize the bi-directional RRT algorithm, write the following:
```
$ python rrt_2.py world_obstacles.txt start_goal.txt
```
Packages may need to imported.
Here is a link to the video of our bi-directional rapidly exploring random tree:
https://www.youtube.com/watch?v=GO9amDYSnns  

My partner and I mostly worked together on every element of the assignment. I wrote functions that built obstacle representations, detected collisions, and connected nodes. I also wrote the functions that implement PRM and bi-directional RRT.

In visualize_map.py:
  ```
  load_obstacles(), hasCollision(), build_prm()
  ```
In rrt_2.py:
  ```
  RRT.build_rrt(), RRt.get_nearest().
  ```

A large component of this assignment was figuring out the most efficient and simplest way to implement certain behaviors. This entailed finding existing libraries and experimenting with parameters. For example, to detect collisions, we used Shapely to build representations of obstacles and paths. We also used Scikit-learn to find neighboring nodes and Matlotlib to visualize paths. Another challenge we dealt with was animating the RRT tree. This led us to adjust our code and create an RRT class in order to use an existing function in Matplotlib, emphasizing the importance of flexbility.

## Inspiration
### Localization Methods for a Mobile Robot in Urban Environments
This paper details how to build a mobile robot that can model and navigate urban environments, as well as localize with a combination of sensor data and GPS. I liked how the goal of this study was to build a robot and design an algorithm that would serve a purpose. Georgiev and Allen emphasize that precise and accurate GPS localization does not work well in urban environments, so they found ways to use sensor data, computer vision, and a Kalman Filter to localize the robot. Also, they mention that there is more need for robots in unpredictable urban settings than in predictable and flat rural ones. Therefore they tackled a challenge that had implications, exploring the best ways to solve difficult problems. The paper also inspired me because of its relevance to my current coursework. It uses many robotics concepts, such as forward kinematics, mobile robots, and the Kalman filter, that I am familiar with.  
### Statistical Analysis Tech Stack: Delivery Times Intelligence
https://medium.com/azimolabs/building-a-statistical-analysis-tech-stack-5d27cd5a7ef3
Last summer, I explored and analyzed data on money transferring behavior, specifically how often and how much people transfer. We built a recency, frequency, and monetary model to segment existing customers into groups. The process, however, was not integrated into their real-time data pipeline and instead run every so often on historical transfer data in Google BigQuery. Kamil, another member of the data team, worked on using transfer-time data to provide projective transfer-time predictions and integrated that into the Azimo phone app. It also flagged times during the week when certain country-to-country transactions are like to take significantly longer. This blog post inspired me it is an example of how statistics, data analysis, and basic machine learning techniques can be used to improve a product. I realized that I could expand on my technical skills even more and really make an impact on the company's performance. I also learned more about the architecture behind Azimo's system.
### Paper on Distributed Agency in the Novel
http://xpmethod.plaintext.in/lit-mod-viz/agency.html
Dennis Yi Tenen, a guest speaker for one of my classes, often uses natural language processing techniques to analyze literature. In this paper, he seeks to create a 'model of agency'. He explores the  kinds of actions and relations literary agents have in a fictional novel and whether or not a character is necessarily a person. In his talk, Tenen emphasized that he wanted to programmatically discern entities that can be conceptualized as active role-players. His talk was inspiring because he passionately discussed how computer science can be applied to any task you wish to do. There exists an intersection of technology, math, and humanistic research, and programming is not restricted to any singular field.

## Focus
This summer, I want my intern experience to be collaborative, productive, and dynamic. I was drawn into Critical Mass's internship program description because it emphasized real-world experience through direct collaboration with developers and clients. I am eager to learn as much as possible, and see how the skills I have learned in school can develop in a working environment. Therefore, I would like to spend my time learning about the standard developer experience and the necessary skills, as well as eventually work with a team on a project that will make a difference for the company. I also would like to improve on Javascript and web development in general. I believe that with those skills, I will be able to confidently build the products that I want to build.

## Coding Challenge
https://codesandbox.io/embed/kqp85932v  
