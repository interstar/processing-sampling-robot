/**
Sampling Robot
*/

import ddf.minim.*;
import themidibus.*;

Minim minim;
AudioInput AUDIO_INPUT;

// SampleRobot(String nr, IGraphic gr, IntRange nRange, IntRange vRange, int ndl, int sl) 

IGraphic graphic = new MangaRects("Manga");
SampleRobot robbie = new SampleRobot("manga",graphic,noteRangeOctsStartStep(4,36,4),
                                     volRange(0,127,40),10,10);

void setup() {
  size(812, 375 );
 
  // List all available Midi devices on STDOUT. This will show each device's index and name.
  MidiBus.list(); 
 
  minim = new Minim(this);
  AUDIO_INPUT = minim.getLineIn(Minim.MONO);  
  textFont(createFont("Arial", 12));

  background(0); 
  stroke(255);
}


void draw() {
 
  robbie.step();
  robbie.draw();
  

}
