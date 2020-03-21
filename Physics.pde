
Box2DProcessing box2d;


void beginContact(Contact cp) {
  // Get both fixtures
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  // Get both bodies
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  // Get our objects that reference these bodies
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  if (o1 instanceof PhysicsGameObject&&o2 instanceof PhysicsGameObject) {
    PhysicsGameObject p1 = (PhysicsGameObject)o1;
    PhysicsGameObject p2 = (PhysicsGameObject)o2;
    CollisionEvent c = new CollisionEvent(p1, p2, box2d.vectorWorldToPixels(b1.getLinearVelocity()), box2d.vectorWorldToPixels(b2.getLinearVelocity()));
    p1.collisions.add(c);
    p2.collisions.add(c);
  }
}

// Objects stop touching each other
void endContact(Contact cp) {
}

class CollisionEvent {
  PhysicsGameObject o1;
  PhysicsGameObject o2;
  Vec2 pvel1;
  Vec2 pvel2;

  CollisionEvent(PhysicsGameObject o1, PhysicsGameObject o2, Vec2 pvel1, Vec2 pvel2) {
    this.o1=o1;
    this.o2=o2;
    this.pvel1=pvel1;
    this.pvel2=pvel2;
  }
}


abstract class GameObject {
  PVector position;
  float hp=1;
  int faction;

  boolean isIn(Vec2 pos) {
    return false;
  }

  float lastdamage = 0;
  void damage(float damage) {
    lastdamage = 0;
    hp-=damage;
  }
  abstract void destroy();
  abstract void update();
  abstract void draw(PGraphics pg);
}
class CarClimber extends GameObject {
  PhysicsGameObject current;
  
  PhysicsGameObject target=null;
  
  float jumpcooldown = 0;
  float jumpani = 0; 

  CarClimber(PhysicsGameObject attached) {
    this.current = attached;
    position = new PVector();
    hp=4;
  }
  //for now well make sure everyone makes it
  void jump(PhysicsGameObject newobject) {
    if (newobject.addClimber(this)) {
      current.climbers.remove(this);
      current = newobject;
      jumpcooldown=0;
      target = null;
    }
  }
  
  void preparejump(PhysicsGameObject newobject) {
    if (jumpcooldown>40) {
      target = newobject;
    }
  }
  
  PVector getAbsolutePos(){
     return position.copy().rotate(-current.angle).add(current.position);
  }
  Vec2 jumptarget;
  void update() {
    lastdamage++;
    jumpcooldown++;
    if(target!=null){
      PVector abspos =  getAbsolutePos();
      Vec2 jumptargetrel = target.constrainPoint(target.transform(abspos));
      jumptarget = current.transform(target.getAbsolutePos(new PVector(jumptargetrel.x,jumptargetrel.y)));
      float dist = dist(jumptarget.x,jumptarget.y,position.x,position.y);
      if(dist<10){
        jump(target);
      }else if(dist>300){
        target = null;
      }
      Vec2 moveto = current.constrainPoint(jumptarget);
      position.x += constrain((moveto.x-position.x)*0.1,-2,2);
      position.y += constrain((moveto.y-position.y)*0.1,-2,2);
    }
    
    if (current==null) {
      hp=0;
    }
    
  }
  boolean isIn(Vec2 pos) {
    if (current!=null) {
      Vec2 apos = current.transform(pos);
      return dist(apos.x, apos.y, position.x, position.y)<20;
    }
    return false;
  }
  void draw(PGraphics pg) {
    pg.fill(200+lastdamage);
    pg.stroke(0);
    pg.ellipse(position.x, position.y, 30, 30);
    if(target!=null&&jumptarget!=null){
      pg.fill(255,0,0);
      pg.ellipse(jumptarget.x, jumptarget.y, 20, 20);
    }
    pg.fill(255);
  }
  void destroy() {
    if (current!=null) {
      current.climbers.remove(this);
    }
  }
}
class Bullet extends GameObject {
  float vx, vy;
  float vangle;

  float drag = 1;

  Bullet(float x, float y, float ang) {
    position = new PVector(x, y);
    vx = sin(ang);
    vy=cos(ang);
  }
  Bullet(float x, float y, float vx, float vy) {
    position = new PVector(x, y);
    this.vx = vx;
    this.vy= vy;
  }
  void update() {
    position.x+=vx;
    position.y+=vy;
    vangle =  atan2(vy, vx);
    vx*=drag;
    vy*=drag;
    hp-=0.01;
    Vec2 pos = new Vec2(position.x, position.y);
    for (GameObject g : gameobjects) {
      if (g.isIn(pos)) {
        hp=0;
        g.damage(1);
        if (g instanceof Car) {
          ((Car)g).speed *=0.9;
        }
      }
    }
    
  }

  void draw(PGraphics pg) {
    pg.pushMatrix();
    pg.translate(position.x, position.y);
    pg.rotate(vangle+PI/2);
    pg.rect(-6, -8, 12, 16);
    pg.popMatrix();
  }
  void destroy() {
  }
}

abstract class PhysicsGameObject extends GameObject {
  Body body;
  PVector position;
  float angle;
  int climbcapacity = 0;
  ArrayList<CarClimber> climbers = new ArrayList();
  void spawnClimber() {
    if (climbers.size()<climbcapacity) {
      CarClimber c = new CarClimber(this);
      c.position.x= random(-10, 10);
      c.position.y= random(-10, 10);
      climbers.add(c);
      gameobjects.add(c);
    }
  }
  Vec2 constrainPoint(Vec2 rp){
    return rp;
  
  }
  PVector getAbsolutePos(PVector position){
     return position.copy().rotate(-angle).add(this.position);
  }
  
  boolean addClimber(CarClimber c) {
    if (climbers.size()<climbcapacity) {
      Vec2 p = constrainPoint(transform(c.getAbsolutePos()));
      c.position.x= p.x;
      c.position.y= p.y;
      climbers.add(c);
      return true;
    }
    return false;
  }

  ArrayList<CollisionEvent> collisions = new ArrayList();
  void destroy() {
    killBody();
  }
  void killBody() {
    box2d.destroyBody(body);
  }
  abstract void update();
  abstract void draw(PGraphics pg);
  abstract void makeBody();

  void updatePos() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    position.x = pos.x;
    position.y= pos.y;
    // Get its angle of rotation
    angle = (body.getAngle()%(2*PI)+(2*PI))%(2*PI);
    lastdamage++;
  }

  Vec2 transform(Vec2 pos) {
    Vec2 oh = pos.sub(new Vec2(position.x, position.y));
    PVector p = new PVector(oh.x, oh.y);
    p.rotate(angle);
    return new Vec2(p.x, p.y);
  }


  Vec2 transform(PVector pos) {
    PVector p = PVector.sub(pos,position);
    p.rotate(angle);
    return new Vec2(p.x, p.y);
  }


  void makeRectBody(Vec2 center, float w_, float h_, float density, float friction, float res) {
    // Define a polygon (this is what we use for a rectangle)
    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w_/2);
    float box2dH = box2d.scalarPixelsToWorld(h_/2);
    sd.setAsBox(box2dW, box2dH);

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = density;
    fd.friction = friction;
    fd.restitution = res;



    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.angularDamping = 10.0;
    bd.linearDamping = 0.2;
    bd.position.set(box2d.coordPixelsToWorld(center));

    body = box2d.createBody(bd);
    body.createFixture(fd);
  }


  void applyForce(Vec2 force, PVector rpos) {
    //rpos.rotate(-angle);
    body.applyForce(force, body.getWorldPoint(box2d.vectorPixelsToWorld(rpos)));
  }

  Vec2 getForwardDir() {
    //rpos.rotate(-angle);
    return new Vec2(sin(angle), cos(angle));
  }


  void applyVehicleDrag(float mul) {
    Vec2 fp = getForwardDir();
    Vec2 fpp = new Vec2(fp.y, fp.x);
    float velt = Vec2.dot(body.getLinearVelocity(), fpp);
    body.applyForce(fpp.mul(-velt*body.getMass()*mul), body.getWorldCenter());
  }
  void pushForwards(float force) {
    applyForce(box2d.vectorPixelsToWorld(getForwardDir().mul(force*body.getMass())), new PVector(0, 0));
  }

  void rotateTowards(float x, float y, float force) {
    Vec2 dir = new Vec2(x-position.x, -(y-position.y));
    float ang  =targetAng(angle, (atan2(dir.y, dir.x) +PI/2+ (2*PI))%(2*PI));
    body.applyAngularImpulse((ang-angle)*force*body.getMass());
  }
  void rotateTowards(float tang, float force) {

    float ang  =targetAng(angle, (tang+ (2*PI))%(2*PI));
    body.applyAngularImpulse((ang-angle)*force*body.getMass());
  }
  void rotateTowardsDirection(float x, float y, float force) {
    Vec2 dir = new Vec2(x, -(y));
    float ang  =targetAng(angle, (atan2(dir.y, dir.x) +PI/2+ (2*PI))%(2*PI));
    body.applyAngularImpulse((ang-angle)*force*body.getMass());
  }

  float distanceToTruck() {
    return dist(position.x, position.y, t.position.x, t.position.y);
  }

  //testing
  int pathseg = 0;
  //finding start 0,  pathing -1 
  int mode=0;
  float palongness=1;

  float totalpathTravelled=0;

  void followPath(Path p, float speedfactor) {
    float calongness = p.path.get(pathseg).alongness(new Vec2(position.x, position.y));
    totalpathTravelled = pathseg+constrain(calongness, 0, 1);
    Vec2 posvec = new Vec2(position.x, position.y);
    PathSegment ps = p.path.get(pathseg);
    float vel = (body.getLinearVelocity()).length()*0.1;
    switch(mode) {
    case 0:
      Vec2 startpos = ps.start;
      rotateTowards(startpos.x, startpos.y, constrain(vel, 0, 3.5));
      if (sign(calongness)!=sign(palongness) || distsqrd(startpos.x, startpos.y, position.x, position.y)<180*180) {
        mode = 1;
      }
      pushForwards(40*speedfactor);
      break;
    case 1:

      rotateTowards(ps.angle, constrain(vel, 0, 3.5));
      if (ps.distance(posvec)>10 && atan2(sin(ps.angle-angle), cos(ps.angle-angle))<PI/2) {
        rotateTowards(ps.angle+radians(constrain((ps.whichside(posvec)-1.5)*ps.distance(posvec)*0.4, -65, 65)), constrain(vel, 0, 3.5));
      }
      if (calongness>1) {
        pathseg++;
        pathseg = pathseg%testpath.path.size();

        PathSegment ps2 = p.path.get(pathseg);
        if (ps2.alongness(posvec)>0) {
          mode=1;
        } else {
          mode=0;
        }
      }
      pushForwards(100*speedfactor);
      break;
    }
    palongness = calongness;
  }
}

class PathSegment {
  Vec2 start, finish;
  float angle;
  PathSegment(Vec2 start, Vec2 finish) {
    this.start=start;
    this.finish = finish;
    Vec2 diff = finish.sub(start);
    angle = ((atan2(-diff.y, diff.x)+PI/2+ (2*PI))%(2*PI));
  }

  float alongness(Vec2 pos) {
    return Vec2.dot(finish.sub(start), pos.sub(start))/(sqrd(start.x-finish.x)+sqrd(start.y-finish.y));
  }
  float distance(Vec2 pos) {
    return finish.sub(start).mul(alongness(pos)).sub(pos.sub(start)).length();
  }
  int whichside(Vec2 pos) {
    return orientation(pos.x, pos.y, start.x, start.y, finish.x, finish.y);
  }
}

class Path {
  ArrayList<PathSegment> path = new ArrayList();
}

class Truck extends PhysicsGameObject {

  Truck(float x, float y, float ang) {
    position = new PVector(x, y);
    angle = ang;
    makeBody();
    hp = 400;
    faction =1;
    body.setUserData(this);
    climbcapacity = 8;
  }

  int firetick = 0;
  float speedpenalty = 0;
  void update() {
    updatePos();

    if (mousePressed) {
      Vec2 dir = new Vec2(gmx-position.x, (gmy-position.y));
      dir.normalize();

      if (firetick>5) {
        firetick=0;
        Vec2 vel = box2d.vectorWorldToPixels(body.getLinearVelocity());
        gameobjects.add(new Bullet(position.x+dir.x*20, position.y+dir.y*20, dir.x*9+vel.x/60f, dir.y*9+vel.y/60f));
      }
      
      //dir  = dir.mul(100);
      //applyForce(box2d.vectorPixelsToWorld(getForwardDir().mul(100*body.getMass())),new PVector(0,0));

      //float ang  =targetAng(angle,(atan2(dir.y,dir.x) +PI/2+ (2*PI))%(2*PI));
      //body.applyAngularImpulse(sign(ang-angle)*8000);
      //rotateTowards(gmx,gmy,18);
      //println(degrees(ang),degrees(angle),degrees(atan2(dir.y,dir.x)));
      //body.getLinearVelocity()
      //body.applyForce(dir,body.getWorldCenter().add(box2d.coordPixelsToWorld(new Vec2(50,0))));
    }
    firetick++;
    followPath(testpath, max(0, 1.0-speedpenalty));
    applyVehicleDrag(1.0);
    speedpenalty*=0.8;
  }
  void draw(PGraphics pg) {
    Vec2 dd = getForwardDir();
    pg.pushMatrix();
    pg.translate(position.x, position.y);
    Vec2 dir = new Vec2(gmx-position.x, (gmy-position.y));
    
    
    pg.stroke(0);
    pg.pushMatrix();
    pg.line(0, 0, dd.x*1000, dd.y*1000);
    pg.rotate(-angle);
    pg.rect(-60, -120, 120, 240);
    pg.fill(0);
    pg.text("MODE:"+mode, 0, 0);
    pg.fill(255);
    for (CarClimber c : climbers) {
      c.draw(pg);
    }
    
    pg.popMatrix();
    pg.rotate(atan2(dir.y, dir.x)+PI/2);
    drawSprite(pg,gun,constrain(firetick,0,4)*(gun.width/5),0,(gun.width/5),gun.height,-40, -30, 80, 60);
    
    pg.popMatrix();
    for (CarClimber c : climbers) {
      PVector p = c.getAbsolutePos();
      pg.fill(255,0,0);
      pg.ellipse(p.x,p.y,10,10);
      pg.fill(255);
    }
    
  }
  @Override
  Vec2 constrainPoint(Vec2 rp){
    return new Vec2(constrain(rp.x,-60,60),constrain(rp.y,-120,120));
  
  }
  
  void makeBody() {
    makeRectBody(new Vec2(position.x, position.y), 120, 240, 10, 0.1, 0.1);
    body.setTransform(box2d.coordPixelsToWorld(new Vec2(position.x, position.y)), angle);
  }
}


class Car extends PhysicsGameObject {
  float len;
  float speed =1.0;
  Car(float x, float y, float ang) {
    position = new PVector(x, y);
    angle = ang;
    makeBody();
    hp = 70;
    body.setUserData(this);

    climbcapacity = 4;
    for (int i = 0; i<random(4); i++) {
      spawnClimber();
    }
  } 

  void update() {
    updatePos();
    float dtt = distanceToTruck();
    if (!collisions.isEmpty()) {
      Vec2 vel = box2d.vectorWorldToPixels(body.getLinearVelocity());
      for (CollisionEvent c : collisions) {
        float sh=0;
        PhysicsGameObject other = null;
        if (c.o1==this) {
          sh  = c.pvel1.sub(vel).length()/60f;
          other=c.o2;
        } else {
          sh  = c.pvel2.sub(vel).length()/60f;
          other=c.o1;
        }
        if (sh>1) {
          damage(sh*5);
        }

        if (other.distanceToTruck()<dtt) {
          for (int i =0; i<climbers.size(); i++) {
            if (random(2)<1) {
              climbers.get(i).preparejump(other);
            }
          }
        }
      }
    }
    collisions.clear();

    followPath(testpath, constrain(t.totalpathTravelled>totalpathTravelled?1.5:0.5, 0, 1.5*speed));
    applyVehicleDrag(1.0);
  }
  void draw(PGraphics pg) {
    //Vec2 dd = getForwardDir();
    pg.pushMatrix();
    pg.translate(position.x, position.y);
    //line(0,0,dd.x*1000,dd.y*1000);
    pg.rotate(-angle);
    pg.fill(200+lastdamage);
    pg.rect(-45, -len/2, 90, len);
    pg.fill(255);
    for (CarClimber c : climbers) {
      c.draw(pg);
    }

    pg.popMatrix();
  }
  @Override
    boolean isIn(Vec2 pos) {
    Vec2 tr = transform(pos);
    return tr.x>-45&&tr.y>-len/2&&tr.x<45&&tr.y<len/2;
  }
  @Override
  Vec2 constrainPoint(Vec2 rp){
    return new Vec2(constrain(rp.x,-45,45),constrain(rp.y,-len/2,len/2));
  
  } 

  void makeBody() {
    len = 120+random(50);
    makeRectBody(new Vec2(position.x, position.y), 90, len, 3, 0.1, 0.1);
    body.setTransform(box2d.coordPixelsToWorld(new Vec2(position.x, position.y)), angle);
  }
}


class Bike extends PhysicsGameObject {
  float len;
  Bike(float x, float y, float ang) {
    position = new PVector(x, y);
    angle = ang;
    makeBody();
    hp = 10;
    body.setUserData(this);
  } 

  void update() {
    updatePos();

    if (!collisions.isEmpty()) {
      Vec2 vel = box2d.vectorWorldToPixels(body.getLinearVelocity());
      for (CollisionEvent c : collisions) {
        float sh=0;
        PhysicsGameObject other = null;
        if (c.o1==this) {
          sh  = c.pvel1.sub(vel).length()/60f;
          other=c.o2;
        } else {
          sh  = c.pvel2.sub(vel).length()/60f;
          other=c.o1;
        }
        if (sh>hp*0.1+0.5) {
          damage(sh*2);
        }
        if (other.climbers.size()<other.climbcapacity&&hp<=0&&random(1)<0.4) {
          other.spawnClimber();
        }
      }
    }
    collisions.clear();
    followPath(testpath, t.totalpathTravelled>totalpathTravelled?1.5:0.5);
    applyVehicleDrag(1.0);

    if (t.totalpathTravelled-totalpathTravelled>7) {
      hp=0;
    }
  }
  void draw(PGraphics pg) {
    //Vec2 dd = getForwardDir();
    //Vec2 tt  = transform(new Vec2(50,50));
    pg.pushMatrix();
    pg.translate(position.x, position.y);
    //line(0,0,dd.x*1000,dd.y*1000);
    pg.rotate(-angle);
    pg.fill(200+lastdamage);
    pg.rect(-5, -len/2, 10, len);
    pg.fill(255);
    pg.popMatrix();
  }

  @Override
    boolean isIn(Vec2 pos) {
    Vec2 tr = transform(pos);
    return tr.x>-5&&tr.y>-len/2&&tr.x<5&&tr.y<len/2;
  }
  void makeBody() {
    len = 70+random(5);
    makeRectBody(new Vec2(position.x, position.y), 10, len, 3, 0.1, 0.1);
    body.setTransform(box2d.coordPixelsToWorld(new Vec2(position.x, position.y)), angle);
  }
}

class PersonOnFoot extends PhysicsGameObject {
  float len;
  PersonOnFoot(float x, float y, float ang) {
    position = new PVector(x, y);
    angle = ang;
    makeBody();
    hp = 2;
    body.setUserData(this);
  } 

  void update() {
    updatePos();

    if (!collisions.isEmpty()) {
      Vec2 vel = box2d.vectorWorldToPixels(body.getLinearVelocity());
      for (CollisionEvent c : collisions) {
        float sh=0;
        PhysicsGameObject other = null;
        if (c.o1==this) {
          sh  = c.pvel1.sub(vel).length()/60f;
          other=c.o2;
        } else {
          sh  = c.pvel2.sub(vel).length()/60f;
          other=c.o1;
        }
        if (sh>hp*0.1+0.5) {
          damage(sh);
          if (c.o1==t||c.o2==t) {
            t.speedpenalty+=0.5/(1+t.speedpenalty*5.0);
          }
        }
        if (other.climbers.size()<other.climbcapacity&&hp<=0&&random(1)<0.7) {
          other.spawnClimber();
        }
      }
    }
    collisions.clear();
    followPath(testpath, t.totalpathTravelled>totalpathTravelled?1.5:0.5);
    applyVehicleDrag(2.0);

    if (t.totalpathTravelled-totalpathTravelled>7) {
      hp=0;
    }
  }
  void draw(PGraphics pg) {
    //Vec2 dd = getForwardDir();
    //Vec2 tt  = transform(new Vec2(50,50));
    pg.pushMatrix();
    pg.translate(position.x, position.y);
    //line(0,0,dd.x*1000,dd.y*1000);
    pg.rotate(-angle);
    pg.fill(200+lastdamage);
    pg.rect(-20, -len/2, 40, len);
    pg.fill(255);
    pg.popMatrix();
  }

  @Override
    boolean isIn(Vec2 pos) {
    Vec2 tr = transform(pos);
    return tr.x>-20&&tr.y>-len/2&&tr.x<20&&tr.y<len/2;
  }
  void makeBody() {
    len = 30;
    makeRectBody(new Vec2(position.x, position.y), 40, len, 3, 0.1, 0.1);
    body.setTransform(box2d.coordPixelsToWorld(new Vec2(position.x, position.y)), angle);
  }
}
