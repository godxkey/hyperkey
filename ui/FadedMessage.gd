extends Node2D

export(float) var move_angle = 0.0
export(float) var move_offset = 100.0

onready var _tween = $Tween

func _ready():
  _tween.interpolate_property(
    self,
    "modulate",
    Color(1.0, 1.0, 1.0, 1.0),
    Color(1.0, 1.0, 1.0, 0.0),
    $LifeTimer.wait_time,
    Tween.TRANS_EXPO,
    Tween.EASE_IN)

  _tween.interpolate_property(
    self,
    "position",
    position,
    position + _offset(),
    $LifeTimer.wait_time,
    Tween.TRANS_EXPO,
    Tween.EASE_OUT)

  _tween.start()

func _offset():
  return Vector2.RIGHT.rotated(move_angle) * move_offset