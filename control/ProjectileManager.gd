extends Node

export(PackedScene) var hit_explosion

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
  projectile.connect("target_hit", self, "play_explosion")
  projectile.connect("tree_exiting", _default_hit_player, "play")
  projectile.connect(
    "tree_exiting",
    self,
    "prepare_bullet_trail_for_removal",
    [projectile],
    CONNECT_ONESHOT)
  projectile.get_node("BulletTrail").preprocess = rand_range(1, 10)
  return projectile

func prepare_bullet_trail_for_removal(projectile):
  var trail = projectile.get_node("BulletTrail")
  projectile.remove_child(trail)
  add_child(trail)
  var timer = trail.get_node("Timer")
  timer.wait_time = trail.lifetime
  timer.connect("timeout", trail, "queue_free")
  timer.start()
  trail.emitting = false

func play_explosion(position:Vector2, rotation:float):
  var explosion = hit_explosion.instance()
  explosion.position = position
  explosion.rotation = rotation + PI # Go against projectile direciton
  add_child(explosion)
  explosion.get_node("Timer").connect("timeout", explosion, "queue_free")
  explosion.emitting = true
