extends BaseActor

func _on_killed():
  GameEvent.play_impact_camera_shake()
  Sound.play("Break")
  Effect.play_explode_break(global_position)

func _on_hit_body(body):
  if body.is_in_group("destroyable"):
    # Apply damage to body and then self kill.
    $Damage.apply_damage(body)
    health.instakill()

func _detach_smoke():
  Effect.kill_effect_after_done($Sprite/SmokeTrail)

func _process(_delta):
  sprite.set_rotation(motion.get_velocity().angle())
