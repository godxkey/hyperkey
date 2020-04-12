extends Area2D

export(float) var speed = 1000.0

onready var sprite := $Sprite as Sprite
onready var timer := $Timer as Timer

var _velocity := Vector2()

func _ready():
  connect("body_entered", self, "on_hit")
  _velocity = Vector2.RIGHT * speed
  timer.connect("timeout", self, "queue_free")
  timer.one_shot = true
  timer.wait_time = 1.0
  timer.start()

func on_hit(body):
  if body.is_in_group("Enemy"):
    queue_free()

func set_projectile_direction(bullet_angle:float):
  _velocity = Vector2.RIGHT.rotated(bullet_angle) * speed
  if sprite:
    sprite.set_rotation(bullet_angle)

func _physics_process(delta):
  translate(_velocity * delta)
