
void keyPressed()
{
  if (keyCode == 32) {
    if (player.isPlaying()) player.pause();
    else if (!madeLoop) {
      player.play();
    }
    else if (madeLoop) {
      player.cue(loopIn);
      player.play();
    }
  }

  if (key == 'l') {
    madeLoop =! madeLoop;
  }

  if (key == 'n') {
    selectNewFile();
  }


  // if the player is at the end of the file,
  // we have to rewind it before telling it to play again
  else if ( player.position() == player.length() )
  {
    player.rewind();
    player.play();
  }
}

void setMousePos() {
  int mouseTime = xPos2Time(mouseX);
  println("mousePressed on " + mouseX + " mouseTime = " + mouseTime);
  if (mouseTime > loopIn && mouseTime > loopOut) madeLoop = false;‘’
  player.cue(mouseTime);

  println("playerpos = " + player.position());
}

void mouseDragged() {
  if (mouseButton == RIGHT) {
    makeLoop();
  }
}

void mouseReleased() {
  if (mouseButton == 39) {
    mouseRightDragged = false;
  }
  println("released mousebutton " + mouseButton);
}
