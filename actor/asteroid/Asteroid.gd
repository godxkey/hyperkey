extends BaseActor

export var death_effect:PackedScene
export var hit_effect:PackedScene

func _on_killed():
  GameEvent.play_impact_camera_shake()
  Sound.play("Break")
  Effect.play_effect(death_effect, global_position)

func _on_damage_taken(health):
  if health > 0:
    Effect.play_effect(hit_effect, global_position)

func _on_hit_body(body):
  # Apply damage to body and self kill.
  if body.is_in_group("destroyable"):
    $Damage.apply_damage(body)
    health.instakill()

func _kill_subasteroid():
  var subcount = sprite.get_child_count()
  if subcount > 0:
    var child = sprite.get_child(randi() % subcount)
    GameEvent.play_impact_camera_shake()
    Sound.play("Break")
    Effect.play_effect(death_effect, child.global_position)
    child.queue_free()
