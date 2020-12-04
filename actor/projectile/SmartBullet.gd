extends Area

onready var _follow = $LinearFollow

func _perform_hit(other):
  if other.get_path() == _follow.target_path:
    Sound.play("Hit")
    $Damage.apply_damage(other)
    queue_free()

