class Display {
  Spectrum spec;
  Waveform wave;
  int displayStart = 0; //beginning of display in ms
  int displayEnd = 0; //end of display in ms
  int displayedMs = 0; //total displayed milliseconds
  int minMsDisplayed = 20; //minimal ms displayed (also most you can zoom in)

  float startDisplayPerc = 0.; //percentage where the display starts within the sample
  float endDisplayPerc = 1.; //percentage where the display ends within the sample

  int displayX; //width of display
  int displayY; //height of display

  int totalTime = 0; //total time of loaded sample

  int barHeight = 10; //height of selection bar at bottom

  boolean spectralDisplay = true; //toggle between waveform and spectrum
  boolean mouseOver = false;

  Display(AudioSample sample, int displayX, int displayY) {
    this.displayX = displayX;
    this.displayY = displayY;

    this.totalTime = sample.length();
    this.displayEnd = totalTime;
    this.displayedMs = totalTime;

    println("Total time in display = " + totalTime);

    spec = new Spectrum(sample, 2048, displayX, displayY);
    wave = new Waveform(sample, displayX, displayY);
  }

  void update() {
    if (spectralDisplay) {
      spec.updateSpectrum(displayX, displayY, startDisplayPerc, endDisplayPerc);
    } else {
      wave.updateWaveform();
    }
    drawSelectionBar();
    drawGrid();
  }

  void drawSelectionBar() {
    fill(255, 100);
    stroke(255);
    float barLength = (float(displayedMs) / float(totalTime)) * displayX;
    int barXPos = round(displayX * (float(displayStart) /float(totalTime)));

    rectMode(CORNERS);
    rect(barXPos, displayY - barHeight, constrain(barLength + barXPos, barLength, displayX - 1), displayY);
  }

  void drawPlayhead(int pos) {
    float pixelsPerMs = float(displayX) / float(displayedMs);
    float offsetFromStart = pos - displayStart;
    if (offsetFromStart >= 0) {
      float xPos = offsetFromStart * pixelsPerMs;
      stroke(255);
      line(xPos, 0, xPos, waveformHeight);
    }
  }

  void switchDisplay() {
    spectralDisplay = !spectralDisplay;
  }


  void setPercPos(float percStart, float percLength) { //changes the start and end percentages within the loaded sample that should be displayed
    displayStart = int(percStart * float(totalTime));
    displayedMs = int(percLength * float(totalTime));
    displayStart = constrain(displayStart, 0, totalTime - minMsDisplayed);
    displayedMs = constrain(displayedMs, minMsDisplayed, totalTime - displayStart);

    startDisplayPerc = float(displayStart) / float(totalTime); //calculate percentages from ms data
    endDisplayPerc = float(displayStart + displayedMs) / float(totalTime);

    //println("displayStart is now " + displayStart + " displayedMs is now " + displayedMs + " totalTime = " + totalTime);
  }

  void drawGrid() {
    float pixelsPerMs = float(displayX) / float(displayedMs);
    int msPerLine = 10000;
    if (displayedMs < 100000) msPerLine = 7000;
    if (displayedMs < 60000) msPerLine = 5000;
    if (displayedMs < 30000) msPerLine = 3000;
    if (displayedMs < 20000) msPerLine = 1000;
    if (displayedMs < 10000) msPerLine = 500; //these are the ms values the display will snap to.
    if (displayedMs < 5000) msPerLine = 100;

    //this draws the horizontal grid of time divisions
    for (int i = 0; i < displayedMs; i ++ ) { //iterate over all of the displayed ms (this might just be a bit clunky)
      if ((i + displayStart) % msPerLine == 0) {  //if we encounter a ms that fits within our current snapping setting (msPerLine)
        float xPos = (i * pixelsPerMs); //absolute xP os of grid
        int currentMs = constrain(i + displayStart, displayStart, displayEnd); //absolute ms we are working with now
        if (xPos > 0 && xPos < displayX) {
          if (currentMs % 100 == 0 && msPerLine <= 100 && currentMs % 1000 != 0 && currentMs % 500 != 0 ) {

            stroke(100, 100); //this is the color for the smallest interval
            textSize(8);
            if (displayedMs < 2000) text(currentMs / 1000. + "s", xPos + 20, displayY - (barHeight * 4));
          }
          if (currentMs % 500 == 0 && msPerLine <= 500 && currentMs % 1000 != 0) { //if this half a second, and not a hunderdth of a second or a whole one
            stroke(200, 100); /// if this is a half second
            textSize(9);
            text(currentMs / 1000. + "s", xPos + 15, displayY - (barHeight *3));
          }
          if (currentMs % 1000 == 0) { //if this is a whole second
            stroke(200, 150);
            textSize(10);
            text(currentMs / 1000 + "s", xPos + 10, displayY - (barHeight * 2));
          }
          line(xPos, 0, xPos, displayY - barHeight);
        }
      }
    }

    stroke(255);
    line(0, displayY - barHeight, displayX, displayY - barHeight); //bottom line
  }

  int getAbsoluteTime(int xPos) {
    int absoluteTime = 0;
    if (spectralDisplay) {
      absoluteTime = spec.getAbsoluteTime(xPos);
    } else {
    }
    return absoluteTime;
  }
}
