
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

    if (key == 'l') madeLoop =! madeLoop;
    else if (key == 'n') selectNewFile();
    else if (key == 'f')  display.switchFollowPlayhead();
    else if (key == 'i')  display.showInfo = !display.showInfo;
    else if (key == 'h')  showHelp = !showHelp;
    else if (key == 'c')  display.centerDisplay();

  //  case 'x': exit();









  if (controlPressed) {
    if (keyPressed && keyCode == 39) player.cue(player.position() + 1000); //skip forward one second
    if (keyPressed && keyCode == 37) player.cue(player.position() - 1000);
    if (keyPressed && keyCode == 38) display.incrementContrast(0.3);
    if (keyPressed && keyCode == 40) display.incrementContrast(-0.3);
    if (shiftPressed && keyCode == 38) display.setGain(display.getGain() - 0.2);
    if (shiftPressed && keyCode == 40) display.setGain(display.getGain() + 0.2);

    if (!shiftPressed && keyCode == 61) display.zoomIn(0.1);
    if (shiftPressed && keyCode == 61) display.zoomIn(0.01);
    if (!shiftPressed && keyCode == 45) display.zoomOut(0.1);
    if (shiftPressed && keyCode == 45) display.zoomOut(0.01);
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
