extends Area

class_name Player

var _target_ref := WeakRef.new()

onready var _gun := $Gun

func _ready():
  # Signal starting health of player to any listeners. e.g. HUD
  _on_health_changed($Health.health())

func fire_at(_other_path):
  var target = _target_ref.get_ref()
  if target:
    _gun.look_at(target.global_transform.origin, Vector3.UP)
    _gun.fire()

func _on_health_changed(health):
  Stats.on_player_health_changed(health)

func _set_target_path(path):
  var t = get_node_or_null(path)
  if t:
    _target_ref = weakref(t)

func _set_target_for_bullet(bullet):
  bullet.get_node("LinearFollow").target_ref = _target_ref
