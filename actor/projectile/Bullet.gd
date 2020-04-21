extends Area2D
class_name Bullet

export(int) var damage = 1
export(float) var hit_power = 0.5
onready var sprite := $Sprite as Sprite
onready var motion := $FollowTarget as FollowTarget

var _rng = RandomNumberGenerator.new()

func _ready():
  _rng.randomize()
  connect("area_entered", self, "on_hit")

func on_hit(body):
  var target = motion.target
  if body == target:
    target.health.apply_damage(damage)
    var to_body = position.direction_to(body.position)
    var speed = body.motion.get_velocity().length()
    var knockback_speed = max(speed * hit_power, 50)
    var knockback_force = to_body * knockback_speed
    var angle = deg2rad(_rng.randf_range(-10, 10))
    target.motion.set_velocity(knockback_force.rotated(angle))
    queue_free()

func _process(_delta):
  sprite.set_rotation(motion.get_velocity().angle())
