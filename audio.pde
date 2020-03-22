import beads.*;


AudioContext ac;
PeakDetector od;
ArrayList<Sample> sounds = new ArrayList();

void initAudio(){
  ac = new AudioContext();
  ac.start();
  ac.runNonRealTime();
  
  //and begin
}

class Sample{
  Panner pan;
  Gain gain;
  SamplePlayer player;
  OnePoleFilter opf;
  Envelope speedControl;
   String s;
  
  Sample(String name ,boolean loops){
    File f = dataFile("audio\\"+name);
    println(name);
    //gain.;
     player = new SamplePlayer(ac, SampleManager.sample(f.getAbsolutePath()));
     //float dist = dist(x,y,cmx+width/2f,cmy+height/2f);
     gain = new Gain(ac, 2, 0.5);
     opf = new OnePoleFilter(ac, 10000);
    // println(1f/(1f+0.01*dist),2.0*(x/width-0.5));
     pan = new Panner(ac,0.0);
     
     opf.addInput(player);
     gain.addInput(opf);
     pan.addInput(gain);
     player.start();
     
     ac.out.addInput(pan);
     speedControl =  new Envelope(ac, 1);
     player.setRate(speedControl);
     if(loops){
       player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
     }else{
       player.setKillOnEnd(true);
     }
  }
  Sample(){
    
  }
  void onRemove(){
   // gain
    pan.kill();
    //gain.s
  }
}

class StereoSample extends Sample{
  
  StereoSample(String name ,boolean loops){
    super();
    this.s=name;
    File f = dataFile("audio\\"+name);
    println(name);
     beads.Sample sm = SampleManager.sample(f.getAbsolutePath());
    // println(sm.getNumChannels()+"edesseessese");
    //sm.
     player = new SamplePlayer(ac, sm);
     //float dist = dist(x,y,cmx+width/2f,cmy+height/2f);
     gain = new Gain(ac, 2, 0.5);
     opf = new OnePoleFilter(ac, 10000);
    // println(1f/(1f+0.01*dist),2.0*(x/width-0.5));
     ///pan.;
     
     
     //opf.addInput(player);
     gain.addInput(player);
     
     player.start();
     //pan.removeAllConnections(ac.out);
     ac.out.addInput(gain);
     speedControl =  new Envelope(ac, 1);
     player.setRate(speedControl);
     if(loops){
       player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
     }else{
       player.setKillOnEnd(true);
     }
  }
  void onRemove(){
   // gain
    opf.kill();
  }
}
class SpatialSample extends Sample{
  float x,y;
  float gaindist=1;
  float basegain=1;
  
  SpatialSample(String name, float x,float y,boolean loops){
    super(name,loops);
    File f = dataFile(name);
    this.x=x;
    this.y=y;
    update();
     //player.
  }
  
  boolean isEnd(){ 
    return player.isDeleted();
  }
  
  void update(){
    float dist = dist(x,y,-cmx+width/2f,-cmy+height/2f);
    gain.setGain(basegain/(gaindist+0.003*dist));
    opf.setFrequency(10f/(0.0005*(100+dist)));
    pan.setPos(2.0*(x/width-0.5));
  }
}
void updateAudio(){
  for(int i = 0;i<sounds.size();i++){
    Sample s = sounds.get(i);
    if(s.player.isDeleted()){
      sounds.get(i).onRemove();
      sounds.remove(i);
      i--;
    }
  }
  //println();
}

SpatialSample playSample(String name,float x,float y,boolean loop){
  //SamplePlaye
  SpatialSample ss = new SpatialSample(name,x,y,loop);
  sounds.add(ss);
  return ss;
}
Sample playSample(String name,boolean loop){
  //SamplePlaye
  Sample s = new Sample(name,loop);
  sounds.add(s);
  return s;
}
Sample playSample(String name,boolean loop,float gain){
  //SamplePlaye
  Sample s = new Sample(name,loop);
  s.gain.setGain(gain);
  sounds.add(s);
  return s;
}
Sample playSample(String name,boolean loop,float gain,float speedOffset){
  //SamplePlaye
  Sample s = new Sample(name,loop);
  s.gain.setGain(gain);
  sounds.add(s);
  s.speedControl.setValue(1+speedOffset);
  return s;
}
Sample playStereoSample(String name,boolean loop,float gain){
  //SamplePlaye
  Sample s = new  StereoSample(name,loop);
  s.gain.setGain(gain);
  sounds.add(s);
  return s;
}
