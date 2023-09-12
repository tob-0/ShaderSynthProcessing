


class TempoInput extends NumberInput {
  float value;
  int x, y;
  String settingName;
  TapTempo handler;
  
  TempoInput() {
    super();
    this.handler = new TapTempo(10);
  }
  
  void tick() {
    super.tick();
    text("BPM",this.x, this.y+30);
  }
  
}
