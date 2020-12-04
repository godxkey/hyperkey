extends Spatial
class_name Bullet

onready var _raycast := $RayCast

func _ready():
  _raycast.cast_to = translation

func _physics_process(_delta):
  var other = _raycast.get_collider()
  if other:
    _perform_hit(other)
  _raycast.cast_to = translation

func _perform_hit(other):
  $Damage.apply_damage(other)
  queue_free()
