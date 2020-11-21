class_name Player

extends Area2D

export(float) var rotation_smoothing = 4.0
export var bullet_resource:PackedScene

var aimed_target = weakref(null) setget _set_aimed_target, _get_aimed_target

onready var _gun_animation = $Gun/AnimationPlayer
onready var _gun_location = $Gun

func _ready():
  $Gun/Flash.visible = false

func _process(delta):
  _rotate_aim(delta)

func aim_rotation_angle() -> float:
  var target = aimed_target.get_ref()
  return global_position.direction_to(target.global_position).angle() if target else rotation

func _rotate_aim(delta:float):
  var angle = lerp_angle(rotation, aim_rotation_angle(), delta * rotation_smoothing)
  set_rotation(angle)

func _set_aimed_target(value):
  aimed_target = weakref(value)

func _get_aimed_target():
  return aimed_target.get_ref()

func _play_gun():
  var reset = true
  _gun_animation.stop(reset)
  _gun_animation.play("Shoot")

func fire_at_target(target, is_critical:bool):
  var bullet = Projectiles.spawn(
    bullet_resource,
    _gun_location.global_position,
    target)
  bullet.get_node("Damage").is_critical = is_critical

  # # If target is removed, make sure to remove bullet.
  target.connect("tree_exiting", bullet, "queue_free")
  _play_gun()

