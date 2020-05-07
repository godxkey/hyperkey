extends Node

# All levels should be under a node named World
func world_root():
  return get_node("/root/World")

func camera_shake():
  return world_root().get_node("Player/Camera2D/CameraShake")

func play_impact_camera_effect():
  camera_shake().shake(0.14, 24.0, 14.0, 1)