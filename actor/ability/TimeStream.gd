extends Area2D

export var duration:float = 5.0
export var slow_scale:float = 0.5

var targets_to_slow := []

func _ready():
  var timer = $Timer
  timer.wait_time = duration
  timer.one_shot = true

  $Tween.interpolate_property(
    self,
    "scale",
    Vector2(1, 0),
    Vector2(1, 1),
    1.0,
    Tween.TRANS_EXPO,
    Tween.EASE_OUT)

func _process(_delta):
  # Continuously set the time scale slowdown.
  # This allows having stacked streams.
  for t in targets_to_slow:
    t.motion.motion_scale = slow_scale

func _on_TimeStream_area_entered(other):
  if _is_in_groups_of_interest(other) and not is_under_slow(other):
    targets_to_slow.append(other)

func _on_TimeStream_area_exited(other):
  # When the target leaves, reset time scale and remove from processing list.
  if _is_in_groups_of_interest(other):
    other.motion.motion_scale = 1.0
    _remove_target(other)

func is_under_slow(target):
  return targets_to_slow.has(target)

func _remove_target(target):
  targets_to_slow.erase(target)

# TODO CHECK: Does queue free call area exited?
# When the ability ends, reset all time scales.
func _on_Timer_timeout():
  for area in get_overlapping_areas():
    if _is_in_groups_of_interest(area):
      area.motion.motion_scale = 1.0
  queue_free()

func _is_in_groups_of_interest(target):
  return target.is_in_group("BaseActor")