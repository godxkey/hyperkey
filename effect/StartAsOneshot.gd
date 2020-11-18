extends Particles2D

# There is a godot bug that prevents setting emitting and one_shot both to true in editor.
# This sets up the particles to make the effect a one shot on start.
func _ready():
  emitting = true
  one_shot = true
