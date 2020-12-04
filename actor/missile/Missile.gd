extends Target

# export var death_effect:PackedScene

func _on_killed():
  Sound.play("Break")
  # Effect.play_effect(death_effect, global_position)
  Effect.release_particles($SmokeTrail)

func _on_hit_body(body):
  # Apply damage to body and then self kill.
  $Damage.apply_damage(body)
  $Health.instakill()

func set_attack_target_path(path):
  $LinearFollow.target_path = path
