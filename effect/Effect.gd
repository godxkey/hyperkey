extends Node

func play_impact_effect(effect_resource, position:Vector2, impact_angle:float):
  var e = effect_resource.instance()
  add_child(e)
  e.global_position = position
  e.rotation = impact_angle + PI # Go against impact direction

func play_effect(effect_resource, position:Vector2):
  var e = effect_resource.instance()
  add_child(e)
  e.global_position = position

# Takes ownership of the effect and lets it finish the emission cycle before deletion.
func release_effect(e):
  e.get_parent().remove_child(e)
  add_child(e)
  e.emitting = false
  yield(get_tree().create_timer(e.lifetime), "timeout")
  e.queue_free()
