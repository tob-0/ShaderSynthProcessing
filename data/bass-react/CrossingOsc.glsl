// Thanks so much to ojack and every contributor of the hydra project, from which i got most of the GLSL functions, enabling me to start quickly
// Go check it out @ https://hydra.ojack.xyz/, it is a work of art

#ifdef GL_ES
precision mediump float;
#endif

#define PROCESSING_COLOR_SHADER
#define PI 3.1415926538

uniform vec2 u_resolution;
uniform float u_time;
uniform float u_subLvl;
uniform float u_bassLvl;

vec4 diff(vec4 _c0,vec4 _c1){
  return vec4(abs(_c0.rgb-_c1.rgb),max(_c0.a,_c1.a));
}

vec4 osc(vec2 _st,float freq,float sync,float offset){
  vec2 st=_st;
  float r=sin((st.x-offset*2./freq+u_time*sync)*freq)*.5+.5;
  float g=sin((st.x+u_time*sync)*freq)*.5+.5;
  float b=sin((st.x+offset/freq+u_time*sync)*freq)*.5+.5;
  return vec4(r,g,b,1.);
}

vec2 rotate(vec2 _st,float angle,float speed){
  vec2 xy=_st-vec2(.5);
  float ang=angle+speed*u_time;
  xy=mat2(cos(ang),-sin(ang),sin(ang),cos(ang))*xy;
  xy+=.5;
  return xy;
}

void main(){
  vec2 st=gl_FragCoord.st/u_resolution;
  vec4 osc00=osc(st,10.*u_bassLvl,.5,2.7*u_subLvl);
  vec4 osc01=osc(rotate(st,PI/4.,sin(u_time)*.07),30.*u_bassLvl,.5,.5*u_subLvl);
  gl_FragColor=diff(osc00,osc01);
}