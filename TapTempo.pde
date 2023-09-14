class TapTempo{
  float last, now, threshold, lastInputMs;;
  float[] entries;
  int cursor, tempo,tempoLength, samples;
  Potentiometer p;
  
  TapTempo(int _samples) {
    this.entries = new float[_samples];
    this.samples = _samples;
    this.last = millis();
    this.now = millis();
    this.cursor = 0;
    this.tempo = 1;
    this.tempoLength = 1;
    this.threshold = 150.0;
    this.lastInputMs = 0.0;
  }
  
  void update() {
    if (millis() - this.lastInputMs > this.threshold) {
      this.lastInputMs = millis();
      if (keyPressed && key == 't'){
        this.now = millis();
        this.entries[cursor] = (1000.0 / (this.now - this.last)) * 60;
        this.cursor++;
        
        if (this.cursor >= this.samples) {
          this.cursor = 0;
        }
         
        this.tempo = round(meanf(this.entries));
        this.tempoLength = 60 * 1000 / this.tempo;
        this.last = this.now; 
      }
    }
  }
  
}
