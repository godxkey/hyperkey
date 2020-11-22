extends Spawner
class_name TextSpawner, "res://icons/text_icon.png"

enum SizeFlags{TINY=1, SHORT=2, MEDIUM=4, LONG=8}

# Specify what words sizes the spawner should use.
export(int, FLAGS, "Tiny", "Short", "Medium", "Long") var sizes = SizeFlags.MEDIUM

# Specifies if the spawner should generate text with multiple words.
export(bool) var multiwords = false
export(int) var min_word_count = 2
export(int) var max_word_count = 4

export var attack_node_path: NodePath

const LABEL_SCENE:PackedScene = preload("res://ui/TypistLabel.tscn")

signal text_spawned(text, spawned)

# Spawns text targets. Null is returned if it could not be created.
func _spawn() -> Node2D:
  var attack_node = get_node_or_null(attack_node_path)
  if attack_node:
    var text = _generate_text()
    if text:
      var s = spawn_scene.instance()
      add_child(s)
      s.set_stats(text)
      s.follow(attack_node)
      _attach_label(s, text)
      emit_signal("text_spawned", text, s)
      return s
  return null

func _attach_label(target, text):
  # Z node required by Text Label so it can render above other objects.
  var z_node = Position2D.new()
  add_child(z_node)

  var label = LABEL_SCENE.instance()
  z_node.add_child(label)
  label.display_text = text

  target.get_node("LabelRemote").remote_path = z_node.get_path()
  target.label_path = label.get_path()

  # If target dies, so does label
  target.connect("tree_exiting", z_node, "queue_free")

func _generate_text() -> TypistText:
  var count = _random_word_count() if multiwords else 1
  return Game.text_gen().random_sized_word_list(_word_sizes(), count)

func _random_word_count() -> int:
  var r = (max_word_count - min_word_count) + 1
  return randi() % r + min_word_count

func _word_sizes() -> PoolIntArray:
  # Stores the size selections available from the size flags.
  var picks = PoolIntArray()
  if sizes & SizeFlags.TINY: picks.append(WordDictionary.WordSize.TINY)
  if sizes & SizeFlags.SHORT: picks.append(WordDictionary.WordSize.SHORT)
  if sizes & SizeFlags.MEDIUM: picks.append(WordDictionary.WordSize.MEDIUM)
  if sizes & SizeFlags.LONG: picks.append(WordDictionary.WordSize.LONG)
  return picks