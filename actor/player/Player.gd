extends Area

class_name Player

var _target_path:NodePath

onready var _gun := $Gun

func fire_at(_other_path):
  var target = get_node_or_null(_target_path)
  if target:
    _gun.look_at(target.global_transform.origin, Vector3.UP)
  var bullet = _gun.fire()
  bullet.get_node("LinearFollow").target_path = _target_path

func _set_target_path(path):
  _target_path = path
