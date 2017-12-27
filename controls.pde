
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

  if (keyCode == 17) {
    controlPressed = true;
  }

  if (key == 'x') {
    exit();
  }

  if (controlPressed && keyCode == 61) {
         display.setGain(display.getGain() + 0.2);
  }

  if (controlPressed && keyCode == 45) {
             display.setGain(display.getGain() - 0.2);
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
}
