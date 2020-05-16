extends Node
class_name Knockback, "res://icons/bounce_icon.png"

export(float) var hit_power = 0.5
export(float) var max_knockback_speed = 75.0
export(float) var knock_back_angle = 10.0

func apply_effect(position:Vector2, target):
  var target_motion = target.get_node("FollowTarget")
  var to_target = position.direction_to(target.position)
  var speed = target_motion.get_velocity().length()
  var knockback_speed = max(speed * hit_power, max_knockback_speed)
  var knockback_force = to_target * knockback_speed
  var angle = deg2rad(rand_range(-knock_back_angle, knock_back_angle))
  target_motion.set_velocity(knockback_force.rotated(angle))