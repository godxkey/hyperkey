extends LinearMotion

class_name LinearFollow

var target_ref := WeakRef.new()

func _physics_process(delta):
  ._physics_process(delta)
  var target = target_ref.get_ref()
  if target:
    _parent.look_at(target.global_transform.origin, Vector3.UP)
