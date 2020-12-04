extends Node
class_name Damage, "res://icons/damage_icon.png"

export var damage_points:int = 1

func apply_damage(other):
  var health = other.get_node_or_null("Health")
  if health:
    health.apply_damage(damage_points)