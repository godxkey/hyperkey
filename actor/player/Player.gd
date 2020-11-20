class_name Player

extends Area2D

export(float) var default_angle = 0 setget _set_default_angle
export(float) var rotation_smoothing = 4.0
export var bullet_resource:PackedScene

var aimed_target = weakref(null) setget _set_aimed_target, _get_aimed_target

onready var sprite = $Sprite as Sprite
onready var _gun_animation = $Sprite/Gun/AnimationPlayer
onready var _gun_location = $Sprite/Gun

func _ready():
  $Sprite/Gun/Flash.visible = false

func _process(delta):
  rotate_sprite(delta)

func aim_rotation_angle() -> float:
  var target = aimed_target.get_ref()
  if target:
    return get_angle_to(target.position)
  else:
    return default_angle

func rotate_sprite(delta:float):
  var angle = lerp_angle(sprite.rotation, aim_rotation_angle(), delta * rotation_smoothing)
  sprite.set_rotation(angle)

func _set_default_angle(value):
  default_angle = deg2rad(value)

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
    _gun_location.position,
    target)
  bullet.get_node("Damage").is_critical = is_critical

  # # If target is removed, make sure to remove bullet.
  target.connect("tree_exiting", bullet, "queue_free")
  _play_gun()

