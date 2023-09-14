// Thanks so much to ojack and every contributor of the hydra project, from which i got most of the GLSL functions, enabling me to start quickly
// Go check it out @ https://hydra.ojack.xyz/, it is a work of art

#ifdef GL_ES
precision mediump float;
#endif

#define PROCESSING_COLOR_SHADER
#define PI 3.1415926538

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
uniform float u_generic0;
uniform float u_generic1;
uniform float u_generic2;
uniform float u_generic3;
uniform float u_generic4;
uniform float u_generic5;
uniform float u_generic6;
uniform sampler2D ppixels;

float _luminance(vec3 rgb){
  const vec3 W=vec3(.2125,.7154,.0721);
  return dot(rgb,W);
}

vec3 _rgbToHsv(vec3 c){
  vec4 K=vec4(0.,-1./3.,2./3.,-1.);
  vec4 p=mix(vec4(c.bg,K.wz),vec4(c.gb,K.xy),step(c.b,c.g));
  vec4 q=mix(vec4(p.xyw,c.r),vec4(c.r,p.yzx),step(p.x,c.r));
  
  float d=q.x-min(q.w,q.y);
  float e=1.e-10;
  return vec3(abs(q.z+(q.w-q.y)/(6.*d+e)),d/(q.x+e),q.x);
}

vec3 _hsvToRgb(vec3 c){
  vec4 K=vec4(1.,2./3.,1./3.,3.);
  vec3 p=abs(fract(c.xxx+K.xyz)*6.-K.www);
  return c.z*mix(K.xxx,clamp(p-K.xxx,0.,1.),c.y);
}

//	Simplex 3D Noise
//	by Ian McEwan, Ashima Arts
vec4 permute(vec4 x){return mod(((x*34.)+1.)*x,289.);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159-.85373472095314*r;}

float _noise(vec3 v){
  const vec2 C=vec2(1./6.,1./3.);
  const vec4 D=vec4(0.,.5,1.,2.);
  
  // First corner
  vec3 i=floor(v+dot(v,C.yyy));
  vec3 x0=v-i+dot(i,C.xxx);
  
  // Other corners
  vec3 g=step(x0.yzx,x0.xyz);
  vec3 l=1.-g;
  vec3 i1=min(g.xyz,l.zxy);
  vec3 i2=max(g.xyz,l.zxy);
  
  //  x0 = x0 - 0. + 0.0 * C
  vec3 x1=x0-i1+1.*C.xxx;
  vec3 x2=x0-i2+2.*C.xxx;
  vec3 x3=x0-1.+3.*C.xxx;
  
  // Permutations
  i=mod(i,289.);
  vec4 p=permute(
    permute(
      permute(
        i.z+vec4(0.,i1.z,i2.z,1.)
      )
      +i.y+vec4(0.,i1.y,i2.y,1.)
    )
    +i.x+vec4(0.,i1.x,i2.x,1.)
  );
  
  // Gradients
  // ( N*N points uniformly over a square, mapped onto an octahedron.)
  float n_=1./7.;// N=7
  vec3 ns=n_*D.wyz-D.xzx;
  
  vec4 j=p-49.*floor(p*ns.z*ns.z);//  mod(p,N*N)
  
  vec4 x_=floor(j*ns.z);
  vec4 y_=floor(j-7.*x_);// mod(j,N)
  
  vec4 x=x_*ns.x+ns.yyyy;
  vec4 y=y_*ns.x+ns.yyyy;
  vec4 h=1.-abs(x)-abs(y);
  
  vec4 b0=vec4(x.xy,y.xy);
  vec4 b1=vec4(x.zw,y.zw);
  
  vec4 s0=floor(b0)*2.+1.;
  vec4 s1=floor(b1)*2.+1.;
  vec4 sh=-step(h,vec4(0.));
  
  vec4 a0=b0.xzyw+s0.xzyw*sh.xxyy;
  vec4 a1=b1.xzyw+s1.xzyw*sh.zzww;
  
  vec3 p0=vec3(a0.xy,h.x);
  vec3 p1=vec3(a0.zw,h.y);
  vec3 p2=vec3(a1.xy,h.z);
  vec3 p3=vec3(a1.zw,h.w);
  
  //Normalise gradients
  vec4 norm=taylorInvSqrt(vec4(dot(p0,p0),dot(p1,p1),dot(p2,p2),dot(p3,p3)));
  p0*=norm.x;
  p1*=norm.y;
  p2*=norm.z;
  p3*=norm.w;
  
  // Mix final noise value
  vec4 m=max(.6-vec4(dot(x0,x0),dot(x1,x1),dot(x2,x2),dot(x3,x3)),0.);
  m=m*m;
  return 42.*dot(m*m,vec4(dot(p0,x0),dot(p1,x1),dot(p2,x2),dot(p3,x3)));
}

vec4 voronoi(vec2 _st,float scale,float speed,float blending){
  vec3 color=vec3(.0);
  // Scale
  _st*=scale;
  // Tile the space
  vec2 i_st=floor(_st);
  vec2 f_st=fract(_st);
  float m_dist=10.;// minimun distance
  vec2 m_point;// minimum point
  for(int j=-1;j<=1;j++){
    for(int i=-1;i<=1;i++){
      vec2 neighbor=vec2(float(i),float(j));
      vec2 p=i_st+neighbor;
      vec2 point=fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
      point=.5+.5*sin(u_time*speed+6.2831*point);
      vec2 diff=neighbor+point-f_st;
      float dist=length(diff);
      if(dist<m_dist){
        m_dist=dist;
        m_point=point;
      }
    }
  }
  // Assign a color using the closest point position
  color+=dot(m_point,vec2(.3,.6));
  color*=1.-blending*m_dist;
  return vec4(color,1.);
}

vec4 add(vec4 _c0,vec4 _c1,float amount){
  return(_c0+_c1)*amount+_c0*(1.-amount);
}
vec4 sub(vec4 _c0,vec4 _c1,float amount){
  return(_c0-_c1)*amount+_c0*(1.-amount);
}

vec4 blend(vec4 _c0,vec4 _c1,float amount){
  return _c0*(1.-amount)+_c1*amount;
}

vec4 mult(vec4 _c0,vec4 _c1,float amount){
  return _c0*(1.-amount)+(_c0*_c1)*amount;
}

vec4 diff(vec4 _c0,vec4 _c1){
  return vec4(abs(_c0.rgb-_c1.rgb),max(_c0.a,_c1.a));
}

vec4 noise(vec2 _st,float scale,float offset){
  return vec4(vec3(_noise(vec3(_st*scale,offset*u_time))),1.);
}

vec4 layer(vec4 _c0,vec4 _c1){
  return vec4(mix(_c0.rgb,_c1.rgb,_c1.a),clamp(_c0.a+_c1.a,0.,1.));
}

vec4 osc(vec2 _st,float freq,float sync,float offset){
  vec2 st=_st;
  float r=sin((st.x-offset*2./freq+u_time*sync)*freq)*.5+.5;
  float g=sin((st.x+u_time*sync)*freq)*.5+.5;
  float b=sin((st.x+offset/freq+u_time*sync)*freq)*.5+.5;
  return vec4(r,g,b,1.);
}
vec4 colorama(vec4 _c0,float amount){
  vec3 c=_rgbToHsv(_c0.rgb);
  c+=vec3(amount);
  c=_hsvToRgb(c);
  c=fract(c);
  return vec4(c,_c0.a);
}
vec4 brightness(vec4 _c0,float amount){
  return vec4(_c0.rgb+vec3(amount),_c0.a);
}

vec4 contrast(vec4 _c0,float amount){
  vec4 c=(_c0-vec4(.5))*vec4(amount)+vec4(.5);
  return vec4(c.rgb,_c0.a);
}

vec2 rotate(vec2 _st,float angle,float speed){
  vec2 xy=_st-vec2(.5);
  float ang=angle+speed*u_time;
  xy=mat2(cos(ang),-sin(ang),sin(ang),cos(ang))*xy;
  xy+=.5;
  return xy;
}

vec2 repeat(vec2 _st,float repeatX,float repeatY,float offsetX,float offsetY){
  vec2 st=_st*vec2(repeatX,repeatY);
  st.x+=step(1.,mod(st.y,2.))*offsetX;
  st.y+=step(1.,mod(st.x,2.))*offsetY;
  return fract(st);
}

vec2 modulateScale(vec2 _st,vec4 _c0,float multiple,float offset){
  vec2 xy=_st-vec2(.5);
  xy*=(1./vec2(offset+multiple*_c0.r,offset+multiple*_c0.g));
  xy+=vec2(.5);
  return xy;
}

vec2 modulate(vec2 _st,vec4 _c0,float amount){
  return _st+_c0.xy*amount;
}

vec2 pixelate(vec2 _st,float pixelX,float pixelY){
  vec2 xy=vec2(pixelX,pixelY);
  return(floor(_st*xy)+.5)/xy;
}

vec4 color(vec4 _c0,float r,float g,float b,float a){
  vec4 c=vec4(r,g,b,a);
  vec4 pos=step(0.,c);
  return vec4(mix((1.-_c0)*abs(c),c*_c0,pos));
}

/*
* Source function to generate a shape
* defaults: 3.0 - 0.3 - 0.01
*/
vec4 shape(vec2 _st, float sides, float radius, float smoothing) {
  vec2 st = _st * 2. - 1.;
  // Angle and radius from the current pixel
  float a = atan(st.x,st.y)+3.1416;
  float r = (2.*3.1416)/sides;
  float d = cos(floor(.5+a/r)*r-a)*length(st);
  return vec4(vec3(1.0-smoothstep(radius,radius + smoothing + 0.0000001,d)), 1.0);
}

/*
* Color modifier function
* defaults: 0.01 - 0.01
*/
vec4 luma(vec4 _c0, float threshold, float tolerance) {
  float a = smoothstep(threshold-(tolerance+0.0000001), threshold+(tolerance+0.0000001), _luminance(_c0.rgb));
  return vec4(_c0.rgb*a, a);
}

/*
* Source function to convert a 2d tex to a vec4
*/
vec4 src(vec2 _st,sampler2D tex){
  return texture2D(tex,fract(_st));
}

vec4 posterize(vec4 _c0,float bins,float gamma){
  vec4 c2=pow(_c0,vec4(gamma));
  c2*=vec4(bins);
  c2=floor(c2);
  c2/=vec4(bins);
  c2=pow(c2,vec4(1./gamma));
  return vec4(c2.xyz,_c0.a);
}

vec4 mask(vec4 _c0,vec4 _c1){
  float a=_luminance(_c1.rgb);
  return vec4(_c0.rgb*a,a*_c0.a);
}

vec2 kaleid(vec2 _st,float nSides){
  vec2 st=_st;
  st-=.5;
  float r=length(st);
  float a=atan(st.y,st.x);
  float pi=2.*PI;
  a=mod(a,pi/nSides);
  a=abs(a-pi/nSides/2.);
  return r*vec2(cos(a),sin(a));
}

void main(){
  vec2 st=gl_FragCoord.st/u_resolution;
  
  vec4 color=vec4(0.);
  
  vec2 _st=modulate(st,osc(rotate(st,9.,0.),6,-.1,0.),.5);
  _st=modulate(_st,osc(rotate(st,6,0),9,-.3,900),.5*u_bassLvl);
  vec4 osc00=osc(modulate(st,osc(rotate(_st,15.,0.),2,-.3,100),.5),215*u_generic0,.1,2);
  osc00=mult(osc00,osc(pixelate(st,500.,0.),215,.1*u_generic0,2.),1.);
  osc00=color(osc00,.9,0.,.9,1.);
  osc00=add(osc00,color(osc(_st,10,-.9,900),1*u_subLvl,0.,1,1),1);
  osc00=mult(osc00,colorama(luma(shape(repeat(_st,20,200,0.,0.),900,.2,1.),.5,.1),10.),1.);
  osc00=add(osc00,color(osc(st,4,3*u_subLvl,90),.5,0.,1.,1.),1.);
  vec4 osc01=osc(rotate(st,PI*4*u_subLvl,.2*u_subLvl),20,5*u_midLvl,3*u_subLvl);
  gl_FragColor=add(osc00,osc01,.7);//vec4(st.x,st.y*u_generic0,1.,1.);
}