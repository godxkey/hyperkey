extends Spawner
class_name PositionedSpawner, "res://icons/area_position_icon.png"

onready var area = $SpawnArea

func spawn(tick:SpawnTick) -> Node2D:
  var s = spawner.spawn(tick)
  if s: s.position = area.spawn_position()
  return s