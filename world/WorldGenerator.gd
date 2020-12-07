extends Spatial

export var world_speed:float = 1.0 setget _set_world_speed
export var world_move_direction:Vector3 = -Vector3.FORWARD
export var chunk_size:float = 5.0 setget _set_chunk_size
export var chunk_scene:PackedScene

onready var _chunk_root := $Chunks

func _ready():
  add_chunk()
  _update_generation_time()

func _set_world_speed(speed:float):
  world_speed = speed
  _update_generation_time()

func _set_chunk_size(size:float):
  chunk_size = size
  _update_generation_time()

func _update_generation_time():
  $GenerationTimer.wait_time = chunk_size / world_speed

func _physics_process(delta):
  # TODO: Maybe make motion be done at the chunk?
  for chunk in _chunk_root.get_children():
    chunk.translation += world_move_direction * world_speed * delta

func add_chunk():
  var chunk = chunk_scene.instance()
  chunk.size = chunk_size
  _chunk_root.add_child(chunk)

