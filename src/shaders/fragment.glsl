uniform float uTime;
uniform vec4 uResolution;
varying vec2 vUv;
varying vec3 vPosition;
float PI = 3.141592653589793238;


//sphere function
float sdSphere( vec3 p, float d )
{
  return length(p)-d;
}

//distance function
float sdf(vec3 p){
    return sdSphere(p,0.4);
}

void main(){


    vec3 camPos = vec3(0.0,0.0,2.0);
    vec3 ray = normalize(vec3((vUv - vec2(0.5))*uResolution.zw,-1.0));

    vec3 rayPos=camPos;
    float t = 0.0;
    float tMax=5.0;

    //raymarching
    for(int i=0;i<256;i++){
        vec3 pos = camPos + t*ray;
        float h = sdf(pos);
        if(h<0.0001 || t>tMax) break;
        t=t+h;
    }
    vec3 color = vec3(0.0);
    if(t<tMax){
        color = vec3(1.0);
    }

    gl_FragColor = vec4(color, 1.0);
    //gl_FragColor = vec4(vUv,0.0, 1.0);
}