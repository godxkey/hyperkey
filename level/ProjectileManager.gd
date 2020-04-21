extends Node

const BULLET_RESOURCE = preload("res://actor/projectile/Bullet.tscn")

func spawn_projectile(location:Vector2, target:Node2D) -> Node2D:
  var projectile = BULLET_RESOURCE.instance()
  add_child(projectile)
  projectile.position = location
  projectile.motion.start_moving_along(location.direction_to(target.position))
  projectile.motion.target = target
  return projectile