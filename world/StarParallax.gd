extends ParallaxLayer

export(float) var scroll_speed = 1.0
export(float) var scroll_scale = 100.0

var _noise = OpenSimplexNoise.new()

func _init():
  _noise.seed = randi()

func _process(delta):
  motion_offset += Vector2(scroll_speed, scroll_speed) * delta
