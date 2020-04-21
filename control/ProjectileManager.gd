extends Node

const BULLET_RESOURCE = preload("res://actor/projectile/Bullet.tscn")
onready var _default_shot_player = $DefaultShotPlayer
onready var _default_hit_player = $DefaultHitPlayer

func spawn_projectile(location:Vector2, target:Node2D) -> Node2D:
  var projectile = BULLET_RESOURCE.instance()
  add_child(projectile)
  projectile.position = location
  projectile.motion.start_moving_along(location.direction_to(target.position))
  projectile.motion.target = target
  _default_shot_player.play()
  projectile.connect("tree_exiting", _default_hit_player, "play")
  return projectile
