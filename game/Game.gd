extends Node2D

export var main_dictionary:Resource
export var typist_path:NodePath
export var player_path:NodePath

onready var text_gen := TextGenerator.new()

func _ready():
  randomize()
  main_dictionary.load_words()
  text_gen.text_server.word_dictionary = main_dictionary

  var typist = get_node(typist_path)

  text_gen.text_server.condition = funcref(typist, "is_letter_unused")

  for spawner in get_tree().get_nodes_in_group("spawner"):
    spawner.text_gen = text_gen
    spawner.attack_node_path = get_node(player_path).get_path()
    var res = spawner.connect("text_spawned", typist, "add_text_target")
    assert(res == OK)
