int mousePressPosX, mousePressPosY;
boolean setMousePressPos = false;
int mouseScroll;

class Potentiometer {
  float value, theta, prevTheta, step, actualValue, dbScale;
  int x, y, r;
  PShape display;
  String settingName;
  Board board;
  
  Potentiometer(int _r, float _step, float defaultValue, Board _parent){
    this.value = defaultValue;
    this.theta = 0.0;
    this.prevTheta = 0.0;
    this.x = 0;
    this.y = 0;
    this.r = _r;
    this.step = _step;
    this.board = _parent;
    this.settingName = "";
    
    this.display = createShape(GROUP);
    PShape main = createShape(ELLIPSE, 0, 0, this.r, this.r);
    main.setFill(color(127));
    main.setStroke(false);
    PShape detail = createShape(ELLIPSE, 0, this.r/3, this.r/7, this.r/7);
    detail.setFill(color(96));  
    detail.setStroke(false);
    this.display.addChild(main);
    this.display.addChild(detail);
  }
  
  boolean mouseHover(int _x, int _y){
   return dist(this.x, this.y, _x, _y) < this.r/2;
  }
  
  boolean mouseHover() {
   return this.mouseHover(mouseX, mouseY);
 }
 
  void place(int _x, int _y) {
    this.x = _x;
    this.y = _y;
  }
  
  void update() {
    this.prevTheta = theta;
    if (this.mouseHover()) {
      println(mouseScroll);
      this.value += this.step * 10 * mouseScroll; 
    }
    if (setMousePressPos && this.mouseHover(mousePressPosX, mousePressPosY)) {
      
      this.theta = atan2(mouseY - this.y, mouseX - this.x);
      if (this.prevTheta < this.theta) {
        this.value += this.step;
      } else if (this.prevTheta > this.theta) {
        this.value -= this.step;
      }
    }
    
    this.actualValue = this.board.parent.getValueByName(this.settingName);
    this.dbScale = 10 * log10(this.actualValue);
  }
  
  void render() {
    
    
    pushMatrix();
    translate(this.x, this.y);
    pushMatrix();
    rotate(this.theta + radians(-90));
    shape(this.display);
    popMatrix();
    fill(255);
    textAlign(CENTER);
    text(this.settingName, 0, - this.r * 0.75);
    text(this.value, 0, this.r * 0.75);
    text(this.actualValue, 0, -150);
    text( String.format("%.02f dB",this.dbScale), 0, -130);
    circle(0, -100, 50 + this.dbScale);
    popMatrix();

  }
  
  void setSettingName(String name) {
    this.settingName = name;
  }
}

class Setting {
  String name;
  float value;
  Potentiometer linkedPot;
  Board board;
  
  Setting(String _name) {
    this.name = _name;
    this.value = 0.0001;
  }
  
  void setDisplayPos(int x, int y) {
    this.linkedPot.x = x;
    this.linkedPot.y = y;
  }
  
  Setting link(Potentiometer p) {
    this.linkedPot = p;
    this.linkedPot.setSettingName(this.name);
    return this;
  }
  
  void update() {
    this.linkedPot.update();
    this.value = this.linkedPot.value;
  }
  
  void render() {
    this.linkedPot.render();
  }
  
  boolean tick() {
    this.update();
    this.render();
    return this.linkedPot.mouseHover();
  }
}


class Board {
  ArrayList<Setting> settings;
  ArrayList<Boolean> hovering;
  int defaultPotenSz, x, y, nextX, nextY;
  Analyzer parent;
  
  Board(int potSz, Analyzer _parent) {
    this.settings = new ArrayList();
    this.hovering = new ArrayList();
    this.defaultPotenSz = potSz;
    this.x = 0;
    this.y = 0;
    this.parent = _parent;
  }
  int paddingX() {
    return round(this.defaultPotenSz * 1.25);
  }
  
  void addSetting(String settingName) {
    this.addSetting(settingName, 0.001, 1.0);
  }
  void addSetting(String settingName, float step) {
    this.addSetting(settingName, step, 1.0);
  }
  void addSetting(String settingName, float step, float defaultValue) {
    Potentiometer _p = new Potentiometer(this.defaultPotenSz, step, defaultValue, this);
    _p.place(this.x + this.paddingX() * this.settings.size(), this.y);
    this.settings.add(new Setting(settingName).link(_p));
  };
  float getSettingValue(String settingName) {
    Setting _s = this.settings.stream().filter(setting -> settingName.equals(setting.name)).findAny().orElse(null);
    if (_s == null) {
      println("[ERR] Setting " + settingName + " does not exist");
      exit();
      return Float.NaN;
    }
    
    return _s.value;
  }
  void run() {
    for(Setting setting: this.settings) {
      setting.tick();
    }
  }
  
  void place(int _x, int _y) {
    this.x = _x;
    this.y = _y;
  }
}

void mousePressed(){
  if (!setMousePressPos) {
    mousePressPosX = mouseX;
    mousePressPosY = mouseY;
    setMousePressPos = true;
  }
  
}
void mouseReleased(){
  setMousePressPos = false;
}

void mouseWheel(MouseEvent event){
  mouseScroll = event.getCount();
}
