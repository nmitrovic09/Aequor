class Landscape {
  //object variables
  Random generator;
  seaData data;

  //2d array of landcape terrain
  Coordinate[][] terrain;

  //array counter
  int indexNums = 1;

  //height target array
  float[] heightTargetArray;

  //target array value
  float localHeightTarget;

  float nonInteractionHeight;

  //mesh dimensions
  //columns, rows, scale, width and height
  int cols, rows;
  int scl = 10;
  int w = 1300;
  int h = 900;

  //mesh movement
  float flying = 0;

  //time values specification
  float timePassed = 0;
  float currentTime = 0;
  float interval = 500;

  //constructor
  Landscape() {
    //dimensions of mesh with values
    cols = w/scl;
    rows = h/scl;

    //instantiate the objects 
    generator = new Random();
    terrain = new Coordinate[cols][rows];
    data = new seaData();

    //store sea height data in this variable
    heightTargetArray = data.getHeightArray();
    //start at the first value in the heightTargetArray
    localHeightTarget = heightTargetArray[0];

    //initialize the first movement and display
    init();
  }

  //initialization of landscape
  void init() {

    //speed of movement
    float yoff = flying;

    //nested loop of rows and cols to create mesh
    for (int y = 0; y < rows; y++) {
      float xoff = 0;
      for (int x = 0; x < cols; x++) {

        // work out a decreasing offset when getting 
        //to the edges of the screen
        float r = heightTargetArray[0]/(float)rows;
        //height formula with the array list for the landscape movement
        localHeightTarget = (heightTargetArray[indexNums]-(y*r));

        //create the terrain object with Coordinate object values
        //and mapping the z values
        terrain[x][y] = new Coordinate(x*scl, y*scl, map(noise(xoff, yoff), 0, 1, -localHeightTarget, localHeightTarget), localHeightTarget);
        xoff += 0.1;
      }
      yoff += 0.1;
    }
  }

  void run() {
  }

  //movement of landscape
  void update() {

    //going backwards in the y axes in three dimension
    //to get a sense of movement in 3d space
    flying -= 0.01;
    float yoff = flying;

    /*this boolean controls when we should change 
     the sea data value elevation*/
    boolean changeState = false;

    // get time
    timePassed = millis()-currentTime;

    //if the time has passed change the inputted data value
    if (timePassed > interval) {
      //change the elevation
      changeState=true;

      //if we are at the end of array go back to beginning
      if (indexNums == heightTargetArray.length-1) {
        indexNums = 0;
      } else {
        indexNums++;
      }
      //reset the timer
      timePassed = 0;
      currentTime = millis();
    }

    //nested for loop for the terrain oscillation 
    //and control of mesh with vertex
    for (int y = 0; y < rows; y++) {
      float xoff = 0;
      for (int x = 0; x < cols; x++) {

        //if interval has been reset
        if (changeState == true) {

          //decreasing offset
          float r = heightTargetArray[0]/(float)125;
          //height formula with the array list for the landscape movement
          nonInteractionHeight = (heightTargetArray[indexNums]-(y*r))*30;

          // limit local height
          if (nonInteractionHeight <= 5) {
            nonInteractionHeight = 5;
          }

          //set the new height target
          terrain[x][y].targetHeight = nonInteractionHeight;
        }


        //update the movement of z values by keep as well the previous value
        terrain[x][y].calcZ();
        terrain[x][y].origin.z = map(noise(xoff, yoff), 0, 1, -terrain[x][y].prevTarget, terrain[x][y].prevTarget);
        xoff += 0.1;
      }
      yoff += 0.1;
    }
  }

  //displaying the landscape on the screen
  void display() {

    //load video to the landscape
    //movie.loadPixels();

    //positioning the landscape in a horizontal position 
    //close to the bottom edge
    translate(width/2, height/2);
    rotateX(PI/2.3);
    translate(-w/2, -h/30);

    //nested for loop to create the landscape with vertex
    for (int y = 0; y < rows-1; y++) {

      //triangle changes
      beginShape(TRIANGLE_STRIP);

      for (int x = 0; x < cols-1; x++) {

        //fill and stroke colors of landscape
        strokeWeight(1);

        //video has a fill of landscape
        //variable for the pixel on the window
        //int multiplier = width/rows;

        //various formulas to put each pixel of video into mesh
        //int loc = (rows - y*multiplier -1) + y*multiplier * rows;
        //int loc = (movie.width - y - 1) + x * movie.width;
        //int loc = x + y * movie.width;
        //loc = constrain(loc, 0, movie.pixels.length-1);
        //color c = movie.pixels[loc];

        //int i = x*scl;
        //int j = y*scl;
        //color c = movie.pixels[i + j*movie.width];

        //noFill();
        //fill(c);

        //various color possibilities  
        //blue possibiity 2
        fill(0, 0, 200, 200);
        stroke(0, 150);

        //blue possibiity 2
        //fill(0,0,70, 200);
        //stroke(100, 150);

        //blue possibiity 4
        //fill(0,0,80);
        //stroke(0,100,150);

        //create the vertex of landscape
        vertex(terrain[x][y].getOx(), terrain[x][y].getOy(), terrain[x][y].getOz());
        vertex(terrain[x][y+1].getOx(), terrain[x][y+1].getOy(), terrain[x][y+1].getOz());
      }
      endShape();
    }
  }
}