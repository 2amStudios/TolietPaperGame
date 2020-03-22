abstract class Particle{
  PImage texture;
  float x,y;
  float vx,vy;
  float life = 1;
  
  abstract void update();
  abstract void draw(PGraphics pg);

}

class StaticParticle extends Particle{
   StaticParticle(PImage texture, float x,float y){
      this.texture = texture;
      this.x=x;
      this.y=y;
   }
   void update(){
     
     if(distsqrd(x,y,t.position.x,t.position.y)>sqrd(2000)){
       life = 0;
     }
   }
   
   void draw(PGraphics pg){
     //println("hewwo?");
     pg.image(texture,x-texture.width*0.5,y-texture.height*0.5);
   }
}

class StaticAnimatedParticle extends Particle{
  int frame=0, maxframe;
  boolean loops;
  int w,h;
   StaticAnimatedParticle(PImage texture, float x,float y,boolean loops, int frames){
      this.texture = texture;
      this.x=x;
      this.y=y;
      maxframe = frames;
      this.loops=loops;
      this.w = texture.width/frames;
      this.h=  texture.height;
      
   }
   void update(){
     
     if(distsqrd(x,y,t.position.x,t.position.y)>sqrd(2000)){
       life = 0;
     }
     frame++;
     if(frame==maxframe){
       frame = 0;
       if(!loops){
         life= 0;
       }
     }
     
   }
   
   void draw(PGraphics pg){
     //println("hewwo?");
     drawSprite(pg,texture, frame*w,0,w,h,     x-w*0.5,y-h*0.5,w,h);
   }
}
