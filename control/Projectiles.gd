extends Node2D

func spawn(resource, location:Vector2, target:Node2D) -> Node2D:
  var projectile = resource.instance()
  add_child(projectile)

  projectile.global_position = location

  var angle = rand_range(-1.0, 1.0)
  var cast_force = location.direction_to(target.position.rotated(angle))
  var follow = projectile.get_node("FollowTarget")
  follow.target = target
  follow.acceleration = 1000.0
  follow.apply_force(cast_force * 5000.0)
  Sound.play("Shot")
  return projectile

