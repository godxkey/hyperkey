extends Node2D
class_name Spawner, "res://icons/target_icon.png"

const UNLIMITED_COUNT:int = -1

# How many active spawns at most. -1 means unlimited.
export(int) var max_active = UNLIMITED_COUNT

# How many available spawns. -1 means unlimited.
export(int) var max_spawns = UNLIMITED_COUNT

# How often to spawn.
export(float) var frequency = 1.0 setget _set_frequency

# Controls how many to spawn at once.
export(int) var emit_count = 1

export(bool) var active = true

export(PackedScene) var spawn_scene = null

onready var spawn_area = $SpawnArea

# How many spawns are alive
var _active_count:int = 0

# How many spawns were created for the entire history of the spawner.
var _spawned_count:int = 0

signal spawned(spawn)

# Triggers when total spawned count reaches the spawn count limit
signal is_done

func _ready():
  var timer = $Timer
  var result = timer.connect("timeout", self, "_signal_spawned")
  assert(result == OK)
  timer.start()

func _signal_spawned():
  if active and (not is_at_capacity() and not is_out_of_spawns()):
    for _i in emit_count:
      var s = spawn()
      if s:
        _active_count += 1
        _spawned_count += 1
        s.connect("tree_exiting", self, "_decrement_active_spawns")
        emit_signal("spawned", s)
        if is_out_of_spawns():
          emit_signal("is_done")
          $Timer.stop()
        if is_at_capacity():
          $Timer.paused = true

func _decrement_active_spawns():
  _active_count -= 1
  if not is_at_capacity():
    $Timer.paused = false

func reset():
  _active_count = 0
  _spawned_count = 0
  $Timer.start()

func is_at_capacity() -> bool:
  return false if max_active == UNLIMITED_COUNT else _active_count >= max_active

func is_out_of_spawns() -> bool:
  return false if max_spawns == UNLIMITED_COUNT else _spawned_count >= max_spawns

func _set_frequency(value:float):
  frequency = value
  $Timer.wait_time = frequency

# Generic top level spawn call.
func spawn() -> Node2D:
  var s = _spawn()
  if s:
    s.global_position = spawn_area.spawn_position()
  return s

# Extended classes implement this to return a spawn object.
func _spawn() -> Node2D:
  return spawn_scene.instance()
