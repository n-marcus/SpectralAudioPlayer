class Spectrum {
  AudioSample sample;
  int fftSize;
  float yScale = 0.2;
  float pixelsPerChunk = 2;
  int displayX = width;
  int displayY = height;
  int startChunk = 0;
  int endChunk = 1000;
  int numChunks = endChunk;
  int totalChunks = 0;
  int _displayX;
  int _displayY;
  float _startPerc;
  float _endPerc;
  float increment;
  boolean debug = false;
  int barHeight = 10;
  float[][] spectra;
  float[] yPosArray;
  float gain = 1.;

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

  void drawSpectrum() {
    float xPos = 0; //initialize x position
    int skipEvery = 1;
    if (pixelsPerChunk < 0.9) {

       skipEvery = int(1./(pixelsPerChunk + 0.1));
       // skipEvery = constrain(skipEvery, 1, 1000);
       // println("pixels per chunk = " + pixelsPerChunk + "skip every " + skipEvery);
    }

    for (int i = startChunk; i < startChunk + numChunks && i < spectra.length - 1; i += 1) { //as long as we are between the startChunk and endChunk and not over the lenght of available chunks
      xPos += pixelsPerChunk;// + (increment - 1); //move everything xScale  to the right
      for (int j = 0; j < spectra[i].length; j ++) {
        if (spectra[i][j] > .05 && (i + 1) % skipEvery == 0) {
          float yPos = displayY - yPosArray[j];
          if (yPos > 0 && yPos > displayY && xPos > 0 && xPos < displayX) {}
            float nextYPos = 0.;
            if (j < yPosArray.length - 1) {
              nextYPos = displayY - yPosArray[j + 1];
            }

            float brightness = map(spectra[i][j] * gain, 0.0, 35., 0., 300.);

            //draw actual points
            point(xPos, yPos);
            strokeWeight(1);
            stroke(brightness);
            // line(xPos, yPos, xPos, nextYPos);
        }
      }
    }
  }




  void updateSpectrum(int displayX, int displayY, float startPerc, float endPerc) { //displayY is height of display, displayX is width, startPerc is the percentage from where the display should start within the sample (0.0 - 1.0)

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
      this.drawSpectrum();
    }




    int getAbsoluteTime(int xPos) {
      float mousePerc = float(xPos) / displayX;
      int firstDisplayedSample = startChunk * fftSize;
      int lastDisplayedSample = endChunk * fftSize;
      int totalDisplayedSamples = lastDisplayedSample - firstDisplayedSample;
      float mouseTime = round(mousePerc * totalDisplayedSamples + firstDisplayedSample);
      mouseTime = (mouseTime / sample.sampleRate()) * 1000; //go from samples to seconds
      mouseTime = constrain(mouseTime, 0, numChunks * fftSize);
      if (debug) {
        println("First displayed sample = " + firstDisplayedSample + " last displayed sample = " + lastDisplayedSample + " total displayed samples = " + totalDisplayedSamples);
        println("mousePerc = " + mousePerc);
        println("mouseTime = " + mouseTime);
      }
      return int(mouseTime);
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
      totalChunks = (leftChannel.length / fftSize) + 1;

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
          for (int i = 0; i < fftSize/2; ++i)
          {
            float power = fft.getBand(i);
            //if (power > 0.0) {
            power = 10 * log(power);
            spectra[chunkIdx][i] = power;

            //}
          }
        }

        yPosArray = new float[spectra[0].length];
        for (int i = 0; i < yPosArray.length; i ++) {
          float val = (sqrt(i *(yScale * width))) * 1.1;
          yPosArray[i] = val;
          // println("Setting yPos " + i + " to " + yPosArray[i]);

        }
        // println(yPosArray);

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

      void setYScale(float _YScale) {
        this.yScale = _YScale;
        println("Set yScale to: " + this.yScale);
        for (int i = 0; i < yPosArray.length; i ++) {
          float val = (sqrt(i *(yScale * width))) * 1.1;
          yPosArray[i] = val;
          // println("Setting yPos " + i + " to " + yPosArray[i]);

        }
      }

      float getHz(int yPos) {
        // println("Looking for band at yPos " + yPos);
        yPos = displayY - yPos;
        float distance = Math.abs(yPosArray[0] - yPos);
        int bandNumber = 0;
        for(int c = 1; c < yPosArray.length; c++){
            float cdistance = Math.abs(yPosArray[c] - yPos);
            if(cdistance < distance){
                bandNumber = c;
                distance = cdistance;
            }
        }
        float theNumber = yPosArray[bandNumber];
        // println("bandNumber = " + bandNumber);

        float freqCenter = (float(bandNumber) / float(fftSize)) * sample.sampleRate();
        // println("freqCenter = " + freqCenter);
        return freqCenter;
      }

      void setGain(float _gain) {
        this.gain = _gain;
      }
    }
