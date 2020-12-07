extends Spatial

class_name Gun

export var bullet_type:PackedScene
export var shot_stream:AudioStream setget _set_shot_stream

# Angle spread in degrees to control accuracy.
# A value of zero means the gun has 100% laser accuracy.
export var spread:float = 0.0 setget _set_spread

onready var _nozzle = $Nozzle
onready var _shot_stream_player = $ShotStreamPlayer

signal bullet_shot(bullet)

# Virtual
# Default behavior simply spawns a bullet upon calling.
func fire():
  _create_bullet()

func _create_bullet():
  var bullet := bullet_type.instance() as Spatial
  bullet.transform = _nozzle.global_transform
  if spread != 0.0:
    bullet.rotate_object_local(Vector3.UP, rand_range(-spread, spread))
    bullet.rotate_object_local(Vector3.RIGHT, rand_range(-spread, spread))
  WorldOrigin.add_child(bullet)
  _shot_stream_player.play()
  emit_signal("bullet_shot", bullet)

func _set_shot_stream(stream:AudioStream):
  $ShotStreamPlayer.stream = stream

# Converts spread to radians to rotate a spatial.
func _set_spread(degrees:float):
  spread = deg2rad(degrees)