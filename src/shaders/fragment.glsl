uniform float uTime;
uniform vec4 uResolution;
uniform vec2 uMouse;
uniform sampler2D uMatcap1;
uniform sampler2D uMatcap2;
varying vec2 vUv;
varying vec3 vPosition;
float PI = 3.141592653589793238;


//function to rotate
mat4 rotationMatrix(vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                0.0,                                0.0,                                0.0,                                1.0);
}

vec3 rotate(vec3 v, vec3 axis, float angle) {
	mat4 m = rotationMatrix(axis, angle);
	return (m * vec4(v, 1.0)).xyz;
}

//polynomial smoothing
float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

//matcap
vec2 matcap(vec3 eye, vec3 normal) {
  vec3 reflected = reflect(eye, normal);
  float m = 2.8284271247461903 * sqrt( reflected.z+1.0 );
  return reflected.xy / m + 0.5;
}


//sphere function
float sdSphere( vec3 p, float d )
{
  return length(p)-d;
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

//distance function to render
float sdf(vec3 p){
    
    vec3 p1 = rotate(p,vec3(1.0),uTime/2.0); //rotate obj
    float sphere = sdSphere(p - vec3(uMouse * uResolution.zw,0.0),0.2);
    float box = smin(sdBox(p1,vec3(0.15)),sdSphere(p,0.15),0.15);
    return smin(box,sphere,0.2);

}

vec3 calcNormal( in vec3 p ) // for function f(p)
{
    const float eps = 0.0001; // or some other value
    const vec2 h = vec2(eps,0);
    return normalize( vec3(sdf(p+h.xyy) - sdf(p-h.xyy),
                           sdf(p+h.yxy) - sdf(p-h.yxy),
                           sdf(p+h.yyx) - sdf(p-h.yyx) ) );
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
        vec3 pos = camPos + t*ray;
        color = vec3(1.0);
        vec3 normal = calcNormal(pos);
        color = normal;
        float diff = dot(vec3(1.0),normal);
        vec2 matcapUV = matcap(ray,normal);
        color = vec3(diff);
        color = texture2D(uMatcap2,matcapUV).rgb;
    }

    gl_FragColor = vec4(color, 1.0);
    //gl_FragColor = vec4(vUv,0.0, 1.0);
}