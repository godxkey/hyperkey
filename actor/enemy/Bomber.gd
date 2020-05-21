extends BaseActor

func _ready():
  health.connect("no_health", self, "on_killed")

func _process(_delta):
  var to_center = position.direction_to(GameEvent.view_center())
  var move_direction = to_center.project(Vector2.RIGHT)
  sprite.scale.x = 1.0 if move_direction.dot(Vector2.RIGHT) > 0 else -1.0
  motion.start_moving_along(move_direction)

# Killed means it was destroyed by bullets, not by crashing into the planet.
func on_killed():
  GameEvent.play_impact_camera_shake()
  Sound.play("Break")
  Effect.play_explode_break(global_position)

func _on_hit_body(body):
  if body.is_in_group("planet"):
    $Damage.apply_damage(body)
    Effect.play_ground_explosion(global_position)
    GameEvent.play_strong_impact_camera_shake()
    queue_free()