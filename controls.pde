
void keyPressed()
{
  println("keyCode " + keyCode);
  if (keyCode == 9) {
    display.switchDisplay();
  }

  if (keyCode == 39) { //key right
    player.cue(player.position() + 1000);
    println("skipping 10 forward");
  }

  if (keyCode == 37) { //key left
    player.cue(player.position() - 1000);
    println("skipping 10 backwards");
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

  if (mouseButton == 37 && !keyPressed) {
    player.cue(display.getAbsoluteTime(mouseX));
  }
  println("released mousebutton " + mouseButton);
}
