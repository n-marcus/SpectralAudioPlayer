
void keyPressed()
{
  println("keyCode " + keyCode);
  switch (keyCode) { //handle keyCode presses
    case 9: //tab key
      display.switchDisplay();
    case 32: //space
      if (player.isPlaying()) player.pause();
      else if (!madeLoop) player.play();
      else if (madeLoop) {
        player.cue(loopIn);
        player.play();
      }
      if (player.position() >= player.length()) {
        player.rewind();
        player.play();
      }


  }

  if (keyCode == 17) {
    controlPressed = true;
    println("controlPressed = true");
  }
  else if (keyCode == 16) {
    shiftPressed = true;
    println("shiftPressed = true");
  }

  switch (key) {
    case 'l': madeLoop =! madeLoop;
    case 'n': selectNewFile();
    case 'f': display.switchFollowPlayhead();
    case 'i': display.showInfo = !display.showInfo;
    case 'h': showHelp = !showHelp;
    case 'c':
    float halfDisplayedPerc = display.displayedPerc / 2.;
      if (!display.followPlayhead) {
        display.setPercPos(display.posPerc - halfDisplayedPerc, display.displayedPerc);
      } else {
        display.followPlayheadOffset = int(halfDisplayedPerc * float(display.totalTime));
      }
  //  case 'x': exit();
  }


  if (controlPressed && shiftPressed && keyCode == 61) {
    display.setGain(display.getGain() + 0.2);
    println("shiftPressed = " + shiftPressed);
    println("controlPressed = " + controlPressed);

  }

  if (controlPressed && shiftPressed && keyCode == 45) {
    display.setGain(display.getGain() - 0.2);
    println("shiftPressed = " + shiftPressed);
    println("controlPressed = " + controlPressed);
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



  if (controlPressed) {
    if (keyPressed && keyCode == 39) player.cue(player.position() + 1000); //skip forward one second
    if (keyPressed && keyCode == 37) player.cue(player.position() - 1000);
    if (keyPressed && keyCode == 38) display.incrementContrast(0.4);
    if (keyPressed && keyCode == 40) display.incrementContrast(-0.4);
  } else {
    if (keyPressed && keyCode == 39) player.cue(player.position() + 5000); //skip forward five seconds
    if (keyPressed && keyCode == 37) player.cue(player.position() - 5000);
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
    println("controlPressed = false");
  }

  if (keyCode == 16) {
    shiftPressed = false;
    println("shiftPressed = false");

  }
}

void checkButtons() { //this runs every loop and looks for action to be repeated when a key is held

}
