extends Spatial
class_name Bullet

func _perform_hit(other):
  $Damage.apply_damage(other)
  queue_free()
