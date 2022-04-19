// CONSTANTS

int GAP = 50;
int BEFORE_PLAY=10;


class SampleRobot {
  AudioRecorder recorder;
  public String nameRoot;
  
  int volume; // volume we're going to record at
  int startNote; // MIDI note we start with
  int currentNote; // current note we're recording
  int stopNote; // highest note to record
  int step; // step between notes
  
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


  MidiBus bus;
  String[] noteNames = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"};
  DecentBuilder decentBuilder;

  SampleRobot(String nr, int vol, int start, int noOctaves, int stepLen, int ndl, int sl) {
    nameRoot = nr;
    decentBuilder = new DecentBuilder(nameRoot);
    startNote = start-step;
    currentNote = startNote;
    stopNote = startNote+(noOctaves*12);
    step = stepLen;
    noteDownLength = ndl;
    sampleLength = sl;
    bus = new MidiBus(this, -1, "USB MIDI Interface ");    
    volume = vol;
  }

  String fileName(int note) {
    int octave = (int)(note/12);
    return nameRoot+"_"+noteNames[(note-startNote)%12]+octave+"_" + volume+".wav";
  }


  void startNext() {
    recorder = minim.createRecorder(in, fileName(currentNote));
    startTime = millis();
    noteOnTime = startTime+BEFORE_PLAY;
    noteOffTime = noteOnTime+noteDownLength;
    stopRecordTime = noteOnTime+sampleLength;    
    startedFlag = false;
    recorder.beginRecord(); // we start record immediately
  }

  void step() {
    if (isRecording()) {
      recordingStep();
    } else {
      nonRecordingStep();
    }
  }
  
  boolean isRecording() {
    if (recorder == null) { return false; }
    return recorder.isRecording();
  }

  void recordingStep() {
      text("Currently recording " + fileName(currentNote), 5, 15);

      long currentTime = millis(); // current time in milliseconds
      
      if ((currentTime > noteOnTime) && (!startedFlag)) {
        decentBuilder.addSampleLine(currentNote, step, fileName(currentNote));
        bus.sendNoteOn(0, currentNote, volume);
        startedFlag = true;
        return;
      }

      if (currentTime > noteOffTime) {
        bus.sendNoteOff(0, currentNote, volume);
      }

      if (currentTime > stopRecordTime) {
        recorder.endRecord();  
        gapflag=GAP;
        if (currentNote >= stopNote) { 
          shutdown();
        }
      }
  }
  
  void nonRecordingStep() {
      text("Not recording", 5, 15);

      if (gapflag > 0) { 
        gapflag = gapflag - 1;
      } else {
        currentNote = currentNote + step;
        startNext();
      }    
  }
    
  void shutdown() {
    decentBuilder.write();
    exit();
  }
}
