extends Node

func _ready():
  randomize()

# All levels should be under a node named World
func world_root():
  return get_node("/root/World")

func camera_shake():
  return world_root().get_node("Player/Camera2D/CameraShake")

func play_impact_camera_shake():
  camera_shake().shake(0.14, 24.0, 14.0, 1)

func play_strong_impact_camera_shake():
  camera_shake().shake(0.20, 24.0, 18.0, 2)

func view_center() -> Vector2:
  return world_root().get_node("Player/Camera2D").global_position
