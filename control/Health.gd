extends Node
class_name Health, "res://icons/health_icon.png"

# The base health. This is not affected by damage.
export var base_health:int = 100

signal no_health
signal health_changed(health)
signal damage_taken(damage)

# Current health. This is affected damage.
# On start, health matches base health
onready var _health:int = base_health setget ,health

func health() -> int:
  return _health

func reset_health(health:int):
  base_health = health
  _health = health

func apply_damage(damage):
  _health -= damage
  _health = int(max(_health, 0)) # Prevent subzero health.
  emit_signal("health_changed", _health)
  emit_signal("damage_taken", damage)
  if _health <= 0:
    _kill_parent()

func instakill():
  _health = 0
  emit_signal("health_changed", _health)
  _kill_parent()

func health_percentage() -> float:
  return 100.0 * (_health / float(base_health)) if base_health > 0 else 0.0

func _kill_parent():
  emit_signal("no_health")
  get_parent().queue_free()
