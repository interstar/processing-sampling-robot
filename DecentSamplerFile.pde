import java.util.HashMap;
import java.util.Map;
import java.util.Collections;

class Attributes {
  Map<String,String> dict;
  
  Attributes(String... vals) {
    dict = new HashMap<String,String>();
    for (int i=0;i<vals.length;i=i+2) {
      dict.put(vals[i],vals[i+1]);
    }
  }
    
  String toString() {
    String s=" ";
    for (String key : dict.keySet()) {
        s = s + key + "=\"" + dict.get(key) +"\" ";
    }
    return s;
  }
  
  Attributes mergeWith(Attributes a2) {
     for (String key : a2.dict.keySet()) {
       dict.put(key,a2.dict.get(key));
     }
     return this;
  }
  
  Attributes put(String key, String val) {
    dict.put(key,val);
    return this;
  }
}



class Wrappable {
  String value;
  
  public Wrappable(String s) {
    value = s;
  }
   
  Wrappable wrap(String tag) {
    return wrap(tag,new Attributes());
  }
 
  
  Wrappable wrap(String tag, Attributes attributes ) {
    value = "<"+tag+" "+attributes.toString()+">" + value + "</"+tag+">";
    return this;
  }
 
 
  Wrappable L() {
    value = "\n"+value+"\n";
    return this;
  }
  
  String toString() { return value; }
}


enum FX {
  lowpass_4pl,
  reverb,
  delay,
  chorus,
  phasor
}

class ParamKnob  {
  String label;
  FX fx;
  int x, y;
  float min,max,value;
  String parameter;
  
  Attributes knobAttributes = 
    new Attributes("width","70","textSize","24","textColor","FFFFFFFF",
                   "trackForegroundColor","ccffffff", "trackBackgroundColor","66999999",
                   "type","float");
                   
  Attributes bindingAttributes = 
    new Attributes("type","effect","level","instrument");

  ParamKnob(String label, int x, int y, 
      float min, float max, float value,  String parameter) {
    this.label = label;
    this.x = x;
    this.y = y;
    this.min = min;
    this.max = max;
    this.value = value;
    this.parameter = parameter;
    knobAttributes.put("label",label);
    knobAttributes.put("x",""+x);
    knobAttributes.put("y",""+y);
    knobAttributes.put("minValue",""+min);
    knobAttributes.put("maxValue",""+max);
    knobAttributes.put("value",""+value);
    bindingAttributes.put("parameter",parameter); 
  }
  
  String knobTag(int position) {
    bindingAttributes.put("position",""+position);
    Wrappable bind = new Wrappable("").wrap("binding",bindingAttributes);
    return bind.wrap("labeled-knob",knobAttributes).toString();    
  }
}

class Effect {
   Attributes attributes;
   Map<String,ParamKnob> knobs;
   
   Effect(String... atts) {
     attributes = new Attributes(atts);
     knobs = new HashMap<String,ParamKnob>();
   }
   
   Effect add(String k, ParamKnob pk) {
     knobs.put(k,pk);
     return this;
   }
   
   String effectTag() {
     return new Wrappable("").wrap("effect",attributes).toString();
   }
   
   String knobBlock(int position) {
     String s = "";
     for (String key : knobs.keySet()) {
       ParamKnob pk = knobs.get(key);
       s = s + "\n" + pk.knobTag(position);      
     }
     return s+"\n";
   }
}

class AllEffects {
   Map<Integer,Effect> effects = new HashMap<Integer,Effect>();
   int count = 0;
   
   void add(Effect e) {
     effects.put(new Integer(count),e);
     count++;
   }
  
   String effectsBlock() {
     String s = "";
     ArrayList<Integer> sortedKeys = new ArrayList(effects.keySet());
     Collections.sort(sortedKeys);
     for (Integer key : sortedKeys) {
       Effect fx = effects.get(key);
       s = s + "\n" + fx.effectTag();      
     }
     return new Wrappable(s+"\n").wrap("effects").toString();
   }
  
   String allKnobs() {
     String s = "";
     ArrayList<Integer> sortedKeys = new ArrayList(effects.keySet());
     Collections.sort(sortedKeys);
     int count = 0;
     for (Integer key : sortedKeys) {
       Effect fx = effects.get(key);
       s = s + "\n" + fx.knobBlock(count); 
       count++;
     }
     return new Wrappable(s+"\n").wrap("tab").toString();

   }
}

class DecentBuilder {
  
  String samples;
  String fileName;
  AllEffects allEffects;
  
  DecentBuilder(String nameRoot) {
    samples = "";
    fileName = nameRoot+".dspreset";
    allEffects = makeEffects();
  }
 
  void addSampleLine(int note, int step, String fileName) {
     samples = samples + "\n<sample rootNote=\"" + note + "\" path=\"" + fileName + 
       "\" 
       "\" loNote=\"" + (note-step) + "\" hiNote=\""+(note-1) +"\" />";
  }

  AllEffects makeEffects() {
     AllEffects allEffects = new AllEffects(); 
     int x = 35;
     int y = 75;
     int offset=90;
     // Filter
     Effect lpf = new Effect("type","lowpass_4pl", "resonance","0.7", "frequency", "22000");
     lpf.add("FX_FILTER_FREQUENCY",
             new ParamKnob("Cutoff",x,y, 60, 22000, 22000,"FX_FILTER_FREQUENCY" ));
     x+=offset;
     lpf.add("FX_FILTER_RESONANCE",
             new ParamKnob("Resonance",x,y, 0.0,2.0,0.0,"FX_FILTER_RESONANCE"));                         
     allEffects.add(lpf);
     
     // Reverb
     Effect reverb = new Effect("type","reverb", "roomSize","0.7", "damping","0.3", "wetLevel","0.5");
     x+=offset;
     reverb.add("FX_REVERB_WET_LEVEL",
                new ParamKnob("Reverb",x,y, 0,1,0.5, "FX_REVERB_WET_LEVEL"));                
     allEffects.add(reverb);
    
     // Delay
     Effect delay = new Effect("type","delay", "delayTime","0.5", 
                               "stereoOffset","0.01", "feedback","0.2", "wetLevel","0.5");
     x+=offset;
     delay.add("FX_DELAY_TIME",
               new ParamKnob("Delay Time",x,y, 0,1,0, "FX_DELAY_TIME"));
     x+=offset;
     delay.add("FX_WET_LEVEL",
               new ParamKnob("Delay Amt",x,y,0,1,0,"FX_WET_LEVEL"));
     allEffects.add(delay);

     // Chorus
     Effect chorus = new Effect("type","chorus", "mix","0.5", "modDepth","0.2", "modRate","0.2");
     x+=offset;
     chorus.add("FX_MOD_DEPTH",
                new ParamKnob("Chorus Depth", x, y, 0,1,0, "FX_MOD_DEPTH"));
     x+=offset;
     chorus.add("FX_MOD_RATE",
                new ParamKnob("Chorus Rate", x, y, 0,10,0, "FX_MODE_RATE"));
     x+=offset;
     chorus.add("FX_MIX",
                new ParamKnob("Chorus Mix", x, y, 0,1,0, "FX_MIX"));
     allEffects.add(chorus);
     
     //   ParamKnob(String label, int x, int y, 
//     float min, float max, float value,  String parameter) {

     return allEffects;
  }
      
  String toString() {
     String ui = new Wrappable(allEffects.allKnobs()).wrap("ui",
       new Attributes("bgImage","background.png","width","812","height","375",
                      "layoutMode","relative","bgMode","top_left")).L().toString();

     String groups = new Wrappable(samples).L().wrap("group").L().wrap("groups").L().toString();
     String s = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + 
     new Wrappable(ui + allEffects.effectsBlock() + groups).wrap("DecentSampler", new Attributes("pluginVersion","1") ).L(); 
     return s;
  }
  
  void write() {
    String[] xs = new String[]{this.toString()};
    saveStrings(fileName,xs);
  }
  
}
