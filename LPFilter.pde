class LPFilter {
  float lastval;
  float val;

  LPFilter(float init) {
    val = init;
    lastval = init;
    //constructor
    //freq = TWO_PI * meantfreq / samplerate;
  }

  float update(float input, float freq) {
    val = input * (1.0 - freq);
    val = val + (lastval * freq);
    lastval = val;
    return val;
  }
}
