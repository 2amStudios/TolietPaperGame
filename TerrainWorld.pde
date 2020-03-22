class TerrainTile{
  PImage texture;
  float x,y;
  
  
}

class PathTile{
  PathSegment prev;
  PathSegment after;
  PathSegment c;
  int node;
  
  PathTile(int node, Path p){
    this.node=node;
    if(node>0){
      prev = p.path.get(node-1);
    }
    if(node<p.path.size()-1){
      after = p.path.get(node+1);
    }
    c = p.path.get(node);
    
  }
  
  
  void draw(float start,PGraphics pg){
    float startcutoff = 0;
    float endcutoff = 0;
    if(prev!=null){
       float cosa = sqrt((Vec2.dot(prev.normdir,c.normdir)+1)*0.5);
       float tana = sqrt(1-cosa*cosa)/cosa;
       startcutoff = tana*road.width/2;
    }
    if(after!=null){
       float cosa = sqrt((Vec2.dot(after.normdir,c.normdir)+1)*0.5);
       float tana = sqrt(1-cosa*cosa)/cosa;
       endcutoff = tana*road.width/2;
    }
    float px=c.start.x,py=c.start.y;
    px+=startcutoff*c.normdir.x;
    py+=startcutoff*c.normdir.y;
    
    float tx = c.normdir.y*road.width/2,ty= -c.normdir.x*road.width/2;
    
    pg.beginShape(TRIANGLES);
    pg.texture(road);
   
      if(prev!=null){
         float ptx = ((prev.normdir.y*road.width/2 )+ tx)/2,pty= ((-prev.normdir.x*road.width/2)+ty)/2;
        int direction = orientation(prev.start.x,prev.start.y,c.start.x,c.start.y,c.finish.x,c.finish.y);
        pg.vertex(px  - tx,  py - ty,road.width,road.height);
        pg.vertex(px  + tx,  py + ty,0,road.height);
        //turning right
        
        if(direction==1){
          pg.vertex(c.start.x  - ptx,  c.start.y - pty,road.width,road.height);
        }
        else if(direction==2){
          pg.vertex(c.start.x  + ptx,  c.start.y + pty,0,road.height);
        }
      }
      
      if(after!=null){
         float atx = ((after.normdir.y*road.width/2 )+ tx)/2,aty= ((-after.normdir.x*road.width/2)+ty)/2;
        float alen = (c.length-endcutoff-startcutoff);
        int direction = orientation(c.start.x,c.start.y,c.finish.x,c.finish.y,after.finish.x,after.finish.y);
        pg.vertex(px +c.normdir.x*alen - tx,  py +c.normdir.y*alen - ty,road.width,0);
        pg.vertex(px +c.normdir.x*alen + tx,  py +c.normdir.y*alen + ty,0,0);
        //turning right
        if(direction==1){
          pg.vertex(c.finish.x  - atx,  c.finish.y - aty,road.width,road.height);
        }
        else if(direction==2){
          pg.vertex(c.finish.x  + atx,  c.finish.y + aty,0,road.height);
        }
      }
      
    pg.endShape();
    pg.beginShape(QUADS);
    pg.texture(road);
    for(float pc = startcutoff;pc<c.length-endcutoff;pc+=road.height){
      
      float maximal  = min((c.length-endcutoff)-pc,road.height);
      
      
      pg.vertex(px + maximal*c.normdir.x + tx,  py + maximal*c.normdir.y+ty,0,0);
      pg.vertex(px + maximal*c.normdir.x - tx,  py + maximal*c.normdir.y-ty,road.width,0);
      pg.vertex(px  - tx,  py - ty,road.width,maximal);
      pg.vertex(px  + tx,  py + ty,0,maximal);
      
      px+=road.height*c.normdir.x;
      py+=road.height*c.normdir.y;
    }
    pg.endShape();
    
  }
  
  
  
}
