extends Spawner
class_name TickedSpawner, "res://icons/wait_icon.png"

onready var timer = $Timer

func spawn(tick:SpawnTick) -> Node2D:
  if timer.is_stopped():
    timer.start()
    return spawner.spawn(tick)
  return null
