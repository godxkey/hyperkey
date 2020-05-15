extends Spawner

export(float) var cluster_offset = 20.0
export(Array, Texture) var textures

const SCENE = preload("res://actor/environment/AsteroidCluster.tscn")

func spawn(_tick) -> Node2D:
  var cluster = SCENE.instance()
  # _add_cluster(cluster, text.text_list.size())
  return cluster

func _add_cluster(cluster, count:int):
  for _i in range(count):
    var asteroid = Sprite.new()
    asteroid.texture = _random_texture()
    asteroid.position = _random_offset()
    asteroid.rotation = _random_angle()
    cluster.get_node("ClusterRoot").add_child(asteroid)

func _random_offset() -> Vector2:
  var x = rand_range(-cluster_offset, cluster_offset)
  var y = rand_range(-cluster_offset, cluster_offset)
  return Vector2(x, y);

func _random_angle() -> float:
  return randf() * TAU

func _random_texture():
  return textures[randi() % textures.size()]