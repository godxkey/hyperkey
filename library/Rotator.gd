extends Node

export(float) var speed = 1.0

onready var _parent = get_parent()

func _process(delta):
  _parent.rotate(speed * delta)