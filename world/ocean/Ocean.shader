shader_type spatial;
render_mode specular_toon;

uniform sampler2D noise;
uniform float scroll_speed = 1.0;
uniform vec2 scroll_direction = vec2(1.0, 0.0);
uniform float ocean_size = 10.0;
uniform vec4 ocean_color : hint_color = vec4(0.0, 0.0, 1.0, 1.0);
uniform float depth_factor = 1.0;
uniform float alpha_scale = 1.0;

float noise_lookup(vec2 position){
  return texture(noise, position / ocean_size).x * 2.0 - 1.0;
}

float wave(vec2 position){
  vec2 wv = 1.0 - abs(sin(position));
  return pow(1.0 - pow(wv.x * wv.y, 0.65), 4.0);
}

float height(vec2 position, float time) {
  float h = noise_lookup(position + time * scroll_speed);
  position += h;
  h += wave(position * 0.1) * 0.5;
  h += wave(position * 0.3) * 0.2;
  h += wave(position * 0.2) * 0.1;
  return h;
}

vec3 lowpoly_normal(vec3 position) {
  vec3 x = dFdx(position);
  vec3 y = dFdy(position);
  return normalize(cross(x, y));
}

//vec3 real_normal(float wave_height, vec2 position, float time){
  //float xnorm = wave_height - height(position + vec2(0.1, 0.0), time);
  //float znorm = wave_height - height(position + vec2(0.0, 0.1), time);
  //return normalize(vec3(xnorm, 0.1, znorm));
//}

float depth_alpha(sampler2D depth_tex, vec2 screen_pos, mat4 projection, float z_pos){
  float depth = texture(depth_tex, screen_pos).x * 2.0 - 1.0;
  depth = projection[3][2] / (depth + projection[2][2]);
  depth += z_pos;
  depth = exp(-depth * depth_factor);
  return clamp(1.0 - depth, 0.0, 1.0);
}

void fragment() {
  RIM = 0.2;
  METALLIC = 0.1;
  ROUGHNESS = 0.01;
  ALBEDO = ocean_color.rgb;
  //ALPHA = depth_alpha(DEPTH_TEXTURE, SCREEN_UV, PROJECTION_MATRIX, VERTEX.z) * alpha_scale;
  //ALPHA = alpha_scale;
  NORMAL = lowpoly_normal(VERTEX);
}

void vertex() {
  vec2 pos = VERTEX.xz;
  VERTEX.y = height(pos, TIME);
}