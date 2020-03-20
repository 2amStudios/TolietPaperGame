  public float targetAng(float oAng,float tAng){
    if(abs(tAng-oAng)<=PI){
      return tAng;
    }
    if(tAng-oAng>PI){
      return tAng-2*PI;
    }
    
    if(tAng-oAng<-PI){
      return tAng+2*PI;
    }
    return tAng;
  }
    float sqrd(float x){
      return (x*x);
  }
  float distsqrd(float x,float y,float x2,float y2){
      return sqrd(x-x2)+sqrd(y-y2);
  }
    // To find orientation of ordered triplet (p, q, r).
// The function returns following values
// 0 --> p, q and r are colinear
// 1 --> Clockwise
// 2 --> Counterclockwise
    public int orientation(float px,float py, float qx,float qy, float rx,float ry)
    {
        
        float val = (qy - py) * (rx - qx) -
                  (qx - px) * (ry - qy);

        if (val == 0) return 0;  // colinear
        
        return (val > 0)? 1: 2; // clock or counterclock wise
    }
    
    public float sign(float t){
      if(t==0){return 0;}
      return t/abs(t);
    }
    
