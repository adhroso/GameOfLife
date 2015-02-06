////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Global variables
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Size of cells
int cellSize = 10;

// How likely for a cell to be alive at start (in percentage)
float probabilityOfAliveAtStart = 15;

// Variables for timer
int interval = 100;
int lastRecordedTime = 0;

// Colors for active/inactive cells
color colorAlive = color(0, 0, 255);  //positive
color colorDead = color(0,0,0);     //negative
color colorNoflyzone = color(255,255,255);    //zero (color white)

int ALIVE = 1;
int DEAD = -1;
int NOFLYZONE = 0;

// Array of cells
int[][] cells;

// Buffer to record the state of the cells and use this while changing the others in the interations
int[][] cellsBuffer; 

// Pause
boolean pause = false;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Setup and drawing functions
void setup() {
    //setup
    size (1000, 800);
    stroke(48);         // This stroke will draw the background grid
    noSmooth();
    background(0);      // Fill in black in case cells don't cover all the windows

    // Instantiate arrays and initialization of cells 
    cells = new int[width/cellSize][height/cellSize];
    cellsBuffer = new int[width/cellSize][height/cellSize];
    setInitialStates();
}


//Draw grid
void draw() {
  WorkerThread wt = new WorkerThread(1,width/cellSize-1, 1, height/cellSize-1);
  try {
    wt.start();
    wt.join();
  }  catch(IllegalThreadStateException e) {
  }  catch(InterruptedException e) {   
  }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Helper functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void simulate () {
    for (int x=1; x < width/cellSize-1; x++) {
        for (int y=1; y < height/cellSize-1; y++) {
            //set cell color
            fill(getColor(cells[x][y], x, y));
            rect (x*cellSize, y*cellSize, cellSize, cellSize);
        }
    }
    
    // Iterate if timer ticks
    if (millis()-lastRecordedTime > interval) {
        if (!pause) {
            iteration();
            lastRecordedTime = millis();
        }
    }
    interact(); 
}
/*
  Allows user to interact with the data
  User should first pause the simulation,
  then add/modify existing cells by
  clicking on the grid
*/
void interact() {
    // Create  new cells manually on pause
    if (pause && mousePressed) {
        // Map and avoid out of bound errors
        int xCellOver = int(map(mouseX, 0, width, 0, width/cellSize));
        xCellOver = constrain(xCellOver, 0, width/cellSize-1);
        int yCellOver = int(map(mouseY, 0, height, 0, height/cellSize));
        yCellOver = constrain(yCellOver, 0, height/cellSize-1);
      
        // Check against cells in buffer
        if (cellsBuffer[xCellOver][yCellOver] == ALIVE) {       // Cell is alive
            cells[xCellOver][yCellOver] = DEAD;                 // Kill
            fill(colorDead);                                    // Fill with kill color
        } else {                                                // Cell is dead
            cells[xCellOver][yCellOver] = ALIVE;                // Make alive
            fill(colorAlive);                                   // Fill alive color
        }
    } else if (pause && !mousePressed) { // And then save to buffer once mouse goes up
        // Save cells to buffer (so we opeate with one array keeping the other intact)
        for (int x=0; x < width/cellSize; x++) {
            for (int y=0; y < height/cellSize; y++) {
                cellsBuffer[x][y] = cells[x][y];
            }
        }
    }
}

/**
  Get color provided the state of a cell and quadrant
    red = 255,0,0 => 1
    purple = 146,40,144 => 2 
    yellow = 254,249,53 => 3
    brown = 169,121,70 => 4
*/
color getColor(int state, int x, int y) {
    return (state < 0) ? colorDead: (state > 0) ? (quadrant(x,y) == 1) ? color(255,0,0) : (quadrant(x,y) == 2) ? color(146,40,144) : (quadrant(x,y) == 3) ? color(254,249,53) : color(169,121,70) : colorNoflyzone;
}


color getColor(int state) {
    return (state < 0) ? colorDead: (state > 0) ? colorAlive: colorNoflyzone;
}

/**
  Initialize cells - randomly
*/
void setInitialStates() {
    // Initialization of cells
    for (int x=1; x < width/cellSize-1; x++) {
        for (int y=1; y < height/cellSize-1; y++) {
            if(x == (width/cellSize)/2 || y == (height/cellSize)/2) {
                cells[x][y] = NOFLYZONE;
            } else {
                float state = random (100); 
                cells[x][y] = (state > probabilityOfAliveAtStart) ? int(DEAD) : int(ALIVE);  
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Manipulation functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void iteration() { // When the clock ticks
    // Save cells to buffer (so we opeate with one array keeping the other intact)
    for (int x=0; x < width/cellSize; x++) {
        for (int y=0; y < height/cellSize; y++) {
            cellsBuffer[x][y] = cells[x][y];
        }
    }

    // Visit each cell:
    for (int x=0; x < width/cellSize; x++) {
        for (int y=0; y < height/cellSize; y++) {
            
            // And visit all the neighbours of each cell
            int neighbours = 0; // We'll count the neighbours
            for (int xx = x-1; xx <= x+1; xx++) {
                for (int yy=y-1; yy <= y+1; yy++) {  
                    if (((xx >= 0) && (xx < width/cellSize)) && ((yy >=0 ) && (yy < height/cellSize))) // Make sure you are not out of bounds
                        if (!((xx==x) && (yy==y)))// Make sure to to check against self
                            if (cellsBuffer[xx][yy] == ALIVE)
                                neighbours ++; // Check alive neighbours and count them
                } // End of yy loop
            } //End of xx loop
          
            // We've checked the neigbours: apply rules!
            if (cellsBuffer[x][y] == ALIVE) { // The cell is alive: kill it if necessary
                if (neighbours < 2 || neighbours > 3)
                    cells[x][y] = DEAD; // Die unless it has 2 or 3 neighbours
                else if(neighbours == 2) {
                    float prob = random(100);               
                    if(prob >= 99.5) {
                        cells[x][y] = DEAD;
                    }else {
                        cells[x][y] = ALIVE;
                    }
                }
            } 
            else if (cellsBuffer[x][y] == DEAD) {  // The cell is dead: make it live if necessary
               if (neighbours == 3)
                    cells[x][y] = ALIVE; // Only if it has 3 neighbours
            } 
        } // End of y loop
    } // End of x loop
} // End of function

void iteration(int width_begin, int width_end, int height_begin, int height_end) { // When the clock ticks
    // Save cells to buffer (so we opeate with one array keeping the other intact)
    for (int x=width_begin; x < width_end; x++) {
        for (int y=height_begin; y < height_end; y++) {
            cellsBuffer[x][y] = cells[x][y];
        }
    }

    // Visit each cell:
    for (int x=width_begin; x < width_end; x++) {
        for (int y=height_begin; y < height_end; y++) {
            
            // And visit all the neighbours of each cell
            int neighbours = 0; // We'll count the neighbours
            for (int xx = x-1; xx <= x+1; xx++) {
                for (int yy=y-1; yy <= y+1; yy++) {  
                    if (((xx >= 0) && (xx < width_end)) && ((yy >=0 ) && (yy < height_end))) // Make sure you are not out of bounds
                        if (!((xx==x) && (yy==y)))// Make sure to to check against self
                            if (cellsBuffer[xx][yy] == ALIVE)
                                neighbours ++; // Check alive neighbours and count them
                } // End of yy loop
            } //End of xx loop
          
            // We've checked the neigbours: apply rules!
            if (cellsBuffer[x][y] == ALIVE) { // The cell is alive: kill it if necessary
                if (neighbours > 3) 
                    cells[x][y] = DEAD; // 6 or more neighbours
                else if(neighbours < 2) {
                    float prob = random(100);
                    if(prob > 0.5) {
                        cells[x][y] = DEAD;
                    }else {
                        Coord coord = migrate(quadrant(x,y));  //migrate of loneliness or kill
                        cells[coord.x][coord.y] = ALIVE;
                    }
                } else if(neighbours == 2 ) {
                      cells[x][y] = DEAD;
                }
            } else if (cellsBuffer[x][y] == DEAD) {      // The cell is dead: make it live if necessary
               if (neighbours > 2 && neighbours < 4)
                    cells[x][y] = ALIVE; // Only if it has 3 neighbours
            } 
        } // End of y loop
    } // End of x loop
} // End of function

Coord migrate(int quadrant ) {
    Coord coord;
    if(quadrant == 1) {
         coord = find_empty_cell((width/cellSize)/2, width/cellSize, 1, (height/cellSize)/2);
    } else if(quadrant == 2) {
       coord = find_empty_cell(1,(width/cellSize)/2, 1, (height/cellSize)/2);
    } else if(quadrant == 3) {
       coord = find_empty_cell(1,(width/cellSize)/2, (height/cellSize)/2, (height/cellSize));
    } else {
       coord = find_empty_cell( 1, width/cellSize/2, height/cellSize, (height/cellSize)/2); 
    }
    return coord;
}

Coord find_empty_cell(int width_begin, int width_end, int height_begin, int height_end) {
  Coord coord = new Coord();
  for(int i = width_begin; i < width_end; i++) {
     for(int j = height_begin; j < height_end; j++) {
         if(cellsBuffer[i][j] == DEAD) {
             coord = new Coord(i,j); 
         }
     } 
  }
  return coord;
}

int quadrant(int x, int y) {
  if(x >= (width/cellSize)/2) {
       return (y <= (height/cellSize)/2) ? 1 : 4;
   } else {
      return (y <= (height/cellSize)/2) ? 2 : 3;
    }
}

void keyPressed() {
    // Restart: reinitialization of cells
    if (key=='r' || key == 'R')
        setInitialStates();
    
    // On/off of pause
    if (key==' ')
        pause = !pause;

    
    // Clear all
    if (key=='c' || key == 'C') { 
        for (int x=0; x < width/cellSize; x++) {
            for (int y=0; y < height/cellSize; y++) {
                cells[x][y] = DEAD; // Save all to zero
            }
        }
    }
}

class Coord {
    public int x, y;
    Coord(){
      this.x = 0;
      this.y = 0;
    }
    Coord(int x, int y){
      this.x = x;
      this.y = y;
    }
}

class WorkerThread extends Thread {
    int width_begin, width_end, height_begin, height_end;
    
    WorkerThread () { }
    WorkerThread (int width_begin, int width_end, int height_begin, int height_end) {
        set_boundaries( width_begin,  width_end,  height_begin,  height_end);
    }
    
    public void run () {
        for (int x=width_begin; x < width_end; x++) {
            for (int y=height_begin; y < height_end; y++) {
                //set cell color
                fill(getColor(cells[x][y], x,y));
                rect (x*cellSize, y*cellSize, cellSize, cellSize);
            }
        }
        
        // Iterate if timer ticks
        if (millis()-lastRecordedTime > interval) {
            if (!pause) {
//                iteration(width_begin, width_end, height_begin, height_end);
                iteration();
                lastRecordedTime = millis();
            }
        }
        interact(); 
    }

    private void set_boundaries(int width_begin, int width_end, int height_begin, int height_end) {
        this.width_begin = width_begin;
        this.width_end = width_end;
        this.height_begin = height_begin;
        this.height_end = height_end;
    }
    void quit() {
        interrupt();
    }
}
