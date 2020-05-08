extends Node

export(Array, String) var sounds

func _ready():
  for s in sounds:
    Sound.play(s)