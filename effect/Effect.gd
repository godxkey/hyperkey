extends Node

export(PackedScene) var _breaking_effect
export(PackedScene) var _explode_effect
export(PackedScene) var _explode_break

func play_explosion(position:Vector2, impact_rotation:float):
  var e = _explode_effect.instance()
  e.position = position
  e.rotation = impact_rotation + PI # Go against impact direciton
  e.emitting = true
  e.get_node("ExplosionSpark").emitting = true
  play_one_shot_effect(e)

func play_hit_break(position:Vector2, impact_rotation:float):
  var e = _breaking_effect.instance()
  e.position = position
  e.rotation = impact_rotation + PI
  play_one_shot_effect(e)

func play_explode_break(position:Vector2):
  var e = _explode_break.instance()
  e.position = position
  play_one_shot_effect(e)

func play_one_shot_effect(e):
  add_child(e)
  e.one_shot = true
  e.emitting = true
  var timer = e.get_node("Timer")
  timer.connect("timeout", e, "queue_free")
  timer.wait_time = e.lifetime
  timer.one_shot = true
  timer.start()

# Takes ownership of the effect and lets it finish the emission cycle before deletion.
func kill_effect_after_done(e):
  e.get_parent().remove_child(e)
  add_child(e)
  var timer = e.get_node("Timer")
  timer.wait_time = e.lifetime
  timer.connect("timeout", e, "queue_free")
  timer.start()
  e.emitting = false
