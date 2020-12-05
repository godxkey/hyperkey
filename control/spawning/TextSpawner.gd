extends Spawner
class_name TextSpawner

enum SizeFlags{TINY=1, SHORT=2, MEDIUM=4, LONG=8}

# Specify what words sizes the spawner should use.
export(int, FLAGS, "Tiny", "Short", "Medium", "Long") var sizes = SizeFlags.MEDIUM

# Specifies if the spawner should generate text with multiple words.
export var multiwords:bool = false
export var min_word_count:int = 2
export var max_word_count:int = 4

export var attack_target_path:NodePath

var label_layer:CanvasLayer

const LABEL_SCENE:PackedScene = preload("res://ui/TypistLabel.tscn")

var text_gen:TextGenerator

signal text_spawned(text, spawned)

# Spawns text targets. Null is returned if it could not be created.
func spawn() -> Spatial:
  if get_node_or_null(attack_target_path):
    var text = _generate_text()
    if text:
      var s = spawn_scene.instance()
      s.translation = random_spawn_location()
      add_child(s)
      s.set_stats(text)
      s.set_attack_target_path(attack_target_path)
      _attach_label(s, text)
      emit_signal("text_spawned", text, s)
      return s
  return null

func _attach_label(target, text):
  var label = LABEL_SCENE.instance()
  label.display_text = text
  label.name += text.merged_text()
  label_layer.add_child(label)
  target.label_ref = weakref(label)
  target.connect("tree_exiting", label, "queue_free")

func _generate_text() -> TypistText:
  var count = _random_word_count() if multiwords else 1
  return text_gen.random_sized_word_list(_word_sizes(), count)

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
