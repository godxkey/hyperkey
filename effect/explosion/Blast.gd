extends AnimatedSprite

func _ready():
  rotate(rand_range(0, TAU))
  play()