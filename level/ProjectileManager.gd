extends Node

const BULLET_RESOURCE = preload("res://actor/projectile/Bullet.tscn")

func spawn_projectile(location:Vector2, direction_angle:float):
  var projectile = BULLET_RESOURCE.instance()
  add_child(projectile)
  projectile.set_projectile_direction(direction_angle)
  projectile.position = location