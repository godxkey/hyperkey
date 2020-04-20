extends Area2D

export(int) var damage = 1
onready var health = $Health as Health
onready var linear_motion = $LinearMotion as LinearMotion

func _ready():
  health.connect("no_health", self, "queue_free")
  connect("body_entered", self, "on_hit")

func on_hit(body):
  if body.is_in_group("planet"):
    body.health.apply_damage(damage)
    queue_free()