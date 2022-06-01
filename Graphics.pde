
interface IGraphic {
  void startDrawing();
  boolean isDrawing();
  void draw();
  void endAndSave();
  void innerDraw();
  boolean isFinished();
}

int MAX_DRAWS = 20;

class RandomRects implements IGraphic {
  String name;
  boolean drawingFlag = false;
  boolean finishedDrawingFlag = false;
  int counter;

  RandomRects(String n) { 
    name = n;
  }

  void startDrawing() {
    background(0); 
    pushMatrix();
    drawingFlag = true;
  }

  boolean isDrawing() { 
    return drawingFlag;
  }

  boolean isFinished() {
    return finishedDrawingFlag;
  }
  
  void draw() {
    if (isDrawing()) {
      counter=counter+1;
      if (counter > MAX_DRAWS) {
        drawingFlag = false;
        endAndSave();
        finishedDrawingFlag = true;
      }
      innerDraw();
    }
  }

  void innerDraw() {
    for (int i=0; i<1; i++) {
      fill(random(200), random(200), random(255));
      rect(random(width), random(height), random(100), random(100));
    }
    filter(BLUR);
    rotate(0.4);
  }

  void endAndSave() {
    noLoop();
    drawingFlag = false;
    popMatrix();
    fill(255, 255, 255, 255);
    textSize(48);
    text(name, 40, 100);
    saveFrame("background.png");
    exit();
  }
}

class RandomLines extends RandomRects {

  RandomLines(String name) {
    super(name);  
  }
  
  void innerDraw() {
    strokeWeight(4);
    for (int i=0; i<5; i++) {
      fill(150, random(200), 30);
      stroke(150, random(200), 30);
      line(random(width), random(height), random(width), random(height));
    }

    rotate(counter*0.4);
    filter(BLUR);
  }
}
