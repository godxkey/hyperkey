extends ParallaxLayer

export(float) var scroll_speed = 10.0

func _process(delta):
  motion_offset += Vector2(scroll_speed, scroll_speed) * delta
