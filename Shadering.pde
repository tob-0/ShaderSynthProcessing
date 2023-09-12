PShader s;

Analyzer analyzer;

int bands = 8192;
int shaderWinW = 720;
int shaderWinH = 1280;
String shdrFile = "shader.glsl";

public class Visual extends PApplet {
  public void settings() {
    size(shaderWinW,shaderWinH, P2D);
    
  } 
  public void draw() {
  
  shader(s);
  rect(0,0,shaderWinW, shaderWinH);
  resetShader();
  saveFrame("frames/frame-######.png");
  
  }
  void keyPressed() {
    if (key == 'q') exit();
    if (key == 'r') reloadShader(shdrFile);
  }


}


  
void reloadShader(String shdrFileName){
  try {
    s = loadShader(shdrFileName);
    s.set("u_resolution", float(shaderWinW), float(shaderWinH));
  } catch(Exception e) {
    println("Error while reloading:");
    println(e);
    return;
  }
}
void setup() {
  fullScreen(P2D);
  //size(720, 1280, P2D);
  frameRate(60);
  reloadShader(shdrFile);
  
  
  analyzer = new Analyzer(bands, this);
  analyzer.setupBoard(50, 200, 75);
  analyzer.useAudioIn();
  analyzer.setSource(7);
  //analyzer.useSoundFile("audiomass-output.mp3");
  
  //String[] args = {"TwoFrameTest"};
  //Visual v = new Visual();
  //PApplet.runSketch(args, v);
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
  float tempo = analyzer.getBpm();
  
  s.set("u_subLvl", sub);
  s.set("u_bassLvl", bass);
  s.set("u_lowLvl", low);
  s.set("u_midLvl", mid);
  s.set("u_highLvl", high);
  s.set("u_ampLvl", analyzer.getVolume());
  s.set("u_tempo", tempo);
  s.set("u_st_offx", analyzer.getOffsetX());
  s.set("u_st_offy", analyzer.getOffsetY());
  s.set("u_generic0", analyzer.board.getSettingValue("Generic0"));
  s.set("u_generic1", analyzer.board.getSettingValue("Generic1"));
  s.set("u_generic2", analyzer.board.getSettingValue("Generic2"));
  s.set("u_generic3", analyzer.board.getSettingValue("Generic3"));
  s.set("u_generic4", analyzer.board.getSettingValue("Generic4"));
  s.set("u_generic5", analyzer.board.getSettingValue("Generic5"));
  s.set("u_generic6", analyzer.board.getSettingValue("Generic6"));
  //if (frameCount >= 600) exit();
  
  
  shader(s);
  rect(0,0,width, height);
  resetShader();
  //
}
void keyPressed(){
saveFrame("frames/frame-######.png");
}
