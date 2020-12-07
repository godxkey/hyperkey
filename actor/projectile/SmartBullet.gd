extends Area

onready var _follow = $LinearFollow

func _perform_hit(other):
  if other == _follow.target_ref.get_ref():
    Sound.play("Hit")
    $Damage.apply_damage(other)
    queue_free()

