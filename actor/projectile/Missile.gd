extends BaseActor

func _ready():
  health.connect("no_health", self, "on_killed")

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

func _detach_smoke():
  Effect.kill_effect_after_done($Sprite/SmokeTrail)

func _process(_delta):
  sprite.set_rotation(motion.get_velocity().angle())