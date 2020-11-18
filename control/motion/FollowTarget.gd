extends LinearMotion
class_name FollowTarget, "res://icons/follow_icon.png"

var target = weakref(null) setget _set_target, _get_target

func _set_target(value):
  target = weakref(value)

func _get_target():
  return target.get_ref()

func _physics_process(delta):
  var tgt = target.get_ref()
  if tgt:
    start_moving_towards(tgt.global_position)
  move(delta)
