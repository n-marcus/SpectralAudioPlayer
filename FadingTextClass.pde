class FadingText {
  float alpha = 255;
  int startTime = 0;
  int endTime = 0;
  int totalTime = 0;
  float decrement = 1.;
  String text = "";
  int xPos;
  int yPos;
  boolean fading = true;

  FadingText(int xPos, int yPos, int duration, String text) {
    this.text = text;
    this.xPos = xPos;
    this.yPos = yPos;

    startTime = millis();
    endTime = startTime + duration;
    totalTime = duration;
    decrement = 255. / float(totalTime);
    textSize(12);
  }

  void update() {
    if (alpha > 0) {
      alpha = 255. - (decrement * (millis() - startTime));
      fill(255, alpha);
      textSize(12);
      text(this.text, xPos, yPos);
    } else {
      fading = false;
    }
  }
}