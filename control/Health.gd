extends Node
class_name Health

export(int) var hit_points = 100 setget _set_hitpoints

signal no_health

func apply_damage(damage):
  hit_points -= damage
  if hit_points <= 0:
    emit_signal("no_health")

func _set_hitpoints(value):
  hit_points = value
  if hit_points <= 0:
    emit_signal("no_health")
