extends Area2D
class_name Bullet

export(int) var damage = 1
onready var sprite := $Sprite as Sprite
onready var follow := $FollowTarget as FollowTarget

func _ready():
  connect("area_entered", self, "on_hit")

func on_hit(body):
  if body == follow.target:
    follow.target.health.apply_damage(damage)
    queue_free()

func _process(_delta):
  sprite.set_rotation(follow.get_velocity().angle())
