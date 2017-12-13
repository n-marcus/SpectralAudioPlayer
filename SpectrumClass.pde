class Spectrum {
  AudioSample sample;
  int fftSize;
  float yScale = 0.5;
  float pixelsPerChunk = 2;
  int displayX = width;
  int displayY = height;
  int startChunk = 0;
  int endChunk = 1000;
  int numChunks = endChunk;
  int _displayX;
  int _displayY;
  float _startPerc;
  float _endPerc;
  float increment;
  boolean debug = true;
  int barHeight = 10;

  Spectrum(AudioSample _sample, int _fftSize) {
    sample = _sample;
    fftSize = _fftSize;
    calcSpectrum();
  }

  Spectrum(AudioSample _sample, int _fftSize, int displayX, int displayY) {
    sample = _sample;
    fftSize = _fftSize;
    calcSpectrum();
    this.displayX = displayX;
    this.displayY = displayY - barHeight; //we dont draw over the selection bar
  }

  void update() {
    float xPos = 0; //initialize x position
    for (int i = startChunk; i < startChunk + numChunks && i < spectra.length - 1; i += 1) { //as long as we are between the startChunk and endChunk and not over the lenght of available chunks
      xPos += pixelsPerChunk;// + (increment - 1); //move everything xScale  to the right
      for (int j = 0; j < spectra[i].length; j ++) {
        if (spectra[i][j] > 0.0) {
          float yPos = displayY - getYPos(j);
          float nextYPos = 0.;
          if (j < spectra[i].length) {
            nextYPos = displayY - getYPos(j + 1);
          }
          float brightness = map(spectra[i][j], 0.0, 35., 0., 300.);

          //draw actual points
          //point(xPos, yPos);
          stroke(brightness);
          strokeWeight(1);
          line(xPos, yPos, xPos, nextYPos);
        }
      }
    }
    drawSelectionBar(numChunks, startChunk);
  }


  void drawSpectrum(int displayX, int displayY, float startPerc, float endPerc) { //displayY is height of display, displayX is width, startPerc is the percentage from where the display should start within the sample (0.0 - 1.0)


    if (_displayX != displayX || _displayY != displayY || _startPerc != startPerc || _endPerc != endPerc) { //check if input has changed, if not, no draw
      this.displayX = displayX;
      this.displayY = displayY - barHeight; //we dont draw over the selection bar

      startPerc = constrain(startPerc, 0.0, 1.0);
      endPerc = constrain(endPerc, 0.0, 1.0);

      startChunk = int(startPerc * float(spectra.length)); //this is the chunk the fft display start at
      endChunk = int(endPerc * float(spectra.length)); //this is the chunk the fft display stops at
      numChunks = constrain(endChunk - startChunk, 20, spectra.length); //total number of chunks to be displayed


      pixelsPerChunk = float(displayX) / float(numChunks); //the horizontal space between two chunks within the chunk buffer

      //if we zoom out enough that chunks would start overlaying, skip a chunk
      increment = constrain(round(1. / pixelsPerChunk), 1, 500);

      //keep track of changes
      _displayX = displayX;
      _displayY = displayY;
      _startPerc = startPerc;
      _endPerc = endPerc;

      if (debug) {
        println("StartChunk = " + startChunk + " endChunk = " + endChunk + " numChunks = " + numChunks);
        println("Pixels per Chunk = " + pixelsPerChunk);
        println("skipping " + increment + " chunks because of pixel folding");
      }
      } else {
        if (debug) println("nothing changed");
      }
      this.update();
    }


    void drawSelectionBar(int numChunks, int startChunk) {
      fill(255, 100);
      stroke(255);
      float barLength = (float(numChunks) / float(spectra.length)) * displayX;
      int barXPos = round(displayX * (float(startChunk) /float(spectra.length)));

      rectMode(CORNER);
      rect(barXPos, displayY - barHeight - (bord / 2), barLength, barHeight);
    }


    void calcSpectrum() {
      int startTime = millis();

      // get the left channel of the audio as a float array
      // getChannel is defined in the interface BuffereAudio,
      // which also defines two constants to use as an argument
      // BufferedAudio.LEFT and BufferedAudio.RIGHT
      float[] leftChannel = sample.getChannel(AudioSample.LEFT);

      //float samplesPerPixel = leftChannel.length / float(width);
      //println("Samples per pixel = " + samplesPerPixel);

      // then we create an array we'll copy sample data into for the FFT object
      // this should be as large as you want your FFT to be. generally speaking, 1024 is probably fine.
      float[] fftSamples = new float[fftSize];
      FFT fft = new FFT( fftSize, sample.sampleRate() );

      // now we'll analyze the samples in chunks
      int totalChunks = (leftChannel.length / fftSize) + 1;

      // allocate a 2-dimentional array that will hold all of the spectrum data for all of the chunks.
      // the second dimension if fftSize/2 because the spectrum size is always half the number of samples analyzed.
      spectra = new float[totalChunks][fftSize/2];

      for (int chunkIdx = 0; chunkIdx < totalChunks; ++chunkIdx)
      {
        int chunkStartIndex = chunkIdx * fftSize;

        // the chunk size will always be fftSize, except for the
        // last chunk, which will be however many samples are left in source
        int chunkSize = min( leftChannel.length - chunkStartIndex, fftSize );

        // copy first chunk into our analysis array
        System.arraycopy( leftChannel, // source of the copy
          chunkStartIndex, // index to start in the source
          fftSamples, // destination of the copy
          0, // index to copy to
          chunkSize // how many samples to copy
          );

          // if the chunk was smaller than the fftSize, we need to pad the analysis buffer with zeroes
          if ( chunkSize < fftSize )
          {
            // we use a system call for this
            java.util.Arrays.fill( fftSamples, chunkSize, fftSamples.length - 1, 0.0 );
          }

          // now analyze this buffer
          fft.forward( fftSamples );

          // and copy the resulting spectrum into our spectra array
          for (int i = 0; i < 512; ++i)
          {
            float power = fft.getBand(i);
            //if (power > 0.0) {
            power = 10 * log(power);
            spectra[chunkIdx][i] = power;

            //}
          }
        }

        sample.close();
        println("Made FFT data in " + (millis() - startTime) + "ms");
        println("Number of horizontal points = " + spectra.length);
        println("Number of freq points = " + spectra[0].length);
        println("Total number of points to be drawn = " + (spectra.length * spectra[0].length));
      }

      float getYPos(int i) {
        float yPos = (sqrt(i *(yScale * width))) * 1.1;
        return yPos;
      }
    }
