void makeWaveform() {
  makingWaveForm = true;
  //1. get samples values as if it was a mono files
  float[] leftSamples = sound.getChannel(AudioSample.LEFT);
  float[] rightSamples = sound.getChannel(AudioSample.RIGHT);
  float [] samplesVal = new float[rightSamples.length];
  for (int i=0; i <rightSamples.length; i++) {
    samplesVal[i] = leftSamples[i]+ rightSamples[i];
  }
  println("samplerate = " + player.sampleRate());

  totalTime = samplesVal.length / sound.sampleRate();
  println("totalTime = " + totalTime);

  pixelsPerSec = float(width) / totalTime;
  println("pixelsPerSec = " + pixelsPerSec);

  secTextInterval = round(totalTime / 20.);
  println("secTextInterval = " + secTextInterval );

  int averageLengthDivider = 6;
  if (totalTime > 120) averageLengthDivider = 4;
  averageLenght =int(player.sampleRate() / averageLengthDivider);
  println("averageLenght " + averageLenght);

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
  xWidth = float(width) / sampleAverage.size();

  // averageLenght = 16384 / 12;
  makingWaveForm = false;
}


void showWaveform() {
  stroke(200);
  fill(255);
  strokeWeight(0.5);
  for ( int i=0; i< sampleAverage.size() - 1; i++) {
    float xPos = i * xWidth;
    float nextXPos = (i + 1) * xWidth;
    float yPos = sampleAverage.get(i);
    float nextYPos = sampleAverage.get(i + 1);
    int yOffset = waveformHeight - bord * 2;
    line(xPos, yOffset - yPos, nextXPos, yOffset - nextYPos);
    // line(i*xWidth, height-bord*2, i*xWidth, (height-bord*2) - sampleAverage.get(i));
  }
}

void showGrid() {

  for (int sec = 0; sec < totalTime; sec +=secTextInterval) {
    float xPos = sec * pixelsPerSec;
    stroke(200, 50);
    line(xPos, 0, xPos, waveformHeight);
    textSize(8);
    fill(200);
    text(sec + "s", xPos, waveformHeight - bord /2);
  }
  line(0, waveformHeight - bord * 2, width, waveformHeight - bord * 2);
  line(0, waveformHeight, width, waveformHeight);
}
