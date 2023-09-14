float log10 (float x) {
  return (log(x) / log(10));
}

float sumf(float[] arr) {
  float acc = 0.0;
  for (float v: arr) acc+=v;
  return acc;
}

float meanf(float[] arr) {
  float arrSum = sumf(arr);
  return (arrSum / arr.length);
}

boolean coordsInBox(int x, int y, int bx0, int by0, int bx1, int by1) {
  return (x >= bx0 && x <= bx1 && y >= by0 && y <= by1);
}

boolean isCharIn(char c, char x, char y) {
  return (c >= x && c <= y);
}
