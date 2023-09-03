PShader s;

Analyzer analyzer;

int bands = 8192;


public class SecondView extends PApplet {
  public void settings() {
    size(800,800, P2D);
  } 
  public void draw() {
  shader(s);
  rect(0,0, width, height);
  }
}


void reloadShader(String shdrFileName){
  s = loadShader(shdrFileName);
  s.set("u_resolution", float(width), float(height));
}

void setup() {
  size(650, 300, P2D);
  reloadShader("shader.glsl");
  analyzer = new Analyzer(bands, this);
  analyzer.setupBoard(50, 200, 75);
  analyzer.useAudioIn();
  analyzer.setSource(7);
  
  String[] args = {"TwoFrameTest"};
  SecondView sa = new SecondView();
  PApplet.runSketch(args, sa);
  
}

void draw() {
  background(0);
  analyzer.tick();
  
  
  s.set("u_mouse", float(mouseX), float(mouseY));
  s.set("u_time", millis() / 1000.0);

  
  float sub = analyzer.getSubValue();
  float bass = analyzer.getBassValue();
  float low = analyzer.getLowValue();
  float mid = analyzer.getMidValue();
  float high = analyzer.getHighValue();
  
  s.set("u_subLvl", sub);
  s.set("u_bassLvl", bass);
  s.set("u_lowLvl", low);
  s.set("u_midLvl", mid);
  s.set("u_highLvl", high);
  s.set("u_ampLvl", analyzer.getVolume());
  
  /*
  resetShader();
  fill(255);
  textAlign(CENTER);
  //text(sub, 100,220);
  //text(10 * log10(sub), 100,250);
  circle(50, 100, 50 + 10 * log10(sub));
  circle(50 + analyzer.board.paddingX(),100, 50 + 10 * log10(bass));
  circle(200, 100, 50 + 10 * log10(low));
  circle(275, 100, 50 + 10 * log10(mid));
  circle(350, 100, 50 + 10 * log10(high));
  */
  
  
  //saveFrame("frames/frame-######.png");
  //if (frameCount >= 600) exit();
}

void keyPressed() {
  if (key == 'q') exit();
  if (key == 'r') reloadShader("shader.glsl");
}
