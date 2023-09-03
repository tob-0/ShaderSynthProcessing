import processing.sound.*;

class Analyzer {
  float[] spectrum, subBasses, basses, lMids, mids, hMids, presence, brilliance;
  
  Shadering parent;
  FFT fft;
  Sound snd;
  AudioIn in;
  Board board;
  Amplitude loudness;
  SoundFile file;
  
  Analyzer(int bandCount, Shadering _parent) {
    this.spectrum = new float[bandCount];
    this.parent = _parent;
    this.fft = new FFT(this.parent, bandCount);
    this.snd = new Sound(this.parent);
    this.loudness = new Amplitude(this.parent);
    
    this.file = null;
    this.in = null;
  }
  
  void useSoundFile(String name) {
    this.file = new SoundFile(this.parent, name);
    this.fft.input(file);
    this.loudness.input(file);
    this.file.play();
  }
  
  void useAudioIn() {
    this.useAudioIn(0);
  }
  void useAudioIn(int channel) {
    this.in = new AudioIn(this.parent, channel);
    this.in.start();
    this.in.amp(1.0);
    this.fft.input(in);
    this.loudness.input(in);
  }
  
  private float sumf(float[] arr) {
    float acc = 0.0;
    for (float v: arr) acc+=v;
    return acc;
  }


  private float meanf(float[] arr) {
    float arrSum = this.sumf(arr);
    return (arrSum / arr.length);
  }
  
  void setSource(int id){
    this.snd.inputDevice(id);
  }
  
  void setupBoard(int _x, int _y, int _sz) {
    this.board = new Board(_sz, this);
    this.board.place(_x, _y);
    this.board.addSetting("Sub");
    this.board.addSetting("Bass");
    this.board.addSetting("Low");
    this.board.addSetting("Mid");
    this.board.addSetting("High");
    this.board.addSetting("GlobalGain", 1.0, 25.0);
    
  }
  
  float getSubSens() {
    return this.board.getSettingValue("Sub");
  }
  float getBassSens() {
    return this.board.getSettingValue("Bass");
  }
  float getLowSens() {
    return this.board.getSettingValue("Low");
  }
  float getMidSens() {
    return this.board.getSettingValue("Mid");
  }
  float getHighSens() {
    return this.board.getSettingValue("High");
  }
  float getOffset() {
    return this.board.getSettingValue("GlobalGain");
  }
  
  void update() {
    
    this.fft.analyze(this.spectrum);
    this.subBasses = subset(this.spectrum, 0, 22);
    this.basses = subset(this.spectrum, this.subBasses.length, 93);
    this.lMids = subset(this.spectrum, this.basses.length, 186);
    this.mids = subset(this.spectrum, this.lMids.length, 1200);
    this.hMids = subset(this.spectrum, this.mids.length, 700);
    this.presence = subset(this.spectrum, this.hMids.length, 700);
    this.brilliance = subset(this.spectrum, this.presence.length);
    
  }
  
  void tick() {
    this.update();
    this.board.run();
  }
  float getValueByName(String name) {
    switch (name) {
      case "Sub":
        return this.getSubValue();
      case "Bass":
        return this.getBassValue();
      case "Low":
        return this.getLowValue();
      case "Mid":
        return this.getMidValue();
      case "High":
        return this.getHighValue();
      default:
        return Float.NaN;
    }
  }
  
  float getSubValue() {
    return this.meanf(this.subBasses) * this.getSubSens() * this.getOffset();
  }
  float getBassValue() {
    return this.meanf(this.basses) * this.getBassSens()* this.getOffset();
  }
  float getLowValue() {
    return this.meanf(this.lMids) * this.getLowSens()* this.getOffset();
  }
  float getMidValue() {
    return this.meanf(this.mids) * this.getMidSens()* this.getOffset();
  }
  float getHighValue() {
    return this.meanf(this.hMids) * this.getHighSens()* this.getOffset();
  }
  float getVolume() {
    return this.loudness.analyze();
  }
}
