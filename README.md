# processing-sampling-robot

Automate making a sampled instrument for Decent Sampler in Processing.

This sketch controls an external synth or keyboard via MIDI to make it play a series of notes, and then records each note into a separate .wav file, suitable for loading into a sampling instrument in Decent Sampler or equivalent.

It also creates a Decent Sampler .dspreset file.

See more on Decent Sampler at https://www.decentsamples.com/product/decent-sampler-plugin/

See this video for original overview / explanation : https://www.youtube.com/watch?v=h81GG_9Qmto

And this video for the June 1st, update : https://www.youtube.com/watch?v=P-pL3Y9ZX-Q

### Update June 1st 2022

The sampling robot now also makes a cover, add some standard effects and can sample at a range of velocities.

To use, set up your external synth connected by both audio and MIDI

```
// This chooses one of the IGraphic classes to make a cover for your instrument.
// Processing is a great random / algorithmic graphics environment, and you can easily
// make your own covers simply by creating your own instance of an IGraphic object
// The argument here is the title which will be added to the instrument
IGraphic graphic = new RandomRects("My Instrument"); 

// This defines the particular robot / parameters you want
// myInstrument is the root for the file names,
// graphic is the IGraphic class to draw the cover
// noteRangeOcsStartStep specifies the note range.
// noteRangeOctsStartStep(numerOfOctaves, startNote, step between each sampled note (in semitones)
// volRange(minVolume, maxVolume, volumeStep)
// last args are 
// time to hold note down (eg. here it's 300 milliseconds)
// length of each sample (here 4000 milliseconds)
SampleRobot robbie = new SampleRobot("myinstrument",graphic,noteRangeOctsStartStep(1,36,6),
                                     volRange(0,127,80),300,4000);
```
