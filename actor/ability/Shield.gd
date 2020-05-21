extends Area2D

export var duration:float = 5.0

func _ready():
  var timer = $Timer
  timer.wait_time = duration
  timer.one_shot = true
  timer.start()

func _on_Shield_area_entered(other):
  if other.is_in_group("BaseActor"):
    other.get_node("Health").instakill()

func _on_Timer_timeout():
  queue_free()

func _on_Health_no_health():
  queue_free()