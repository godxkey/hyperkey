extends TextSpawner

export(Array, Texture) var textures

const SCENE = preload("res://actor/environment/Asteroid.tscn")

func _spawn_text_target(_text) -> Node2D:
  var asteroid = SCENE.instance()
  asteroid.get_node("Sprite").texture = _random_texture()
  return asteroid

func _random_texture():
  return textures[randi() % textures.size()]
