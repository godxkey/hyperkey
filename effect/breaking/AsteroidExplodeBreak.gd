extends Particles2D

func _ready():
  var blast = $Blast
  blast.rotate(rand_range(0, TAU))
  blast.play()
  blast.connect("animation_finished", blast, "hide")
