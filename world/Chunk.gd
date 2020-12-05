extends Spatial

export (Array, PackedScene) var platforms
export var noise:OpenSimplexNoise
export(float, 500.0) var size:float = 10.0
export(float, 10.0) var step:float = 2.0
export(float, 1.0) var density = 0.3
export(float, 500.0) var height_range = 2.0
export(float, 180) var rotation_range = 180.0

signal generation_complete

var _generation_thread := Thread.new()

func _ready():
  populate()

# Populate the chunk with platforms
func populate():
  if can_generate():
    var res = _generation_thread.start(self, "_generate")
    assert(res == OK)

func can_generate():
  return not _generation_thread.is_active() and not platforms.empty() and noise

func _generate(_discard_arg):
  noise.seed = randi() # FIME: Not thread safe if noise is shared with other scenes.
  for x in range(-size, size, step):
    for z in range(-size, size, step):
      var noise_level = 1.0 - density
      if _noise(x, z)  > noise_level:
        var platform = _platform_scene().instance()
        platform.translation = Vector3(x, _height(), z)
        platform.rotation_degrees.y = _rotation()
        add_child(platform)
  emit_signal("generation_complete")

func _noise(x:float, z:float):
  var noise_size = size * 2.0
  var raw_noise = noise.get_noise_2d(x * noise_size, z * noise_size)
  return (raw_noise + 1.0) / 2.0 # Normalize between 0 and 1

func _platform_scene():
  # FIXME: Not thread safe since we are accessing same random engine.
  var pick = randi() % platforms.size()
  return platforms[pick];

func _height():
  return rand_range(-height_range, height_range)

func _rotation():
  return rand_range(-rotation_range, rotation_range)

func _exit_tree():
  _generation_thread.wait_to_finish()