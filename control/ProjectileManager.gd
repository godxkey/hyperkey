extends Node2D

const BULLET_RESOURCE = preload("res://actor/projectile/Bullet.tscn")

func spawn_projectile(location:Vector2, target:Node2D) -> Node2D:
  var projectile = BULLET_RESOURCE.instance()
  add_child(projectile)

  projectile.global_position = location

  var angle = rand_range(-1.0, 1.0)
  var cast_force = location.direction_to(target.position.rotated(angle))
  var follow = projectile.get_node("FollowTarget")
  follow.target = target
  follow.acceleration = 1000.0
  follow.apply_force(cast_force * 5000.0)

  projectile.connect("target_hit", self, "_on_target_hit")
  Sound.play("Shot")
  return projectile

func _on_target_hit(target):
  _change_rotation_speed(target)

func _change_rotation_speed(target):
  var rotator = target.get_node_or_null("Rotator")
  if rotator:
    rotator.speed += sign(rotator.speed) * 1.5
    if randf() < 0.1:
      rotator.speed = 1.0
    if randf() < 0.1:
      rotator.speed *= -1.0
