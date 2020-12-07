extends Gun

export var burst_duration:float = 0.5 setget _set_burst_duration
export var cooldown:float = 1.0 setget _set_cooldown
export var firerate:float = 0.1 setget _set_firerate

onready var _duration_timer := $DurationTimer
onready var _cooldown_timer := $CooldownTimer
onready var _firerate_timer := $FireRateTimer

func fire():
  if _cooldown_timer.is_stopped() and _duration_timer.is_stopped():
    _duration_timer.start()
    _firerate_timer.start()

func _set_burst_duration(duration:float):
  $DurationTimer.wait_time = duration

func _set_cooldown(time:float):
  $CooldownTimer.wait_time = time

func _set_firerate(rate:float):
  $FireRateTimer.wait_time = rate
