FloatList spectrumAxisHz = new FloatList();
FloatList spectrumAxisxPos = new FloatList();

void initSpectrum() {
  for (int i = 0; i < fft.specSize(); i++) {
    if (i % 20 == 0) {
      spectrumAxisHz.append(fft.indexToFreq(i));
      spectrumAxisxPos.append(getXPos(i));
    }
  }
}

void drawSpectrumAxis() {
  for (int i = 0; i < spectrumAxisHz.size(); i ++) {
    text(spectrumAxisHz.get(i) + "Hz", spectrumAxisxPos.get(i), height - waveformHeight);
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
