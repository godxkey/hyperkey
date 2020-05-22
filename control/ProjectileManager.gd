extends Node

const BULLET_RESOURCE = preload("res://actor/projectile/Bullet.tscn")

func spawn_projectile(location:Vector2, target:Node2D) -> Node2D:
  var projectile = BULLET_RESOURCE.instance()
  add_child(projectile)
  projectile.position = location

  # Linear start trajectory
  # projectile.motion.start_moving_along(location.direction_to(target.position))

  # Randomize start trajectory slightly.
  # Makes projectiles not follow directly behind another
  var angle = rand_range(-1.0, 1.0)
  var cast_force = location.direction_to(target.position.rotated(angle))
  projectile.motion.acceleration = 1000.0
  projectile.motion.apply_force(cast_force * 5000.0)

  projectile.motion.target = target
  projectile.connect("target_hit", self, "play_explosion")
  projectile.connect(
    "tree_exiting",
    self,
    "prepare_bullet_trail_for_removal",
    [projectile],
    CONNECT_ONESHOT)
  # Prevent repetitive trails by preprocessing the particles.
  projectile.get_node("BulletTrail").preprocess = rand_range(1, 10)
  Sound.play("Shot")
  return projectile

func prepare_bullet_trail_for_removal(projectile):
  var trail = projectile.get_node("BulletTrail")
  Effect.kill_effect_after_done(trail)

func play_explosion(position:Vector2, impact_rotation:float):
  Sound.play("Hit")
  Effect.play_explosion(position, impact_rotation)
  Effect.play_hit_break(position, impact_rotation)

