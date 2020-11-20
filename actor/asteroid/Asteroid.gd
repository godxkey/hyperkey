extends BaseTarget

export var death_effect:PackedScene
export var hit_effect:PackedScene

export(float) var cluster_offset = 20.0
export(Array, Texture) var textures

func _on_text_set(text:TypistText):
  $Sprite.texture = _random_texture()
  _add_cluster(text.text_list.size())

func _add_cluster(count:int):
  # Substract one since the first is used as the main, central asteroid
  for _i in (count - 1):
    var sub = Sprite.new()
    sub.texture = _random_texture()
    sub.position = _random_offset()
    sub.rotation = _random_angle()
    $Sprite.add_child(sub)

func _random_offset() -> Vector2:
  var x = rand_range(-cluster_offset, cluster_offset)
  var y = rand_range(-cluster_offset, cluster_offset)
  return Vector2(x, y);

static func _random_angle() -> float:
  return randf() * TAU

func _random_texture() -> Texture:
  return textures[randi() % textures.size()]

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
