tool
extends Node2D
class_name SpawnArea, "res://icons/area_position_icon.png"

export(float) var width = 400.0 setget _set_width
export(float) var height = 200.0 setget _set_height
export(Color) var debug_color = Color(0.8, 0.4, 0.0, 0.3) setget _set_debug_color

var _area := Rect2()

func spawn_position() -> Vector2:
  var x = rand_range(_area.position.x, _area.end.x)
  var y = rand_range(_area.position.y, _area.end.y)
  return transform.xform(Vector2(x, y))

func _set_width(value):
  width = value
  _area.size.x = value
  _area.position.x = -value / 2.0
  if Engine.editor_hint:
    update()

func _set_height(value):
  height = value
  _area.size.y = value
  _area.position.y = -value / 2.0
  if Engine.editor_hint:
    update()

func _set_debug_color(value:Color):
  debug_color = value
  if Engine.editor_hint:
    update()

func _draw():
  if Engine.editor_hint:
    draw_rect(_area, debug_color)