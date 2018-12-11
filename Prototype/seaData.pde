class seaData {
  //variable of json file
  JSONArray jsonData;
  JSONObject jsonObj;
  
  //data height array
  float[] dataNums;

  seaData() {
    //declare a new json array
    jsonObj = loadJSONObject("seaData.json");
    //jsonData = new JSONArray();
    
    //load file into the array
    jsonData = jsonObj.getJSONArray("elevations");
    
    //json height data array into dataNums     
    dataNums = new float[jsonData.size()];
    
    //inital data value of sea data
    init();
  }

  //initialization of data
  void init() {

    //loop through all the values from the json file of seaData value
    for (int i = 0; i < jsonData.size(); i++) {
      //create a json object for the current json array position
      JSONObject sea = jsonData.getJSONObject(i);
      dataNums[i] = sea.getFloat("VCAR");
    }
  }
  
  //return the height value of sea data for the landscape class
  float[] getHeightArray() {
    return dataNums;
  }
}