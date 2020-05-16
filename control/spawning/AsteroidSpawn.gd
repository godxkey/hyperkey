extends TextSpawner

export(float) var cluster_offset = 20.0
export(Array, Texture) var textures

func _spawn_text_target(text) -> Node2D:
  var asteroid = spawn_scene.instance()
  asteroid.get_node("Damage").damage_points = text.merged_text().length()
  asteroid.get_node("Sprite").texture = _random_texture()
  _add_cluster(asteroid, text.text_list.size())
  return asteroid

func _add_cluster(asteroid, count:int):
  # Substract one since the first is used as the main, central asteroid
  for _i in (count - 1):
    var sub = Sprite.new()
    sub.texture = _random_texture()
    sub.position = _random_offset()
    sub.rotation = _random_angle()
    asteroid.get_node("Sprite").add_child(sub)

func _random_offset() -> Vector2:
  var x = rand_range(-cluster_offset, cluster_offset)
  var y = rand_range(-cluster_offset, cluster_offset)
  return Vector2(x, y);

func _random_angle() -> float:
  return randf() * TAU

func _random_texture() -> Texture:
  return textures[randi() % textures.size()]
