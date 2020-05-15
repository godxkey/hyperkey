extends Node
class_name Spawner

onready var spawner = _get_child_spawner()

# Implement in extended class
# Returns null if object could not be spawned
func spawn(_tick:SpawnTick) -> Node2D:
  return null

func _get_child_spawner() -> Spawner:
  for c in get_children():
    if c.has_method("spawn"):
      return c
  return null
