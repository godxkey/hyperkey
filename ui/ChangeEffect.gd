extends Node

export(bool) var change_scale = true
export(float) var scale = 1.5
export(float) var scale_duration = 0.3

export(bool) var change_color = true
export(Color) var start_color = Color.red
export(Color) var end_color = Color.white
export(float) var color_duration = 0.2

func start():
  var parent = get_parent()
  var tween = $Tween
  if change_color:
    # Modulate from color to the original parent color
    tween.interpolate_property(
      parent,
      "modulate",
      start_color,
      end_color,
      color_duration,
      Tween.TRANS_QUART,
      Tween.EASE_IN)
  if change_scale:
    tween.interpolate_property(
      parent,
      "rect_scale",
      Vector2.ONE * scale,
      Vector2.ONE,
      scale_duration,
      Tween.TRANS_QUAD,
      Tween.EASE_OUT)
  tween.start()