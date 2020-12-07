extends Spatial

class_name Chunk

export (Array, PackedScene) var platforms
export var noise:OpenSimplexNoise
export(float, 500.0) var size:float = 10.0 setget _set_size
export(float, 10.0) var step:float = 2.0
export(float, 1.0) var density = 0.3
export(float, 500.0) var height_range = 2.0 setget _set_height_range
export(float, 180) var rotation_range = 180.0

signal generation_complete

var _generation_thread := Thread.new()

# Generator per chunk for now to prevent race conditions in multi-threaded generation.
var _number_generator := RandomNumberGenerator.new()

func _ready():
  populate()
  _number_generator.randomize()

# Populate the chunk with platforms
func populate():
  if can_generate():
    # Set seed before running in new thread.
    noise.seed = _number_generator.randi()
    var res = _generation_thread.start(self, "_generate")
    assert(res == OK)

func can_generate():
  return not _generation_thread.is_active() and not platforms.empty() and noise

func _generate(_discard_arg):
  for x in range(-size, size, step):
    for z in range(-size, size, step):
      var noise_level = 1.0 - density
      if _noise(x, z)  > noise_level:
        var platform = _platform_scene().instance()
        platform.translation = Vector3(x, _height(), z) + translation # Take into account chunk location
        platform.rotation_degrees.y = _rotation()
        platform.scale = _scale()
        add_child(platform)
  emit_signal("generation_complete")

func _noise(x:float, z:float):
  var noise_size = size * 2.0
  var raw_noise = noise.get_noise_2d(x * noise_size, z * noise_size)
  return (raw_noise + 1.0) / 2.0 # Normalize between 0 and 1

func _platform_scene():
  var pick = _number_generator.randi() % platforms.size()
  return platforms[pick];

func _height():
  return _number_generator.randf_range(-height_range, height_range)

func _rotation():
  return _number_generator.randf_range(-rotation_range, rotation_range)

func _scale():
  var scale = _number_generator.randf_range(1.0, 2.0)
  return Vector3(scale, scale, scale)

func _set_size(value:float):
  size = value
  # Add extra extents for visbility
  var vis = $VisibilityNotifier
  vis.aabb.size.x = size * 2.0
  vis.aabb.size.z = size * 2.0
  vis.aabb.position.x = -size
  vis.aabb.position.z = -size

func _set_height_range(value:float):
  height_range = value
  var vis = $VisibilityNotifier
  vis.aabb.size.y = height_range * 2.0
  vis.aabb.position.y = -height_range


func _exit_tree():
  _generation_thread.wait_to_finish()