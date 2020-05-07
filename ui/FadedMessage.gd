extends Node2D

export(Vector2) var move_orientation = Vector2.DOWN

onready var _color_tween = $ColorTween
onready var _move_tween = $MoveTween

func _ready():
  _color_tween.interpolate_property(
    self,
    "modulate",
    Color(1.0, 1.0, 1.0, 1.0),
    Color(1.0, 1.0, 1.0, 0.0),
    $LifeTimer.wait_time,
    Tween.TRANS_EXPO,
    Tween.EASE_IN)
  _color_tween.start()

  _move_tween.interpolate_property(
    self,
    "position",
    position,
    position + _random_offset(),
    $LifeTimer.wait_time,
    Tween.TRANS_EXPO,
    Tween.EASE_OUT)
  _move_tween.start()

func _random_offset():
  var angle = rand_range(-1.0, 1.0)
  return move_orientation.rotated(angle) * 100.0