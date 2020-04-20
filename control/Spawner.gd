tool
extends Node2D
class_name Spawner

export(PackedScene) var spawn_type
export(Rect2) var spawn_area = Rect2(0, 0, 400, 200) setget _set_spawn_area

var _debug_spawn_area_color = Color(0.8, 0.4, 0.0, 0.3)
var _rng = RandomNumberGenerator.new()
onready var timer = $Timer as Timer

func _ready():
  _rng.randomize()

func spawn() -> Node2D:
  var x = _rng.randf_range(spawn_area.position.x, spawn_area.end.x)
  var y = _rng.randf_range(spawn_area.position.y, spawn_area.end.y)
  var spawn_object = spawn_type.instance()

  spawn_object.position = transform.xform(Vector2(x, y))
  return spawn_object

func bulk_spawn(count:int) -> Array:
  var spawns = []
  for _spawn in range(count):
    spawns.append(spawn())
  return spawns

func _set_spawn_area(value):
  spawn_area = value
  if Engine.editor_hint:
    update()

func _draw():
  if Engine.editor_hint:
    draw_rect(spawn_area, _debug_spawn_area_color)
