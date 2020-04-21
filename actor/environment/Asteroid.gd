extends Area2D

export(int) var damage = 1
export(float) var rotation_speed = 1.0
onready var health = $Health as Health
onready var motion = $FollowTarget as FollowTarget
onready var sprite = $Sprite as Sprite

func _ready():
  health.connect("no_health", self, "queue_free")
  connect("body_entered", self, "on_hit")

func _process(delta):
  sprite.rotate(rotation_speed * delta)

func on_hit(body):
  if body.is_in_group("planet"):
    body.health.apply_damage(damage)
    queue_free()