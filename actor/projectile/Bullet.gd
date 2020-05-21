extends Area2D
class_name Bullet

onready var motion := $FollowTarget as FollowTarget

signal target_hit

func _ready():
  var res = connect("area_entered", self, "on_hit")
  assert(res == OK)

func on_hit(target):
  if target and target == motion.target:
    $Damage.apply_damage(target)
    _change_rotation_speed(target)
    emit_signal("target_hit", global_position, motion.get_velocity().angle())
    queue_free()

func _change_rotation_speed(target):
  var rotator = target.get_node_or_null("Rotator")
  if rotator:
    rotator.speed += sign(rotator.speed) * 1.5
    if randf() < 0.1:
      rotator.speed = 1.0
    if randf() < 0.1:
      rotator.speed *= -1.0

func _process(_delta):
  set_rotation(motion.get_velocity().angle())
