tool
extends Spatial
class_name SpawnArea, "res://icons/area_position_icon.png"

export var length:float = 10.0 setget _set_length
export var width:float = 10.0 setget _set_width
export var height:float = 10.0 setget _set_height

var _box := AABB(Vector3.ZERO, Vector3.ONE)

func spawn_position() -> Vector3:
  var x = rand_range(_box.position.x, _box.end.x)
  var y = rand_range(_box.position.y, _box.end.y)
  var z = rand_range(_box.position.z, _box.end.z)
  return to_global(Vector3(x, y, z))

func _set_length(value):
  length = value
  _box.size.x = value
  _box.position.x = -value / 2.0
  if Engine.editor_hint:
    var v = _visual()
    if v:
      v.size.x = value

func _set_width(value):
  width = value
  _box.size.z = value
  _box.position.z = -value / 2.0
  if Engine.editor_hint:
    var v = _visual()
    if v:
      v.size.z = value

func _set_height(value):
  height = value
  _box.size.y = value
  _box.position.y = -value / 2.0
  if Engine.editor_hint:
    var v = _visual()
    if v:
      v.size.y = value

func _visual() -> CubeMesh:
  var v = get_node_or_null("Visual")
  return v.mesh as CubeMesh if v else null
