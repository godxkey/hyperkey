extends BaseTarget

export var death_effect:PackedScene

func _on_killed():
  Sound.play("Break")
  Effect.play_impact_camera_shake()
  Effect.play_effect(death_effect, global_position)
  Effect.release_particles($SmokeTrail)

func _on_hit_body(body):
  if body.is_in_group("destroyable"):
    # Apply damage to body and then self kill.
    $Damage.apply_damage(body)
    $Health.instakill()
