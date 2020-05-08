extends Node
class_name SoundSelector

# Uniform selection
func play():
  var sounds = get_children()
  if not sounds.empty():
    var pick = sounds[randi() % sounds.size()]
    pick.play()