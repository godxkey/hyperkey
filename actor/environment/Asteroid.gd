extends Area2D

export(int) var damage = 1
export(float) var rotation_speed = 1.0
onready var health = $Health as Health
onready var sprite = $Sprite as Sprite

func _ready():
  health.connect("no_health", self, "on_killed")
  connect("body_entered", self, "on_hit_body")

# Killed means it was destroyed by bullets, not by crashing into the planet.
func on_killed():
  GameEvent.play_impact_camera_effect()
  Sound.play_break()
  Effect.play_explode_break(global_position)
  queue_free()

func _process(delta):
  sprite.rotate(rotation_speed * delta)

func on_hit_body(body):
  if body.is_in_group("planet"):
    body.health.apply_damage(damage)
    queue_free()