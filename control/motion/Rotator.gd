extends Node
class_name Rotator, "res://icons/circle_arrow_icon.png"

export(float) var speed = 1.0
export(float) var min_speed = 1.0
export(float) var damping = 0.5
export(bool) var rotate_parent = false
export(NodePath) var rotated_node_path

onready var _parent = get_parent()
var _rotated_node = null

func _ready():
  if rotated_node_path:
    _rotated_node = get_node(rotated_node_path)

func _process(delta):
  var step:float = speed * delta
  if rotate_parent:
    get_parent().rotate(step)
  if _rotated_node:
    _rotated_node.rotate(step)
  speed = lerp(speed, min_speed, delta * damping)