class Coordinate {
  
  //initial origin and interaction origin
  PVector origin;
  PVector interOrigin;

  /*target Height and previous target height from
   the initial tarting seaData landscape*/
  float targetHeight;
  float prevTarget;

  /*the coordinates of the screen 
   (screen coordinates in correspondance 
   to the landscape for interaction)*/
  PVector screenCoordinate;

  //Target position of finger 
  PVector fingerTarget;
  //Previous Target position of finger
  PVector prevFingerTarget;

  //test if there is interaction
  boolean isActive;

  //constructor
  Coordinate(float x, float y, float z, float _t) {
    origin = new PVector(x, y, z);
    targetHeight = _t;
    prevTarget =_t;

    screenCoordinate = new PVector();
    prevFingerTarget = new PVector();
    interOrigin = new PVector();
  }

  //methods
  //keep track of the original coordinates of the lanscape
  float getOx () {
    return origin.x;
  }

  float getOy () {
    return origin.y;
  }

  float getOz () {
    return origin.z;
  }

  void calcDir() {
  }

  /*calculation easing of the Z coordinate
   similar to the learp function*/
  void calcZ() {
    //get the distance from target height and previous height of landscape
    float distance = abs(prevTarget - targetHeight);

    if (distance > 1) {
      if (prevTarget > targetHeight)
        //decrementing speed to the previous target height
        prevTarget-=.4;
      else
        //incrementing speed to the target height
        prevTarget+=.4;
    }
  }
}