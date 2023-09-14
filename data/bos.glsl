
#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359
#define TWO_PI 6.28318530718

uniform vec2 u_resolution;
uniform vec3 u_mouse;
uniform float u_time;
uniform float u_soundLvl;
uniform float u_subLvl;
uniform float u_bassLvl;
uniform float u_lowLvl;
uniform float u_midLvl;
uniform float u_highLvl;
uniform float u_tempo;
uniform float u_st_offx;
uniform float u_st_offy;
uniform sampler2D ppixels;

float box(in vec2 _st,in vec2 _size){
  _size=vec2(.5)-_size*.5;
  vec2 uv=smoothstep(_size,_size+vec2(.001),_st);
  uv*=smoothstep(_size,_size+vec2(.001),vec2(1.)-_st);
  return uv.x*uv.y;
}

float cross(in vec2 _st,float _size){
  return box(_st,vec2(_size,_size/3.))+
  box(_st,vec2(_size/3.,_size));
}
mat2 rotate2d(float _angle){
  return mat2(cos(_angle),-sin(_angle),
  sin(_angle),cos(_angle));
}

float random(in vec2 _st){
  return fract(sin(dot(_st.xy,
        vec2(12.9898,78.233)))*
      43758.5453123);
    }
    
    // Based on Morgan McGuire @morgan3d
    // https://www.shadertoy.com/view/4dS3Wd
    float noise(in vec2 _st){
      vec2 i=floor(_st);
      vec2 f=fract(_st);
      
      // Four corners in 2D of a tile
      float a=random(i);
      float b=random(i+vec2(1.,0.));
      float c=random(i+vec2(0.,1.));
      float d=random(i+vec2(1.,1.));
      
      vec2 u=f*f*(3.-2.*f);
      
      return mix(a,b,u.x)+
      (c-a)*u.y*(1.-u.x)+
      (d-b)*u.x*u.y;
    }
    
    #define NUM_OCTAVES 12
    
    float fbm(in vec2 _st){
      float v=0.;
      float a=.5;
      vec2 shift=vec2(100.);
      // Rotate to reduce axial bias
      mat2 rot=mat2(cos(.5),sin(.5),
      -sin(.5),cos(.50));
      for(int i=0;i<NUM_OCTAVES;++i){
        v+=a*noise(_st);
        _st=rot*_st*2.+shift;
        a*=.5;
      }
      return v;
    }
    
    void main(){
      vec2 st=gl_FragCoord.st/u_resolution.xy;
      // st+=st*abs(sin(u_time*.1)*3.);
      st.x+=u_time/10.;
      vec3 color=vec3(.6,.5608,.5608);
      
      vec2 q=vec2(0.);
      q.x=fbm(st+0.*u_time);
      q.y=fbm(st+vec2(1.));
      
      vec2 r=vec2(0.);
      r.x=fbm(st+1.*q+vec2(.7)+.1*u_time);
      r.y=fbm(st+1.*q+vec2(.3)+.1*u_time);
      float f=fbm(st+r);
      
      color=mix(vec3(.101961,.619608,.666667),
      vec3(.666667,.666667,.498039),
      clamp((f*f)*4.,0.,1.));
      
      color=mix(color,
        vec3(0,0,.164706),
        clamp(length(q),0.,1.)
      );
      
      color=mix(color,
        vec3(.666667,1,1),
        clamp(length(r.x),0.,1.)
      );
      
      gl_FragColor=vec4((f*f*f+.6*f*f+.5*f*u_bassLvl)*color,1.);
    }