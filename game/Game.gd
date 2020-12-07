extends Spatial

export var main_dictionary:Resource
export var typist_path:NodePath
export var player_path:NodePath

onready var text_gen := TextGenerator.new()

func _ready():
  randomize()
  main_dictionary.load_words()
  text_gen.text_server.word_dictionary = main_dictionary

  var typist = get_node(typist_path)
  var player = get_node(player_path)

  text_gen.text_server.condition = funcref(typist, "is_letter_unused")

  for spawner in get_tree().get_nodes_in_group("spawner"):
    spawner.label_layer = $TextTargetsLayer
    spawner.text_gen = text_gen
    spawner.attack_target_path = player.get_path()
    var res = spawner.connect("text_spawned", typist, "add_text_target")
    assert(res == OK)

func _set_target_as_active(target_path:NodePath):
  var target = get_node_or_null(target_path)
  if target:
    _move_active_label(target)

func _move_active_label(target):
  var label = target.label_ref.get_ref()
  assert(label)
  label.get_parent().remove_child(label)
  $ActiveTextTargetLayer.add_child(label)
