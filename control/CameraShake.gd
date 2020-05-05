extends Node

onready var _camera: Camera2D = get_parent()

onready var _duration = $Duration
onready var _frequency = $Frequency
onready var _tween = $Tween

var _amplitude = 0.0
var _priority = 0

func shake(duration:float, frequency:float = 15.0, amplitude:float = 16.0, priority = 0):
  if priority >= _priority:
    _priority = priority
    _amplitude = amplitude

    _duration.wait_time = duration
    _frequency.wait_time = 1.0 / frequency

    _duration.start()
    _frequency.start()

    _new_shake()

func _reset():
  _tween_camera_offset(Vector2.ZERO)
  _priority = 0

func _on_Frequency_timeout():
  _new_shake()

func _on_Duration_timeout():
  _reset()
  _frequency.stop()

func _new_shake():
  _tween_camera_offset(_random_offset())
  _tween.start()

func _tween_camera_offset(offset):
  _tween.interpolate_property(
    _camera,
    "offset",
    _camera.offset,
    offset,
    _frequency.wait_time,
    Tween.TRANS_SINE,
    Tween.EASE_OUT)

func _random_offset() -> Vector2:
  # If new offset is in the same direction, then reflect.
  # This avoids shaking towards the same or near offset again.
  var offset = Vector2(_random_amplitude(), _random_amplitude())
  var dot =  _camera.offset.normalized().dot(offset.normalized())
  return offset if dot < 0 else -offset

func _random_amplitude() -> float:
  return rand_range(-_amplitude, _amplitude);
