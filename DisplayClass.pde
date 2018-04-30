class Display {
  Spectrum spec;
  Waveform wave;
  int displayStart = 0; //beginning of display in ms
  int displayEnd = 0; //end of display in ms
  int displayedMs = 0; //total displayed milliseconds
  int minMsDisplayed = 20; //minimal ms displayed (also most you can zoom in)
  int positionInFile = 0;

  float startDisplayPerc = 0.; //percentage where the display starts within the sample
  float endDisplayPerc = 1.; //percentage where the display ends within the sample
  float displayedPerc = 1.; //total percentage displayed in display
  float posPerc = 0.;

  int displayX; //width of display
  int displayY; //height of display

  int totalTime = 0; //total time of loaded sample

  int barHeight = 10; //height of selection bar at bottom

  boolean spectralDisplay = true; //toggle between waveform and spectrum
  boolean mouseOver = false;
  boolean showInfo = false;


  boolean followPlayhead = false;
  int followPlayheadOffset = 0;

  LPFilter playheadFilter;
  LPFilter startDisplayFilter;
  LPFilter endDisplayFilter;
  LPFilter displayLengthFilter;

  Display(AudioSample sample, int displayX, int displayY) {
    this.displayX = displayX;
    this.displayY = displayY;

    this.totalTime = sample.length();
    this.displayEnd = totalTime;
    this.displayedMs = totalTime;

    println("Total time in display = " + totalTime);

    spec = new Spectrum(sample, 1024, displayX, displayY);
    wave = new Waveform(sample, displayX, displayY);
    playheadFilter = new LPFilter(0.);
    startDisplayFilter = new LPFilter(0.);
    endDisplayFilter = new LPFilter(0.);
    displayLengthFilter = new LPFilter(0.);
  }

  void update() {
    if (spectralDisplay) {
      // if (followPlayhead) setAbsPos(positionInFile - followPlayheadOffset, displayedMs);
      spec.updateSpectrum(displayX, displayY, startDisplayPerc, endDisplayPerc);
      if (followPlayhead) {
        //first we calculate where the display should start keeping the same percentage from the playhead
        float startPerc = (float(display.positionInFile) / float(display.totalTime)) - (float(followPlayheadOffset) / float(totalTime));
        // the we check how long the display should be
        float endPerc = float(displayedMs) / float(totalTime);
        this.setPercPos(startPerc, endPerc); //make sure the display follows the playhead
      }
    } else if (!spectralDisplay){
      wave.updateWaveform();
    }
    drawSelectionBar();
    drawGrid();
  }

  void drawInfo() {
    if (showInfo && mouseX < displayX && mouseY < waveformHeight) {
      if (!mousePressed) {
        String msString = getAbsoluteTime(mouseX) / 1000. + "s";
        String freqString = spec.getHz(mouseY) + "Hz";
        String ampString = "power: " + nfc(spec.getAmp(mouseX, mouseY), 2);
        pushMatrix();
        translate(10, - 35);
        // String hzString =
        rectMode(CORNER);
        stroke(255);
        fill(255,100);
        rect(mouseX, mouseY,70, 35);

        stroke(255);
        fill(255);
        textSize(10);
        textAlign(CORNER);
        text(msString, mouseX, mouseY + 10);
        text(freqString, mouseX, mouseY + 20);
        text(ampString, mouseX, mouseY + 30);
        popMatrix();
        // text()
      }
    }
  }




  void switchFollowPlayhead() {
    followPlayhead = !followPlayhead;
    followPlayheadOffset = positionInFile - displayStart;
    println("follow playhead is " + followPlayhead);
    println("followPlayheadOffset = " + followPlayheadOffset);
  }

  void drawSelectionBar() {
    fill(255, 100);
    stroke(255);
    float barLength = (float(displayedMs) / float(totalTime)) * displayX;
    int barXPos = round(displayX * (float(displayStart) /float(totalTime)));

    rectMode(CORNERS);
    rect(barXPos, displayY - barHeight, constrain(barLength + barXPos, barLength, displayX - 1), displayY);

    //draw smaller playhead in selectionbar
    if (followPlayhead) {
      stroke(100,10,35);
      fill(100,10,35);
    }
    else {
      stroke(255);
      fill(255);
    }
    float xPos = (float(positionInFile) / float(totalTime)) * displayX;
    rectMode(CORNER);
    rect(xPos, displayY - barHeight, 3, barHeight);
  }

  void drawPlayhead(int pos) {
    float pixelsPerMs = float(displayX) / float(displayedMs);
    float offsetFromStart = pos - displayStart;
    positionInFile = pos;
    posPerc = float(positionInFile) / float(totalTime);
    if (offsetFromStart >= 0) {
      float xPos = offsetFromStart * pixelsPerMs;
      xPos = playheadFilter.update(xPos, 0.5);
      if (followPlayhead) {
        stroke(100,10,35);
        strokeWeight(5);
      }
      else {
        stroke(255);
        strokeWeight(1);
      }
      line(xPos, 0, xPos, waveformHeight);
    } else if (offsetFromStart < 0) playheadFilter.update(0,0.5);
      else if (offsetFromStart > displayX) playheadFilter.update(width, 0.5);
  }

  void switchDisplay() {
    spectralDisplay = !spectralDisplay;
  }


  void setPercPos(float percStart, float percLength) { //changes the start and end percentages within the loaded sample that should be displayed
    displayStart = int(percStart * float(totalTime)); //time of start in ms
    displayedMs = int(percLength * float(totalTime)); //displayed ms in ms
    displayStart = constrain(displayStart, 0, totalTime - minMsDisplayed);
    displayedMs = constrain(displayedMs, minMsDisplayed, totalTime - displayStart);

    startDisplayPerc = float(displayStart) / float(totalTime); //calculate percentages from ms data
    endDisplayPerc = float(displayStart + displayedMs) / float(totalTime);
    displayedPerc = float(displayedMs) / float(totalTime);
    //startDisplayPerc = startDisplayFilter.update(startDisplayPerc, 0.8);
    //endDisplayPerc = endDisplayFilter.update(endDisplayPerc, 0.8);
    //displayedPerc = displayLengthFilter.update(displayedPerc, 0.8);

    //println("displayStart is now " + displayStart + " displayedMs is now " + displayedMs + " totalTime = " + totalTime);
  }

  void setAbsPos(int startPos, int displayedMs) {
    startDisplayPerc = float(startPos) / float(totalTime); //calculate percentages from ms data
    endDisplayPerc = float(startPos + displayedMs) / float(totalTime);
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
        fill(200, 150); // text color for grid
        if (xPos > 0 && xPos < displayX) {
          if (currentMs % 100 == 0 && msPerLine <= 100 && currentMs % 1000 != 0 && currentMs % 500 != 0 ) {
            stroke(100, 100); //this is the color for the smallest interval
            textSize(8);
            if (displayedMs < 2000) text(currentMs / 1000. + "s", xPos + 20, displayY - (barHeight * 3));
          }
          if (currentMs % 500 == 0 && msPerLine <= 500 && currentMs % 1000 != 0) { //if this half a second, and not a hunderdth of a second or a whole one
            stroke(200, 100); /// if this is a half second
            textSize(9);
            text(currentMs / 1000. + "s", xPos + 15, displayY - (barHeight *2));
          }
          if (currentMs % 1000 == 0) { //if this is a whole second
            stroke(200, 150);
            textSize(10);
            text(currentMs / 1000 + "s", xPos + 10, displayY - (barHeight * 1.5));
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

  void setYScale(float _YScale) {
    if (spectralDisplay) {
      spec.setYScale(_YScale);
    } else {
      wave.setYScale(_YScale);
    }
  }

  void incrementYScale(float increment) {
    spec.incrementYScale(increment);
  }
  void setGain(float _gain) {
    println("setting gain to: " + _gain);
    spec.setGain(_gain);
  }

  float getGain() {
    return spec.gain;
  }

  void incrementContrast(float increment) {
    spec.contrast = spec.contrast + increment;
    println("Changed contrast to: " + spec.contrast);
  }

  void centerDisplay() {
    float halfDisplayedPerc = display.displayedPerc / 2.;
      if (!followPlayhead) {
        setPercPos(display.posPerc - halfDisplayedPerc, displayedPerc);
      } else {
        followPlayheadOffset = int(halfDisplayedPerc * float(totalTime));
      }
  }

  void zoomIn(float perc) {
    float startPerc =(float(positionInFile) / float(totalTime)) - perc;
    float endPerc = (endDisplayPerc - startDisplayPerc) - perc;
    println("zooming in to: " + startPerc + " , " + endPerc);
    setPercPos(startPerc, endPerc);
    centerDisplay();
  }

  void zoomOut(float perc) {
    float startPerc =(float(positionInFile) / float(totalTime)) - perc;
    float endPerc = (endDisplayPerc - startDisplayPerc) + perc;;
    println("zooming out");
    setPercPos(startPerc, endPerc);
    centerDisplay();
  }

  void writeFFT() {
    spec.writeFFTToFile();
  }
}