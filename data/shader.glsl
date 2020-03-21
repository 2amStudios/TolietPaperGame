#ifdef GL_ES
//precision highp float;
//precision highp int;
#endif

#define PROCESSING_TEXTURE_SHADER
#define PI 3.1415926538

uniform sampler2D texture;
uniform sampler2D noisetex;
uniform sampler2D pal;
uniform int steps;


uniform vec2 texOffset;
varying vec4 vertColor;
varying vec4 vertTexCoord;
uniform vec4 texAdjust;

float scale = 0.1;
const int amount = 10	;
const int shadowamount = 15	;
uniform vec2 offset;

void main() {
 //gl_FragCoord.
  vec2 pos = vertTexCoord.xy;
  vec4 color = texture2D(texture,pos);
  float bright = (texture2D(texture,pos).g)*(float(steps));
  float brightmodstep = (mod(bright,1.0)-0.5) * 0.5 +0.5;
  bright-=brightmodstep;
  float noiseval = texture2D(noisetex,mod(gl_FragCoord.xy*0.004+offset,vec2(0.99))).r;
  if(brightmodstep>noiseval){
	bright++;
  }
  
  bright = min(steps-1,bright);
  
  
  gl_FragColor = vec4(texture2D(pal,vec2((bright+0.5)/(float(steps)),0.5)).rgb * (1.0-color.r),1.0);
  
  

  
}