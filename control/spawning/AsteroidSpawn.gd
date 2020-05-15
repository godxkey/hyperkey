extends Spawner

export(Array, Texture) var textures

const SCENE = preload("res://actor/environment/Asteroid.tscn")

func spawn(_tick) -> Node2D:
  var asteroid = SCENE.instance()
  asteroid.get_node("Sprite").texture = _random_texture()
  return asteroid

func _random_texture():
  return textures[randi() % textures.size()]
