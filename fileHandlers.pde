void selectNewFile() {
  fileLoaded = false;
  if (player != null) {
    player.pause();
  }
  selectInput("Select a file to process:", "fileSelected");
}

void loadNewFile(String fullFileName) {
  int startTime = millis();//record starting time
  File f = new File(fullFileName);
  fileName = f.getName();
  loadingFile = true;
  // fileName = fileName[fileName.length];
  println("loading file: " + fullFileName);
  if (fileLoaded) {
    println("disposing player object...");
    minim.debugOn();
    player.close();
    sound.close();
    minim.debugOff();
    // player.remove();
    // sound.remove();
  }

  fileLoaded = false;

  try {
    sound = minim.loadSample(fullFileName);
    player = minim.loadFile(fullFileName);
    fft = new FFT(player.bufferSize(), 2048 * 4);
    initRealTimeSpectrum();
    display = new Display(sound, width, waveformHeight);
    // spec = new Spectrum(sound, 2048, width , waveformHeight);
    fileLoaded = true;
    errorOccured = false;
    // thread("makeWaveform");
    // thread("initSpectrum");
    } catch (Exception e) {
      e.printStackTrace();
      println("something went wrong");
      errorOccured = true;
    }
    loadingFile = false;
    int endTime = millis() - startTime;
    loadingTimeText = new FadingText(width - 200, 50, 10000, "Loaded file in " + endTime + "ms");
  }

  void fileSelected(File selection) {
    if (selection == null) {
      println("Window was closed or the user hit cancel.");
      errorOccured = true;
      } else {
        println("User selected " + selection.getAbsolutePath());
        loadNewFile(selection.getAbsolutePath());
      }
    }
