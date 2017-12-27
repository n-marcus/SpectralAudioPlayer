FloatList spectrumAxisHz = new FloatList();
FloatList spectrumAxisxPos = new FloatList();
float _xPos;
float xPos;
float lastUsedXPos;

void initRealTimeSpectrum() {
  for (int i = 0; i < fft.specSize(); i++) {
    if (i % 10 == 0) {
      spectrumAxisHz.append(fft.indexToFreq(i));
      spectrumAxisxPos.append(getXPos(i));
    }
  }
}

void drawSpectrumAxis() {
  lastUsedXPos = 0;
  for (int i = 0; i < spectrumAxisHz.size(); i ++) {
    xPos = spectrumAxisxPos.get(i);
    if (xPos - lastUsedXPos > 40) {
      lastUsedXPos = xPos;
      textSize(10);
      text(int(spectrumAxisHz.get(i)) + "Hz", xPos , height - waveformHeight - 10);
    }
    _xPos = xPos;
  }
}

void drawSpectrum() {
  for (int i = 0; i < fft.specSize(); i++)
  {
    float realFreq = fft.indexToFreq(i);
    float currentBandPower = getPower(i);
    float nextBandPower = getPower(i + 1);

    float xPos = 0;
    float nextXPos = 0;
    // if (i != 0) {
    xPos = getXPos(i);
    nextXPos = getXPos(i + 1);
    // }

    float endpointx = xPos;
    // float destination = (power * 200);
    int yOffset = height - waveformHeight + 100;
    strokeWeight(0.5);
    stroke(255);
    line(xPos, yOffset - map(currentBandPower, -3., 0., 40., 200.), nextXPos, yOffset - map(nextBandPower, -3., 0., 40., 200.) );

    // println("power = " + power);
    // println("startingpointx" + startingpointx + " yOffset" + yOffset + " destination" + destination);
  }
}



float getPower(int i) {
  int gain = 200;
  float power = fft.getBand(i) * (gain / 100);
  power = (log(power)/ log(10)) * (3./4.);
  return constrain(power, -4., 4.);
}

float getXPos(int i) {
  int initXOffset = 10;
  float xPos = (sqrt(i*(5 * width))) + initXOffset;
  return xPos;
}
