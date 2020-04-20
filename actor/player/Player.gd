class_name Player

extends Node2D

export(float) var default_angle = 0 setget _set_default_angle
export(float) var rotation_smoothing = 12.0

var aimed_target:Node2D = null

onready var sprite = $Sprite as Sprite

func _process(delta):
  rotate_sprite(delta)

func aim_rotation_angle() -> float:
  if aimed_target != null:
    return get_angle_to(aimed_target.position)
  else:
    return default_angle

func rotate_sprite(delta:float):
  var current_rotation = Transform2D(sprite.rotation, Vector2.ZERO)
  var target_rotation = Transform2D(aim_rotation_angle(), Vector2.ZERO)
  var rotation_step = current_rotation.interpolate_with(target_rotation, delta * rotation_smoothing)
  sprite.set_rotation(rotation_step.get_rotation())

func _set_default_angle(value):
  default_angle = deg2rad(value)