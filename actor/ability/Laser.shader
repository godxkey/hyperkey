shader_type canvas_item;
uniform vec4 Tint : hint_color;
uniform float TintEdge = 0.8;
uniform float BrightEdge = 0.95;
uniform float BrightStrength = 5.0;

vec3 rgb2hsb( in vec3 c ){
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz),
                 vec4(c.gb, K.xy),
                 step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r),
                 vec4(c.r, p.yzx),
                 step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)),
                d / (q.x + e),
                q.x);
}

//  Function from Iñigo Quiles
//  https://www.shadertoy.com/view/MsS3Wc
vec3 hsb2rgb( in vec3 c ){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                             6.0)-3.0)-1.0,
                     0.0,
                     1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

void fragment(){
  float dist = 1.0 - abs(UV.y - 0.5);
  float edge = smoothstep(TintEdge, 1.0, dist);
  vec3 hsb = rgb2hsb(Tint.rgb);
  hsb.z += BrightStrength * smoothstep(BrightEdge, 1.0, dist) * edge;
  COLOR.rgb = hsb2rgb(hsb);
  COLOR.a = edge;
 }