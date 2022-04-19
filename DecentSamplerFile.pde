class DecentBuilder {
  
  String value="";
  String fileName;
  
  DecentBuilder(String nameRoot) {
    fileName = nameRoot+".dspreset";
  }
 
  DecentBuilder wrap(String t, String extra) {
    value = "<"+t+" "+extra+">" + value + "</"+t+">";
    return this;
  }
  
  void addSampleLine(int note, int step, String fileName) {
     value = value + "<sample rootNote=\"" + note + "\" path=\"" + fileName + "\" loNote=\"" + (note-step) + "\" hiNote=\""+(note-1)+"\" />\n";
  }
  
  void fullFile() {
     value= "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + 
     this.wrap("group","").wrap("groups","").wrap("DecentSampler"," pluginVersion=\"1\""); 
  }
  
  void write() {
    fullFile();
    String[] xs = new String[]{this.toString()};
    saveStrings(fileName,xs);
  }
  
  String toString() { return value; }
}
