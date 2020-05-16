extends Node

var blackboard := {}

func _ready():
  for spawner in get_children():
    spawner.blackboard = blackboard