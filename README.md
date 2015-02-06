# GameOfLife
Simulation of game of life

#Download at: 
https: https://github.com/adhroso/GameOfLife.git
or 
git clone git@github.com:adhroso/GameOfLife.git

Game of life simulation allows a user to create rules and observe different
outcomes between predator and prey. In this simple simulation, we have very basic rules
in which govern the survival of both the predator and prey, in other words alive or dead.

The basic rules are binary, i.e. cells in the grid is represented alive or dead at any given time.
If a cell is alive, then it stay alive if and only if there are exactly three other alive cells.
An alive cell can die if there are less than two or more than 4 alive neighboring cells.
However, a cell can become alive if exactly three alive neighboring cells are present.

One aspect of data visualizations or simulation is the pre-processing of the data. In this 
version game of life is re-implemented from the original version (Conway https://processing.org/examples/gameoflife.html)
employing multithreading. In addition, we modified the environment to simulate multi
geolocations where each location is identified as by its own color (dead cells are the same color
in all locations). This generic implementation allows one to conduct biological simulation 
at molecular level (such as cellular functions) to environmental such as tracking the migration of 
one or more species. Migration is currently is not supported as it is in the beta state 
(see iteration() function for more information).
User is allowed to interact with the simulation by clicking the space bar (once the simulation has started).
When simulation is paused, user can click the C button from the keyboard to clear the 
cells, or R to reset their states. In addition, user can modify the cell by clicking directly 
on the cell, turning them off or on.

Current implementation allows only two states, alive and dead. Future implementation should
abstract the cell in order to support many features without modification of the code
(such as illness...etc).
 
It is noteworthy to mention that this is a prototype and meant only as a proof of concept 
and not be used in a production environment. 

See original version Conway at: https://processing.org/examples/gameoflife.html

#how to run
0. Download or clone the repository from github
1. unzip 
2. Open Processing
3. Via Processing, click open and navigate to the unzipped location.
4. Select the game_of_life.pde and click open.
5. Processing will warn you source file not being in a sketcher directory. Click OK.
6. Click the run button
