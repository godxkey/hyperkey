extends Node

# Uniform selection
func play():
  var sounds = get_children()
  var pick = sounds[randi() % sounds.size()]
  pick.play()