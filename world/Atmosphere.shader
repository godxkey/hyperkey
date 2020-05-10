shader_type canvas_item;

uniform vec4 atmosphere_color : hint_color;
uniform float atmosphere_power;

void fragment(){
  COLOR.rgb = atmosphere_color.rgb;
  // Controls the atmospheric fading.
  // Atmospheric color will be the strongest at the bottom fades at the top.
  COLOR.a = pow(UV.y, atmosphere_power);
 }