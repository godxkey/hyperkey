extends Control
class_name QuickInfo

export(float) var display_time = 1.0
export(float) var move_distance = 100.0
export(float) var move_angle = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
  var timer = $Timer
  var tween = $Tween

  timer.connect("timeout", self, "queue_free")
  timer.wait_time = display_time
  timer.one_shot = true
  timer.start()

  tween.interpolate_property(
    self,
    "modulate",
    Color(1.0, 1.0, 1.0, 1.0),
    Color(1.0, 1.0, 1.0, 0.0),
    timer.wait_time,
    Tween.TRANS_EXPO,
    Tween.EASE_IN)

  tween.interpolate_property(
    self,
    "rect_position",
    rect_position,
    rect_position + offset(),
    timer.wait_time,
    Tween.TRANS_EXPO,
    Tween.EASE_OUT)

  tween.start()

func offset() -> Vector2:
  return Vector2.RIGHT.rotated(move_angle) * move_distance