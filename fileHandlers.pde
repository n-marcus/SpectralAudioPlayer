void selectNewFile() {
  fileLoaded = false;
  if (player != null) {
    player.pause();
  }
  selectInput("Select a file to process:", "fileSelected");
}

void loadNewFile(String fileName) {
  println("loading file: " + fileName);
  try {
    sound = minim.loadSample(fileName);
    player = minim.loadFile(fileName);
    fft = new FFT(player.bufferSize(), player.sampleRate());
    initRealTimeSpectrum();
    spec = new Spectrum(sound, 2048, width, waveformHeight);
    fileLoaded = true;

    thread("makeWaveform");
    // thread("initSpectrum");
    } catch (Exception e) {
      e.printStackTrace();
      println("something went wrong");
      errorOccured = true;
    }
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
