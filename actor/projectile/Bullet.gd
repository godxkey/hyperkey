extends Area2D
class_name Bullet

signal target_hit

onready var follow = $FollowTarget

var _is_near := false

func _on_hit(object_hit):
  var target = follow.target
  if object_hit and object_hit == target:
    $Damage.apply_damage(target)
    emit_signal("target_hit", target, global_position, follow.get_velocity().angle())
    queue_free()

func _on_near(near_object):
  if not _is_near:
    var target = follow.target
    if near_object and near_object == target:
      # Increase homing acceleration so bullet does not miss target.
      follow.acceleration *= 100.0
      _is_near = false

func _process(_delta):
  set_rotation(follow.get_velocity().angle())