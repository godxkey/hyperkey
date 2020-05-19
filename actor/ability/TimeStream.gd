extends Area2D

export var duration:float = 5.0
export var slow_scale:float = 0.5

func _ready():
  var timer = $Timer
  timer.wait_time = duration
  timer.one_shot = true
  timer.start()

func _on_TimeStream_area_entered(other):
  if other.is_in_group("BaseActor"):
    other.motion.motion_scale = slow_scale

func _on_TimeStream_area_exited(other):
  if other.is_in_group("BaseActor"):
    other.motion.motion_scale = 1.0

# TODO CHECK: Does queue free call area exited?
func _on_Timer_timeout():
  for area in get_overlapping_areas():
    if area.is_in_group("BaseActor"):
      area.motion.motion_scale = 1.0
  queue_free()