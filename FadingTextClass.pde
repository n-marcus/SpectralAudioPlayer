class FadingText {
  float alpha = 255;
  int startTime = 0;
  int endTime = 0;
  int totalTime = 0;
  float decrement = 1.;
  String text = "";
  int xPos;
  int yPos;
  boolean alive = true;

  FadingText(int xPos, int yPos, int duration, String text) {
    this.text = text;
    this.xPos = xPos;
    this.yPos = yPos;

    this.startTime = millis();
    this.endTime = startTime + duration;
    this.totalTime = duration;
    this.decrement = 255. / float(totalTime);
  }

  void update() {
    if (this.alpha > 0) {
      this.alpha = 255. - (decrement * (millis() - startTime));
      fill(255, alpha);
      textSize(12);
      text(this.text, xPos, yPos);
    } else {
      this.alive = false;
    }
  }
}
