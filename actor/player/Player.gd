class_name Player

extends Node2D

export(float) var default_angle = 0 setget _set_default_angle
export(float) var rotation_smoothing = 12.0
export(float) var move_speed = 1.0
export(float) var tween_offset = 200

var aimed_target = weakref(null) setget _set_aimed_target, _get_aimed_target

onready var sprite = $Sprite as Sprite
onready var _tween = $Tween
onready var _tween_target = Vector2.RIGHT * tween_offset

func _ready():
  _tween.connect("tween_all_completed", self, "_new_move_tween")
  _new_move_tween()

func _process(delta):
  rotate_sprite(delta)

func aim_rotation_angle() -> float:
  var target = aimed_target.get_ref()
  if target:
    return get_angle_to(target.position)
  else:
    return default_angle

func _new_move_tween():
  _tween_target *= -1.0
  _tween.interpolate_property(
    self,
    "position",
    position,
    _tween_target,
    1.0 / move_speed,
    Tween.TRANS_SINE,
    Tween.EASE_IN_OUT)
  _tween.start()

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
