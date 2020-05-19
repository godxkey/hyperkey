shader_type canvas_item;

uniform vec4 ShieldColor : hint_color;
uniform float OuterRadius;
uniform float InnerRadius;
uniform float Thickness;

void fragment() 
{
  vec2 to_center = UV.xy - vec2(0.5);
  float dist = dot(to_center, to_center) * 2.0;

  float outer_mask = smoothstep(OuterRadius, InnerRadius, dist);
  float inner_mask = smoothstep(InnerRadius - Thickness, InnerRadius, dist);
  
  COLOR.rgb = ShieldColor.rgb;
  COLOR.a = outer_mask * inner_mask;
}
