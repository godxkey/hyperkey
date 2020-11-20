extends AnimatedSprite

func _ready():
  rotate(rand_range(-PI, PI))
  show()
  play()