extends Node

func _ready():
  randomize()

# All levels should be under a node named World
func world_root():
  return get_node("/root/World")

func view_center() -> Vector2:
  return world_root().get_node("Camera2D").global_position
