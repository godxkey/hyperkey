extends Node

func spawn_projectile(resource, location:Vector2, direction_angle:float):
  var projectile = resource.instance()
  add_child(projectile)
  projectile.set_projectile_direction(direction_angle)
  projectile.position = location