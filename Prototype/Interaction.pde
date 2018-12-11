class Interaction extends Landscape {

  //arraylists for the returning leap coordinates
  ArrayList<Float> fingerHeightArray;
  ArrayList<PVector> fingersPosArray;

  /*variables to store the values of 
   arrayList from Leap Motion*/
  float fingerHeight;
  PVector fingersPos;

  /*only finger y coordinate and finger 
   (x,y,z) coordinates for the mapping 
   of fingers*/
  float mapFingerHeight;
  PVector mapFingersSpace;

  /*the positon of finger in the correct 
   cell on the landscape*/
  int indexX;
  int indexY;

  //timer
  float interval = 5000;

  Interaction() {
    super();

    fingersPos = new PVector();
    mapFingersSpace = new PVector();
  }

  void run() {

    //store Leap finger y coordinante array in this array
    fingerHeightArray = getLeapFingerPosY();
    //store Leap finger position array into this array
    fingersPosArray = getLeapFingers();

    /*----------if the arraylists contain finger values for the interaction-------------*/
    if (fingerHeightArray.size() != 0 && fingersPosArray.size() != 0) {

      //get the height of the finger from leap motion
      fingerHeight = fingerHeightArray.get(0);

      //get the values of each finger of the arraylist of Leap motion
      for (int i = 0; i < fingersPosArray.size(); i++) {
        fingersPos = fingersPosArray.get(i);
      }

      //mapping the values from the finger data position to the correct landscape values
      mapFingerHeight = map(fingerHeight, 100, 300, 100, 0);
      //mapFingerHeight = constrain(mapFingerHeight, 0, 100);
      mapFingersSpace = new PVector(map(fingersPos.x, 300, 900, 0, width), map(fingersPos.y, 400, 670, 200, 0), map(fingersPos.z, 30, 70, height, 0));
      //mapFingerSpace = constrain(fingerHeight, 0, width);

      //update the height interaction to the landcape
      fingerHeightUpdate();

      //update the initial values of landscape from seaData
      update();

      //update the interaction to the landcape
      fingerMeshInteraction();

      /*detect and control the place of the finger
       in relation to landscape*/
      testFingerAgainstVertex();


      /*----------if there is no interaction (no finger detected)-------------*/
    } else {

      //update the initial landscape movement
      update();

      /*go through the landscape to transition 
       between the interaction values to landscape seaData */
      for (int y = 0; y < rows; y++) {
        for (int x = 0; x < cols; x++) {

          //the landscape interaction with the finger is not active anymore
          //do the easing of vertex and transition to initial values of landscape from seaData
          terrain[x][y].isActive = false;

          //check if there is a previous target of the finger
          if (terrain[x][y].prevFingerTarget.y != 0) {
            //if yes, do the easing of the interaction to the landscape original values
            terrain[x][y].origin.z = lerp(terrain[x][y].prevFingerTarget.y, terrain[x][y].origin.z, 0.01);
            terrain[x][y].prevFingerTarget.y = terrain[x][y].origin.z;


            // float t =terrain[x][y].prevFingerTarget.y + terrain[x][y].origin.z;
            //terrain[x][y].origin.z-=terrain[x][y].interOrigin.z;
            //terrain[x][y].prevTarget = lerp(terrain[x][y].origin.z, terrain[x][y].prevTarget, 0.1);
          }
        }
      }
    }
  }

  void update() {
    super.update();
  }

  /*test the vertex interaction with finger*/
  //if counter value is 0 = interaction is true(active)
  //else if counter velue is > 0 = false(not active)
  void testFingerAgainstVertex() {

    //find the grid cell in the landscape
    indexX = ceil(mapFingersSpace.x/10);
    indexY = ceil(mapFingersSpace.z/10);

    //find the matching one
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {

        //if the finger is in the cell area according to the landscape
        if (int(terrain[x][y].screenCoordinate.y/10) == indexY && int(terrain[x][y].screenCoordinate.x/10) == indexX) {
          //update the interaction with the finger
          terrain[x][y].isActive = true;
        } else {
          //decrease the vertex after the timer has passed
          //make it the vertex not active in order to decrease
          terrain[x][y].isActive = false;
        }
      }
    }
  }

  //function for finger interaction with the landscape
  void fingerMeshInteraction() {

    float yoff =+ 0.1;

    //nested for loop for the terrain oscillation 
    //and control of mesh with vertex
    for (int y = 0; y < rows; y++) {
      float xoff = 0.1;
      for (int x = 0; x < cols; x++) {

        if (terrain[x][y].isActive) {

          //easing value on y axes according to new position from the leap motion
          //float r = mapFingerSpace.y/(float)125;
          //mapFingerSpace.y-(y*r)

          //Target finger posiiton according to the leap motion values
          PVector fingerCoordinate = new PVector(mapFingersSpace.x, mapFingersSpace.y, mapFingersSpace.z);

          // limit local height
          //if (localHeightTarget <= 5) {
          //localHeightTarget = 5;
          //}

          //set the new height target to the landscape
          terrain[x][y].fingerTarget = fingerCoordinate;

          //the elevation is calculated from the previous finger target to the Targeted finger coordinate
          terrain[x][y].interOrigin.z = lerp(terrain[x][y].prevFingerTarget.y, fingerCoordinate.y, 0.001);

          //elevate the origin.z value to the target height of finger
          terrain[x][y].origin.z = terrain[x][y].interOrigin.z*2;

          //assign the elevation to the previous one in order to keep track of it
          terrain[x][y].prevFingerTarget.y = terrain[x][y].origin.z;
        } else {

          /*if the vertex is not active anymore,
           decrease the vertex to the original values
           of landscape or to the interaction height,
           (funtion fingerHeightUpdate())
           */

          if (terrain[x][y].prevFingerTarget.y!=0) {
            //decrease the height of the interaction to the landscape values (reversed from the one above)
            terrain[x][y].origin.z = lerp(terrain[x][y].prevFingerTarget.y, terrain[x][y].origin.z, 0.05);
            terrain[x][y].prevFingerTarget.y = terrain[x][y].origin.z;
          }

          xoff += 0.1;
        }
        yoff += 0.1;
      }
    }
  }

  //function for the height finger interaction with the landscape
  void fingerHeightUpdate() {

    float yoff =+ 0.01;

    /*nested for loop for the terrain oscillation 
     and control of mesh with the fingers height */
    for (int y = 0; y < rows; y++) {
      float xoff = 0.1;
      for (int x = 0; x < cols; x++) {

        //easing formula with the mapped height value of finger
        float r = mapFingerHeight/(float)125;
        //localHeightTarget = (mapFingerHeight-(y*r));
        localHeightTarget = mapFingerHeight;

        // limit local height
        if (localHeightTarget <= 5) {
          localHeightTarget = 5;
        }

        //set the new height target
        terrain[x][y].targetHeight = localHeightTarget;

        //the easing calculation
        terrain[x][y].calcZ();

        //update the movement of the terrain
        terrain[x][y].origin.z = map(noise(xoff, yoff), 0, 1, -terrain[x][y].prevTarget, terrain[x][y].prevTarget);

        xoff += 0.1;
      }
      yoff += 0.1;
    }
  }

  //displaying the landscape
  void display() {

    //load video to the landscape
    //movie.loadPixels();

    //positioning the landscape in a horizontal position 
    //close to the bottom edge
    translate(width/2, height/2);
    rotateX(PI/2.3);
    translate(-w/2, -h/15);

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

        fill(0, 0, 200, 200);
        stroke(0, 150);

        //create the vertex of landscape
        vertex(terrain[x][y].getOx(), terrain[x][y].getOy(), terrain[x][y].getOz());
        vertex(terrain[x][y+1].getOx(), terrain[x][y+1].getOy(), terrain[x][y+1].getOz());

        //get the landscape from the screen coordinates
        terrain[x][y].screenCoordinate.x = screenX(terrain[x][y].getOx(), terrain[x][y].getOy(), terrain[x][y].getOz());
        terrain[x][y].screenCoordinate.y = screenY(terrain[x][y].getOx(), terrain[x][y].getOy(), terrain[x][y].getOz());
        terrain[x][y].screenCoordinate.z = screenZ(terrain[x][y].getOx(), terrain[x][y].getOy(), terrain[x][y].getOz());
      }
      endShape();
    }
    //testing for finger on mesh
    //fill(0, 0, 255);
    //ellipse(mapFingerSpace.x, mapFingerSpace.z, 50, 50);
  }

  //get the finger coordinates from the leap
  ArrayList<PVector> getLeapFingers() {

    //how many hands are detected (for the println only)
    int handi = 0;

    //instantiate the returning array list
    ArrayList<PVector> values = new ArrayList<PVector>();

    //check if there is any hands detected
    for (Hand hand : leap.getHands()) {
      //check for how many fingers are detected


      //get the current index finger coordinates
      //PVector fingerPosition   = finger.getPosition();

      //check for how many fingers are detected
      for (int i = 0; i < 5; i++) {

        //get the current index finger coordinates
        Finger fingerCurrent = hand.getIndexFinger();

        PVector fingerPosition = fingerCurrent.getPositionOfJointTip();
        println("handId:: "+handi+" finger"+ i+":: "+ fingerPosition);
        values.add(fingerPosition);

        //add the index finger y value to the returning arraylist
        //increment to find which hand is detected (for the println only)
        handi++;
      }
    }
    return values;
  }

  //get the finger Y coordinate from the leap
  ArrayList<Float> getLeapFingerPosY() {

    //how many hands are detected (for the println only)
    int handi = 0;

    //instantiate the returning array list
    ArrayList<Float> values = new ArrayList<Float>();

    //check if there is any hands detected
    for (Hand hand : leap.getHands()) {
      //check for how many fingers are detected
      for (int i = 0; i < 5; i++) {

        //get the current index finger coordinates
        Finger fingerCurrent = hand.getIndexFinger();

        //get only the y value of the index finger
        Float fingerY = fingerCurrent.getPositionOfJointTip().y;

        //println("handId:: "+handi+" finger"+ i+":: "+ fingerY);

        //add the index finger y value to the returning arraylist
        values.add(fingerY);
      }
      //increment to find which hand is detected (for the println only)
      handi++;
    }
    return values;
  }
}