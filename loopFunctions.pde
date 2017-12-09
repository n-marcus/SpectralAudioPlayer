void makeLoop() { //this function translates the mouse position to looping points
  if (!mouseRightDragged) loopInPixels = mouseX; //mouse point when clicked is start point
  mouseRightDragged = true;
  madeLoop = true;
  loopOutPixels = mouseX; //loop out point is variable till mouseReleased

  loopIn = xPos2Time(loopInPixels); //translate to time
  loopOut = xPos2Time(loopOutPixels);
  println("loop is between " + loopIn + "s and " + loopOut + "s");

}


void showLoop() {
  fill(255,10);
  rectMode(CORNERS);
  rect(loopInPixels, 0, loopOutPixels, waveformHeight - bord * 2);
  rectMode(CORNER);

  fill(175);
  text(loopIn/1000. + "s", loopInPixels + 5, 20);
  text(loopOut/1000. + "s", loopOutPixels + 5, 30);
}


void checkLoop() {
  if (madeLoop) {
    if (loopIn < loopOut) {
      if (player.position() > loopOut) {
        player.cue(loopIn);
      }
    } else if (loopOut < loopIn) {
      if (player.position() > loopIn) {
        player.cue(loopOut);
      }
    } else if (loopOut == loopIn) {
        println("loop points are the same");
    }
  }
}
