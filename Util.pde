public class IntRange {
  int lo, hi, step, _current;
  IntRange(int l, int h, int s) {
    lo = l;
    hi = h;
    step = s;
    reset();
  }

  void reset() {
    _current = lo;
  }

  boolean finished() {
    return _current >= hi-1;
  }

  void advance() {
    _current = _current + step;
  }

  int current() {
    return _current;
  }
}





class BothRanges {
  IntRange volRange;
  IntRange noteRange;
  boolean _finished = false;

  BothRanges(IntRange volRange, IntRange noteRange) {
    this.volRange = volRange;
    this.noteRange = noteRange;
  }

  boolean finished() {
    return _finished;
  }

  void advance() {
    if (volRange.finished() && noteRange.finished()) {
      _finished = true;
    } else {
      if (volRange.finished()) {
        volRange.reset();
        noteRange.advance();
      } else {
        volRange.advance();
        if (volRange._current>127) { volRange._current = 127; }
      }
    }
  }

  int getVol() { 
    return volRange.current();
  }
  int getNote() { 
    return noteRange.current();
  }
  int getStep() {  
    return noteRange.step;
  }
}




IntRange volRange(int lo, int hi, int step) {
  return new IntRange(lo, hi, step);
}

IntRange noteRangeOctsStartStep(int noOcts, int start, int step) {
  return new IntRange(start, start+noOcts*12, step);
}
