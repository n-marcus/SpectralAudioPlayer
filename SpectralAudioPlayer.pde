
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

int _height;
int _width;

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
boolean controlPressed = false;
boolean shiftPressed = false;
boolean loadingFile = false;
boolean showHelp = false;

FadingText helpText;
FadingText loadingTimeText;

String[] helpStrings = {
  "Press space to pause / play loaded audio file",
  "Click anywhere in the spectrum to move to that location within the file",
  "Hold cntrl and press + or - to zoom in or out",
  "Or hold cntrl and drag the mouse to zoom in or out",
  "Press the right or left arrow key to move 5 seconds forward or backwards (hold cntrl for 1 second intervals)",
  "Hold cntrl and shift and press + or - to adjust the overall gain of the spectogram",
  "-----------",
  "Press 'n' to load a new audio file",
  "Press 'x' to exit the program",
  "Press 'c' to center the view around the current playing position in the file",
  "Press 'i' to show details on the spectogram",
  "Press 'f' to follow the positon in the file",
  "Press 'h' to hide this information"
};

void setup() {
  selectInput("Select a file to process:", "fileSelected");
  // loadNewFile("C:/Users/Nathan/Music/SoundsSamplesandSnippets/Boutiq 1/zingende kids afrika.wav");
  sampleAverage = new FloatList();
  draggedLoopPoints = new IntList(); //only make new intlist when we
  size(1024, 600, OPENGL);
  waveformHeight = int(height / 3. * 2.);
  pixelDensity(2);
  minim = new Minim(this);
  surface.setResizable(true);

  helpText = new FadingText(50 ,50 , 30000, "Press 'h' to for shortcuts and explanations");


}

void draw() {
  background(20);
  checkWindowResized();
  // smooth();
  textSize(42);
  fill(175);
  textAlign(CENTER);
  text(frameRate + "fps", 10, 10);


  if (errorOccured) {
    textSize(42);
    fill(175);
    text("An error occured :( ", width / 2 , height / 2);
    textSize(20);
    text("Try loading a new sound by pressing 'n'", width / 2, height / 2 + 50);
    text("Make sure your audio file is either .wav .mp3 or .aiff and either 8 or 16 bit", width / 2, height / 2 + 100);
  }
  if (makingWaveForm) text("Generating waveform...", width / 2, height /2);
  if (!fileLoaded && !errorOccured && loadingFile) {
    textSize(42);
    fill(175);
    text("Loading file ", width / 2, height /2);
    text(fileName, width / 2, height / 2 + 50);
  }

  if (fileLoaded) {
    checkButtons();



      // if (keyPressed && keyCode == 61 && controlPressed) display.setGain(display.getGain() + 0.2);
      // if (keyPressed && )


      fft.forward(player.mix);
      display.update();

      // showGrid();
      // showPlayhead();
      display.drawPlayhead(player.position());
      display.drawInfo();
      // checkLoop(); //make sure player follows loop points
      if (mousePressed && keyPressed && keyCode == 17) {
        display.setPercPos(float(mouseX) / float(width), 1. - float(mouseY) / float(height)) ; //zoom by holding cntrl and clicking and dragging
        display.followPlayhead = false;
      }
      if (mousePressed && keyPressed && keyCode == 16) display.setYScale((float(height - mouseY) * 2. )/ float(height));
       // if (madeLoop) showLoop(); //if a loop has been made and is active, show it;

      pushMatrix(); //make a different coordinate system
      translate(0, waveformHeight - 5); //move down to make a second window
      if (player.isPlaying()) drawSpectrum(); //drawRealTime spectrum
      drawSpectrumAxis();
      popMatrix(); //back to normal coordinate system
    }


    textAlign(CORNER);
    textSize(8);
    text(nfc(frameRate, 2) + "fps",20,waveformHeight + 20);



    if (helpText.alive) helpText.update();
    if (loadingTimeText != null && loadingTimeText.alive) loadingTimeText.update();

    if (showHelp) showHelp();
  }


int xPos2Time(int xPos) { //this function translates a point in x space to the time in the sample within the player object
  int time = int(map(xPos, 0, width, 0, player.length()));
  return time;
}

void checkWindowResized() {
  if (height != _height || width != _width) {
    println("resized!");
    if (fileLoaded) {
      display.displayX = width;
      waveformHeight = int(height / 3. * 2.);
      display.displayY = waveformHeight;
    }
  }
  _height = height;
  _width = width;
}

void showHelp() {
  float textBase = height * 0.2;
  int textInterval = 20;
  stroke(0);
  strokeWeight(1);
  fill(0,200);
  rectMode(CORNER);
  rect(width / 10, textBase - textInterval, width * 0.8, (helpStrings.length + 1) * textInterval);
  fill(200);
  textAlign(LEFT);
  textSize(16);
  for (int i = 0; i < helpStrings.length; i ++ ) {
    text(helpStrings[i], width / 10, textBase + (i * textInterval));
  }
}
