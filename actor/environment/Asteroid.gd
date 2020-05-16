extends BaseActor

func _ready():
  health.connect("critical_hit", self, "_kill_random_subasteroid")
  health.connect("no_health", self, "on_killed")
  var res = connect("body_entered", self, "on_hit_body")
  assert(res == OK)

# Killed means it was destroyed by bullets, not by crashing into the planet.
func on_killed():
  GameEvent.play_impact_camera_shake()
  Sound.play("Break")
  Effect.play_explode_break(global_position)

func on_hit_body(body):
  if body.is_in_group("planet"):
    $Damage.apply_damage(body)
    Effect.play_ground_explosion(global_position)
    GameEvent.play_strong_impact_camera_shake()
    queue_free()

func _kill_random_subasteroid():
  var subcount = sprite.get_child_count()
  if subcount > 0:
    var child = sprite.get_child(randi() % subcount)
    GameEvent.play_impact_camera_shake()
    Sound.play("Break")
    Effect.play_explode_break(child.global_position)
    child.queue_free()
