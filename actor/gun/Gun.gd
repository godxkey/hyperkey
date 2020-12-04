extends Spatial

export var bullet_type:PackedScene

onready var _nozzle = $Nozzle
onready var _shot_audio = $ShotAudio

func fire():
  var bullet = bullet_type.instance()
  WorldOrigin.add_child(bullet)
  bullet.global_transform = _nozzle.global_transform
  _shot_audio.play()
  return bullet
