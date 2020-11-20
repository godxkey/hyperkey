class_name Player

extends Area2D

export(float) var default_angle = 0 setget _set_default_angle
export(float) var rotation_smoothing = 12.0

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
  var current_rotation = Transform2D(sprite.rotation, Vector2.ZERO)
  var target_rotation = Transform2D(aim_rotation_angle(), Vector2.ZERO)
  var rotation_step = current_rotation.interpolate_with(target_rotation, delta * rotation_smoothing)
  sprite.set_rotation(rotation_step.get_rotation())

func _set_default_angle(value):
  default_angle = deg2rad(value)

func _set_aimed_target(value):
  aimed_target = weakref(value)

func _get_aimed_target():
  return aimed_target.get_ref()

func fire():
  var reset = true
  _gun_animation.stop(reset)
  _gun_animation.play("Shoot")

func gun_position():
  return _gun_location.global_position
