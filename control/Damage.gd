extends Node
class_name Damage, "res://icons/damage_icon.png"

export(int) var damage_points = 1
export(bool) var is_critical = false
export(float) var critical_multiplier = 1.0

func apply_damage(other:Node2D):
  var health = other.get_node_or_null("Health")
  if health:
    var total_damage = _critical_damage() if is_critical else damage_points
    health.apply_damage(total_damage, is_critical)
  apply_effects(other)

func apply_effects(target):
  for effect in get_children():
    effect.apply_effect(get_parent().position, target)

func _critical_damage() -> int:
  return (damage_points * critical_multiplier) as int