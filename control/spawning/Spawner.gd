extends Node
class_name Spawner, "res://icons/target_icon.png"

# How many active spawns at most. -1 means unlimited
export(int) var max_active = -1

# How many available spawns. -1 means it is infinite
export(int) var spawn_count = -1

# How often to spawn.
export(float) var frequency = 1.0 setget _set_frequency

# The area where spawns are placed.
onready var spawn_area = $SpawnArea

var blackboard := {}

signal spawned(spawn)

func _ready():
  var timer = $Timer
  var result = timer.connect("timeout", self, "_signal_spawned")
  assert(result == OK)
  timer.start()

func _signal_spawned():
  var s = spawn()
  if s: emit_signal("spawned", s)

func _set_frequency(value:float):
  frequency = value
  $Timer.wait_time = frequency

# Generic top level spawn call.
func spawn() -> Node2D:
  var s = _spawn()
  if s and spawn_area:
    s.position = spawn_area.spawn_position()
  return s

# Extended classes implement this to return a spawn object.
func _spawn() -> Node2D:
  return null
