/**
Sampling Robot
*/

import ddf.minim.*;
import themidibus.*;

Minim minim;
AudioInput in;


SampleRobot robbie = new SampleRobot("sax",60,36,5,3,2000,5000);

void setup() {
  size(512, 200, P3D);
 
  // List all available Midi devices on STDOUT. This will show each device's index and name.
  MidiBus.list(); 
 
  minim = new Minim(this);
  in = minim.getLineIn(Minim.MONO);  
  textFont(createFont("Arial", 12));
}


void draw() {
  background(0); 
  stroke(255);
  robbie.step();
  
  // draw the waveforms
  for(int i = 0; i < in.bufferSize() - 1; i++) {
    line(i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50);
    line(i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50);
  }
}
