// CONSTANTS

int GAP = 50;
int BEFORE_PLAY=10;

enum RobotState {
  RECORDING_PHASE, 
    COVER_DRAWING_PHASE, 
    ;
}

class SampleRobot {
  AudioRecorder recorder;
  MidiBus bus;
  DecentBuilder decentBuilder;
  RobotState state = RobotState.RECORDING_PHASE ;
  IGraphic graphic;

  public String nameRoot;


  BothRanges bothRanges; // the note and volume ranges

  // these variables control the time of an individual recording
  // in millisecond
  long noteDownLength; // length of time for holding note down
  long sampleLength; // how long is sample altogether
  long startTime;  // capture time when we start recording
  long noteOnTime; // time we send the NoteOn message
  long noteOffTime; // time we send the NoteOff message
  long stopRecordTime; // time we stop recording
  long gapflag=0; // counter between recordings
  boolean startedFlag = false;  // have we sent the NoteOn?

  // cached values
  int currentNote;
  int currentVol;
  String currentFileName;

  SampleRobot(String nr, IGraphic gr, IntRange nRange, IntRange vRange, int ndl, int sl) {
    nameRoot = nr;
    graphic = gr;
    decentBuilder = new DecentBuilder(nameRoot);

    bothRanges = new BothRanges(vRange, nRange);

    noteDownLength = ndl;
    sampleLength = sl;
    bus = new MidiBus(this, -1, "USB MIDI Interface ");
  }

  String[] noteNames = {"A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#" };

  String getNoteName(int note) {
    return noteNames[(note-21)%12];
  }

  String getOctave(int note) {
    return ""+(1+ (int)( (note-24)/12));
  }

  String fileName(int note, int volume) {
    return nameRoot+"_"+getNoteName(note)+getOctave(note)+"_" + volume+".wav";
  }


  void startNext() {

    currentNote = bothRanges.getNote();
    currentVol = bothRanges.getVol();
    currentFileName = fileName(currentNote, currentVol);
    recorder = minim.createRecorder(AUDIO_INPUT, currentFileName);
    startTime = millis();
    noteOnTime = startTime+BEFORE_PLAY;
    noteOffTime = noteOnTime+noteDownLength;
    stopRecordTime = noteOnTime+sampleLength;    
    startedFlag = false;
    bothRanges.advance();
    recorder.beginRecord(); // we start record immediately
  }

  void step() {
    switch (state) {
    case COVER_DRAWING_PHASE:
      if (graphic.isFinished()) {
        exit();
      }
      break;

    case RECORDING_PHASE:
      if (isRecording()) {
        recordingStep();
      } else {
        nonRecordingStep();
      }
      break;
    }
  }

  boolean isRecording() {
    if (recorder == null) { 
      return false;
    }
    return recorder.isRecording();
  }

  void recordingStep() {
    text("Currently recording " + currentFileName, 5, 15);

    long currentTime = millis(); // current time in milliseconds

    if ((currentTime > noteOnTime) && (!startedFlag)) {
      decentBuilder.addSampleLine(currentNote, bothRanges.getStep(), 
                  currentVol, bothRanges.volRange.step, currentFileName);
      bus.sendNoteOn(0, currentNote, currentVol);
      startedFlag = true;
      return;
    }

    if (currentTime > noteOffTime) {
      bus.sendNoteOff(0, currentNote, currentVol);
    }

    if (currentTime > stopRecordTime) {
      recorder.endRecord();  
      gapflag=GAP;
    }
  }

  void nonRecordingStep() {
    text("Not recording", 5, 15);

    if (gapflag > 0) { 
      gapflag = gapflag - 1;
    } else {
      
      if (bothRanges.finished()) { 
        startShutdownProcess();
      } else {
        startNext();
        
      }
    }
  }

  void startShutdownProcess() {
    state = RobotState.COVER_DRAWING_PHASE;
    decentBuilder.write();
    graphic.startDrawing();
  }

  void draw() {
    if (state == RobotState.COVER_DRAWING_PHASE) {
      graphic.draw();
    } else {
      background(0);
      for (int i = 0; i < AUDIO_INPUT.bufferSize() - 1; i++) {
        line(i, 150 + AUDIO_INPUT.left.get(i)*50, i+1, 150 + AUDIO_INPUT.left.get(i+1)*50);
        line(i, 250 + AUDIO_INPUT.right.get(i)*50, i+1, 250 + AUDIO_INPUT.right.get(i+1)*50);
      }
    }
  }
}
