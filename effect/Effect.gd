extends Node

onready var camera_shake = get_tree().root.find_node("CameraShake", true, false)

func play_impact_camera_shake():
  camera_shake.shake(0.14, 24.0, 14.0, 1)

func play_strong_impact_camera_shake():
  camera_shake.shake(0.20, 24.0, 18.0, 2)

func play_impact_effect(fx_resource, position:Vector2, impact_angle:float):
  var e = fx_resource.instance()
  add_child(e)
  e.global_position = position
  e.rotation = impact_angle + PI # Go against impact direction

func play_effect(fx_resource, position:Vector2):
  var e = fx_resource.instance()
  add_child(e)
  e.global_position = position

# Takes ownership of the particles and lets it finish the emission cycle before deletion.
func release_particles(p):
  p.get_parent().remove_child(p)
  add_child(p)
  p.emitting = false
  yield(get_tree().create_timer(p.lifetime), "timeout")
  p.queue_free()
