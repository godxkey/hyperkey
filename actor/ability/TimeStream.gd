extends Area2D

export var duration:float = 5.0
export var slow_scale:float = 0.5

var _targets_to_slow := []

func _ready():
  var timer = $Timer
  timer.wait_time = duration
  timer.one_shot = true