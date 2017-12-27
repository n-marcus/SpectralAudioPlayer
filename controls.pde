
void keyPressed()
{
  println("keyCode " + keyCode);
  if (keyCode == 9) {
    display.switchDisplay();
  }


  if (keyCode == 32) { //space key
    if (player.isPlaying()) player.pause();
    else if (!madeLoop) {
      player.play();
    }
    else if (madeLoop) {
      player.cue(loopIn);
      player.play();
    }
    if (player.position() >= player.length()) {
      player.rewind();
      player.play();
    }
  }

  if (key == 'l') { // loop key
    madeLoop =! madeLoop;
  }

  if (key == 'n') { // load new file
    selectNewFile();
  }
  if (key == 'f') {
    display.switchFollowPlayhead();
  }
  if (key == 'i') {
    display.showInfo = !display.showInfo;
  }

  if (key == 'c') {
    float halfDisplayedPerc = display.displayedPerc / 2.;
    if (!display.followPlayhead) {
      display.setPercPos(display.posPerc - halfDisplayedPerc, display.displayedPerc);
      } else {
      display.followPlayheadOffset = int(halfDisplayedPerc * float(display.totalTime));
      }
    }

  if (keyCode == 17) {
    controlPressed = true;
  }

  if (keyCode == 16) {
    shiftPressed = true;
  }

  if (key == 'x') {
    exit();
  }

  if (controlPressed && shiftPressed && keyCode == 61) {
    display.setGain(display.getGain() + 0.2);
  }

  if (controlPressed && shiftPressed && keyCode == 45) {
    display.setGain(display.getGain() - 0.2);
  }

  if (controlPressed && !shiftPressed && keyCode == 61) {
    float startPerc =(float(display.positionInFile) / float(display.totalTime)) - 0.1;
    float endPerc = (display.endDisplayPerc - display.startDisplayPerc) - 0.05;
    println("zooming in to: " + startPerc + " , " + endPerc);
    display.setPercPos(startPerc, endPerc);
  }

  if (controlPressed && !shiftPressed && keyCode == 45) {
    float startPerc =(float(display.positionInFile) / float(display.totalTime)) - 0.1;
    float endPerc = (display.endDisplayPerc - display.startDisplayPerc) + 0.05;
    println("zooming out");
    display.setPercPos(startPerc, endPerc);

  }
}

void mouseDragged() {
  if (mouseButton == RIGHT) {
    // makeLoop();
  }
}

void mouseReleased() {
  if (mouseButton == 39) {
    mouseRightDragged = false;
  }

  if (mouseButton == 37 && !keyPressed && mouseY < waveformHeight) {
    if (player != null) player.cue(display.getAbsoluteTime(mouseX));
  }
  println("released mousebutton " + mouseButton);
}


void keyReleased() {
  if (keyCode == 17) {
    controlPressed = false;
  }

  if (keyCode == 16) {
    shiftPressed = false;
  }
}
