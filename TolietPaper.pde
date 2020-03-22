import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

//0 - play
int gamestate = -1;


//sprites
PImage gun;
PImage van;
PImage road;
PImage bullet;
PImage player;
PImage enemy;
PImage aura;
PImage car;

PImage title;
PImage titletext;
//shader
PShader shader;
PImage pallette;
PImage noise;

PGraphics mainCanvas;

void settings(){
  size(displayWidth,displayHeight-50,P2D);
}
void setup(){
  
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0,0);
  box2d.listenForCollisions();
  frame.setResizable(true);

  t = new Truck(100,100,radians(30));
  gameobjects.add(t);
  
  title = loadImage("title.png");
  titletext = loadImage("titletext.png");
  gun = loadImage("gunsheet.png");
  van= loadImage("truck.png");
  road = loadImage("path.png");
  bullet= loadImage("bullet.png");
  player= loadImage("player.png");
  enemy= loadImage("enemy.png");
  noise = loadImage("NoiseTex.png");
  pallette = loadImage("pal.png");
  aura = loadImage("aura.png");
  car = loadImage("car.png");
  
  mainCanvas = createGraphics(displayWidth,displayHeight,P2D);
  ((PGraphicsOpenGL)this.g).textureSampling(2);
  testpath = new Path();
  testpath.path.add(new PathSegment(new Vec2(),new Vec2(width*4,300)));
  testpath.path.add(new PathSegment(new Vec2(width*4,300),new Vec2(width*8,0)));
  float tpx = width*8; float tpy = 0;
  for(int i = 0;i<100;i++){
    
    ang+=random(-1,1);
    ang = constrain(ang,-PI,PI);
    float dis = random(800,3000);
    float dx = cos(ang)*dis;
    float dy = sin(ang)*dis;
    testpath.path.add(new PathSegment(new Vec2(tpx,tpy),new Vec2(tpx+dx,tpy+dy)));
    tpx+=dx;
    tpy+=dy;
  }
  
  for(int i =0;i<5;i++){
    paths.add(new PathTile(i,testpath));
  }
  
  shader = loadShader("shader.glsl");
  shader.init();
}


float ang=0;
ArrayList<PathTile> paths = new ArrayList();
//game objects
ArrayList<GameObject> gameobjects = new ArrayList();
Truck t;
Path testpath;

void spawnAtPathPoint(int type, int node, float spread){
  if(node<0||node>testpath.path.size()-1){
    return;
  }
  PhysicsGameObject pg;
  PathSegment ps = testpath.path.get(node);
  switch(type){
    case 1:
      pg = new Bike(ps.start.x+random(-spread,spread),ps.start.y+random(-spread,spread),radians(random(180)));
      break;
    case 2:
      pg = new Car(ps.start.x+random(-spread,spread),ps.start.y+random(-spread,spread),radians(random(180)));
      break;  
    default:
      pg = new PersonOnFoot(ps.start.x+random(-spread,spread),ps.start.y+random(-spread,spread),radians(random(180)));
  }
  pg.pathseg = node;
  pg.mode=1;
  
  gameobjects.add(pg);
}


float cmx,cmy;

float gmx,gmy;
float scale = 1;


float animatetick =0;
//title
float titletextscale = 1.5;

void draw(){
  animatetick++;
  switch(gamestate){
    case -1:
      background(42);
      image(title,width/2 - title.width/2,height/2 - title.height/2);
      pushMatrix();
      translate(width/2,height/2);
      rotate(sin(animatetick*0.01)*0.03);
      scale(titletextscale);
      titletextscale+=(0.5-titletextscale)*0.1;
      image(titletext,- titletext.width/2, - titletext.height/2);
      popMatrix();
      if(mousePressed){
        gamestate = 0;
      }
    break;
    case 0:
      for(int i = 0;i<gameobjects.size();i++){
        GameObject g = gameobjects.get(i);
        g.update();
        if(g.hp<=0){
          g.destroy();
          gameobjects.remove(i);
          i--;
        }
      }
      box2d.step();
     
      
      cmx += ((width/2*scale)-t.position.x-cmx)*0.1;
      cmy += ((height/2*scale)-t.position.y-cmy)*0.1;
      gmx = mouseX*scale-cmx;
      gmy = mouseY*scale-cmy;
      mainCanvas.beginDraw();
      mainCanvas.background(20);
      mainCanvas.pushMatrix();
      mainCanvas.scale(1f/scale);
      mainCanvas.translate(cmx,cmy);
      
      mainCanvas.ellipse(gmx,gmy,5,5);
      
      int highestpathnode= 0;
      for(int i = 0;i<paths.size();i++){
        PathTile g = paths.get(i);
        g.draw(0,mainCanvas);
        highestpathnode = max(highestpathnode,g.node);
        if(g.node<=t.totalpathTravelled-3){
          paths.remove(i);
          i--;
        }
      }
      if(highestpathnode<t.totalpathTravelled+3){
        paths.add(new PathTile(highestpathnode+1,testpath));
      }
      
      mainCanvas.fill(255);
      for(GameObject g:gameobjects){
        if(g instanceof CarClimber){
        
          continue;
        }
        g.draw(mainCanvas);
      }
      
      //debug
      
      mainCanvas.popMatrix();
      
      
      
      //spawning goes here
      if(random(100)<1){
        int thing = constrain((int)random(t.totalpathTravelled*0.23),0,2);
        float severity = t.totalpathTravelled/60f;
        for(int i=0;i<constrain(severity*10f/(thing+1f),1,10);i++){
          spawnAtPathPoint(thing,(int)(t.totalpathTravelled+0.8)+(random(2)>1?1:-3),100);
        }
      }
      //progress bar
      mainCanvas.fill(0,255,0);
      mainCanvas.rect(0,0,width*t.totalpathTravelled/70f,20);
      
      mainCanvas.endDraw();
      shader.set("noisetex",noise);
      shader.set("pal",pallette);
      shader.set("offset",-cmx/256,cmy/256);
      shader.set("steps",pallette.width);
      shader(shader);
      image(mainCanvas,0,0);
    break;
  }
  

}
