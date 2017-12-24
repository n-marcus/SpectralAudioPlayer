
import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer player;
FFT fft;
FloatList sampleAverage;
int bord = 10;
AudioSample sound;

Spectrum spec;
Display display;

float totalTime;
float xWidth;
int averageLenght = 16384 / 12; //this determines the detail in the waveform
float pixelsPerSec;
int secTextInterval;

boolean mouseRightDragged = false;
boolean madeLoop = false;
int loopIn;
int loopOut;
int loopInPixels;
int loopOutPixels;

int waveformHeight = 400;
boolean fileLoaded = false;
boolean makingWaveForm = false;
boolean spectrumMode = false;

IntList draggedLoopPoints;
float[][] spectra;

String fileName;

boolean errorOccured = false;

void setup() {
  selectInput("Select a file to process:", "fileSelected");
  // loadNewFile("C:/Users/Nathan/Music/SoundsSamplesandSnippets/Boutiq 1/zingende kids afrika.wav");
  sampleAverage = new FloatList();
  draggedLoopPoints = new IntList(); //only make new intlist when we
  size(1024, 600, OPENGL);
  pixelDensity(2);
  minim = new Minim(this);
}

void draw() {
  background(20);
  smooth();
  textSize(42);
  fill(175);
  textAlign(CENTER);
  text(frameRate + "fps", 10, 10);


  if (errorOccured) text("An error occured :( ", width / 2 , height / 2);
  if (makingWaveForm) text("Generating waveform...", width / 2, height /2);
  if (!fileLoaded && !errorOccured) text("Loading file...", width / 2, height /2);
  if (fileLoaded) {
      fft.forward(player.mix);
      display.update();

      // showGrid();
      // showPlayhead();
      display.drawPlayhead(player.position());
      // checkLoop(); //make sure player follows loop points
      if (mousePressed && keyPressed && keyCode == 17) display.setPercPos(float(mouseX) / float(width), 1. - float(mouseY) / float(height)) ; //zoom by holding cntrl and clicking and dragging
      if (mousePressed && keyPressed && keyCode == 16) display.setYScale((float(mouseX) * 2. )/ float(width));
       // if (madeLoop) showLoop(); //if a loop has been made and is active, show it;
      translate(0, waveformHeight - 5); //move down to make a second window
      if (player.isPlaying()) drawSpectrum(); //drawRealTime spectrum
      drawSpectrumAxis();
    }
    textAlign(CORNER);
    text(frameRate + "fps", 20, 20);

  }


void showPlayhead() {
  // draw a line to show where in the song playback is currently located
  float posX = map(player.position(), 0, player.length(), 0, width);
  stroke(175);
  line(posX, 0, posX, waveformHeight); //display playhead
  fill(175);
  text((player.position() / 1000.) + "s", posX + 5, 10); //display current seconds
}



int xPos2Time(int xPos) { //this function translates a point in x space to the time in the sample within the player object
  int time = int(map(xPos, 0, width, 0, player.length()));
  return time;
}
