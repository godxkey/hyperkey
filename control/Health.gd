extends Node
class_name Health, "res://icons/health_icon.png"

export(int) var hit_points = 100 setget _set_hitpoints

signal no_health
signal health_changed
signal damage_taken

func apply_damage(damage):
  hit_points -= damage
  emit_signal("health_changed", hit_points)
  emit_signal("damage_taken", hit_points)
  if hit_points <= 0:
    emit_signal("no_health")
    get_parent().queue_free()

func instakill():
  _set_hitpoints(0)

func _set_hitpoints(value):
  hit_points = value
  emit_signal("health_changed", hit_points)
  if hit_points <= 0:
    emit_signal("no_health")
    get_parent().queue_free()
