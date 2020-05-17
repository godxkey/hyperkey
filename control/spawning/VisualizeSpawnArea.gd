tool
extends Node2D

func _draw():
  if Engine.editor_hint:
    var parent = get_parent()
    draw_rect(parent.get_area(), parent.debug_color)
