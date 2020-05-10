extends Area2D
class_name Bullet

export(int) var damage = 1
export(float) var hit_power = 0.5
export(float) var max_knockback_speed = 75.0
export(float) var knock_back_angle = 10.0
onready var motion := $FollowTarget as FollowTarget

# Marks the bullet for critical hit
var critical_hit: bool = false

signal target_hit

func _ready():
  var res = connect("area_entered", self, "on_hit")
  assert(res == OK)

func on_hit(target):
  if target == motion.target:
    _apply_damage(target)
    _apply_knockback(target)
    _change_rotation_speed(target)
    emit_signal("target_hit", global_position, motion.get_velocity().angle())
    queue_free()

func _apply_damage(target):
  var target_health = target.get_node("Health")
  target_health.apply_damage(damage, critical_hit)

func _apply_knockback(target):
  var target_motion = target.get_node("FollowMotion")
  var to_target = position.direction_to(target.position)
  var speed = target_motion.get_velocity().length()
  var knockback_speed = max(speed * hit_power, max_knockback_speed)
  var knockback_force = to_target * knockback_speed
  var angle = deg2rad(rand_range(-knock_back_angle, knock_back_angle))
  target_motion.set_velocity(knockback_force.rotated(angle))

func _change_rotation_speed(target):
  target.rotation_speed += sign(target.rotation_speed) * 1.5
  if randf() < 0.1:
    target.rotation_speed = 1.0
  if randf() < 0.1:
    target.rotation_speed *= -1.0

func _process(_delta):
  set_rotation(motion.get_velocity().angle())
