extends LinearMotion
class_name FollowTarget

var target: Node2D = null

func _physics_process(delta):
  if target:
    _acceleration = _parent.position.direction_to(target.position) * acceleration
  move(delta)