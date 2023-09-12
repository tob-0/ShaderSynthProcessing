abstract class Input {
  float value;
  int x, y;
  String settingName;
  boolean showDetails;
  abstract void place(int _x, int _y);
  abstract void update();
  abstract void tick();
  abstract void render();
  abstract void setSettingName(String _settingName);
  abstract float value();
}


enum InputPlacingMode {
  CORNER,
  CENTER
}


class NumberInput extends Input{
  boolean isSelected;
  int x, y, w, h, maxValueLength;
  String value, settingName;
  float threshold, lastInputMs;
  InputPlacingMode placingMode;  
  
  
  NumberInput() {
    this.isSelected = false;
    this.x = 0;
    this.y = 0;
    this.w = 100;
    this.h = 24;
    this.value = "0";
    this.threshold = 150.0;
    this.lastInputMs = 0;
    this.maxValueLength = 3;
    this.placingMode = InputPlacingMode.CORNER;
  }
  
  void input(char c) {
    if (this.value.length() < this.maxValueLength && isCharIn(c, '0', '9'))
      this.value += c;
  }
  
  void place(int _x, int _y) {
    this.x = _x;
    this.y = _y;
  }
  
  
  void render() {
    fill(255);
    
    if (this.isSelected) stroke(255,0,0);
    else stroke(0);
    
    rect(this.x, this.y, this.w, this.h);
    
    fill(0);
    text(this.value, this.x+10, this.y+16);
  }
  
  void update() {
    if (setMousePressPos) {
      if (coordsInBox(mousePressPosX, mousePressPosY, this.x, this.y, this.x + this.w, this.y + this.h)) {
        this.isSelected = true;
      }
      else {
        this.isSelected = false;
      }
    }  
    
    if (this.isSelected && keyPressed){
      if (millis() - this.lastInputMs > this.threshold) {
        
        
        if (key == BACKSPACE)
          this.value =  this.value.length() > 0 ? this.value.substring( 0, this.value.length() - 1) : "0";
        else
          this.input(key);
        
        this.lastInputMs = millis();
      }
    }
  }
  
  void tick() {
    this.update();
    this.render();
  }
  
  float value() {
    return Integer.parseInt(this.value);
  }
  
  void setSettingName(String _settingName) {
    this.settingName = _settingName;
  }
}

class Potentiometer extends Input{
  float value, theta, prevTheta, step, actualValue, dbScale;
  int x, y, r;
  PShape display;
  String settingName;
  boolean showDetails;
  Board board;
  
  Potentiometer(Board _parent, int _r, float _step, float defaultValue ){
    this.init(_r, _step, defaultValue, _parent, true);
  }
  Potentiometer(Board _parent, int _r, float _step, float defaultValue,  boolean details){
    this.init(_r, _step, defaultValue, _parent, details);
  }
  
  private void init(int _r, float _step, float defaultValue, Board _parent, boolean details){
    this.value = defaultValue;
    this.theta = 0.0;
    this.prevTheta = 0.0;
    this.x = 0;
    this.y = 0;
    this.r = _r;
    this.step = _step;
    this.board = _parent;
    this.settingName = "";
    this.showDetails = details;
    
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
    if (this.showDetails) {
      text(this.actualValue, 0, -150);
      text( String.format("%.02f dB",this.dbScale), 0, -130);
      circle(0, -100, 50 + this.dbScale);
    }
    popMatrix();

  }
  
  void tick() {
    this.update();
    this.render();
  }
  
  float value() {
    return this.value;
  }
  
  void setSettingName(String _settingName) {
    this.settingName = _settingName;
  }
}

class Setting {
  String name;
  float value;
  Input input;
  Board board;
  
  
  Setting(String _name) {
    this.name = _name;
    this.value = 0.0001;
  }
  
  void setDisplayPos(int x, int y) {
    this.input.x = x;
    this.input.y = y;
  }
  
  Setting link(Input i) {
    this.input = i;
    this.input.setSettingName(this.name);
    return this;
  }
  
  void update() {
    this.input.update();
    this.value = this.input.value();
  
  }
  
  void render() {
    this.input.render();
  }
  
  void tick() {
    this.update();
    this.render();
  }
}


class Board {
  ArrayList<Setting> settings;
  ArrayList<Boolean> hovering;
  int defaultPotenSz, x, y, nextX, nextY, currentLine,currentObj;
  Analyzer parent;
  
  Board(int potSz, Analyzer _parent) {
    this.settings = new ArrayList();
    this.hovering = new ArrayList();
    this.defaultPotenSz = potSz;
    this.x = 0;
    this.y = 0;
    this.currentLine = 0;
    this.currentObj = 0;
    this.parent = _parent;
  }
  
  int padding() {
    return round(this.defaultPotenSz * 1.25);
  }
  
  void addPotenSetting(String settingName) {
    this.addPotenSetting(settingName, 0.001, 1.0);
  }
  
  void addPotenSetting(String settingName, boolean showDetails) {
    this.addPotenSetting(settingName, 0.001, 1.0, showDetails);
  }
  void addPotenSetting(String settingName, float step) {
    this.addPotenSetting(settingName, step, 1.0);
  }
  
  void addPotenSetting(String settingName, float step, float defaultValue) {
    this.addPotenSetting(settingName, step, defaultValue, true);
  };
  
  void addPotenSetting(String settingName, float step, float defaultValue, boolean showDetails) {
    Potentiometer _p = new Potentiometer(this, this.defaultPotenSz, step, defaultValue, showDetails);
    this.addSettingWith(settingName, _p);
  };
  
  void addSettingWith(String settingName, Input withInput) {
    
    if (this.currentObj > 0 && this.currentObj % 7== 0) {
      this.currentLine++;
      this.currentObj = 0;
    }
    this.nextX = this.x + this.padding() * this.currentObj;
    this.nextY = this.y + this.padding()*2 * this.currentLine;
    
    this.currentObj++;
    withInput.place(this.nextX, this.nextY);
    this.settings.add(new Setting(settingName).link(withInput));
  }
  
  
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
