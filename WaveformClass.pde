class Waveform {
  AudioSample sample;
  boolean makingWaveform;
  float totalTime;
  float pixelsPerSec;
  int averageLenght;
  FloatList sampleAverage;
  float widthPerChunk;
  int displayX;
  int displayY;
  float timePerChunk;
  
  Waveform(AudioSample sample, int displayX, int displayY) {
    this.displayX = displayX;
    this.displayY = displayY;
    this.sample = sample;
    sampleAverage = new FloatList();
    makeWaveform();
  }



  void makeWaveform() {
    makingWaveform = true;
    //1. get samples values as if it was a mono files
    float[] leftSamples = sample.getChannel(AudioSample.LEFT);
    float[] rightSamples = sample.getChannel(AudioSample.RIGHT);
    float [] samplesVal = new float[rightSamples.length];
    for (int i=0; i <rightSamples.length; i++) {
      samplesVal[i] = leftSamples[i]+ rightSamples[i];
    }

    totalTime = samplesVal.length / sample.sampleRate();
    println("totalTime = " + totalTime);

    pixelsPerSec = float(displayX) / totalTime;
    println("pixelsPerSec = " + pixelsPerSec);

    int averageLengthDivider = 6;
    if (totalTime > 120) averageLengthDivider = 4;
    averageLenght =int(sample.sampleRate() / averageLengthDivider);
    println("averageLenght " + averageLenght); //length of a chunk in audio samples

    //2. reduce quantity : get an average from those values each  16 348 samples

    int average=0;

    for (int i = 0; i< samplesVal.length; i+=1) {
      average += abs(samplesVal[i])*1000 ; // sample are low value so *1000
      if ( i % averageLenght == 0 && i!=0) {
        sampleAverage.append( average / averageLenght);
        average = 0;
      }
    }

    println("total averages made = " + sampleAverage.size());
    widthPerChunk = float(displayX) / sampleAverage.size();

    // averageLenght = 16384 / 12;
    makingWaveform = false;
  }

  void updateWaveform() {
    stroke(200);
    fill(255);
    strokeWeight(0.5);
    for ( int i=0; i< sampleAverage.size() - 1; i++) {
      float xPos = i * widthPerChunk;
      float nextXPos = (i + 1) * widthPerChunk;
      float yPos = sampleAverage.get(i);
      float nextYPos = sampleAverage.get(i + 1);
      int yOffset = displayY - 10;
      line(xPos, yOffset - yPos, nextXPos, yOffset - nextYPos);
      // line(i*xWidth, height-bord*2, i*xWidth, (height-bord*2) - sampleAverage.get(i));
    }
  }
}