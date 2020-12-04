extends LinearMotion

class_name LinearFollow

export var target_path:NodePath

func _physics_process(delta):
  ._physics_process(delta)
  var target = get_node_or_null(target_path)
  if target:
    _parent.look_at(target.global_transform.origin, Vector3.UP)
