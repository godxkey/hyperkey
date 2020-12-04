extends Node

class_name LinearMotion

onready var _parent = get_parent()

export var speed := 100.0

func _physics_process(delta):
  _parent.translate(Vector3.FORWARD * speed * delta);