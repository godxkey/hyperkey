extends Spawner
class_name TextSpawner, "res://icons/text_icon.png"

enum SizeFlags{TINY=1, SHORT=2, MEDIUM=4, LONG=8}

# Specify what words sizes the spawner should use.
export(int, FLAGS, "Tiny", "Short", "Medium", "Long") var sizes = SizeFlags.MEDIUM

# Specifies if the spawner should generate text with multiple words.
export(bool) var multiwords = false
export(int) var min_word_count = 2
export(int) var max_word_count = 4

# The blackboard key for the attack target that spawns will follow.
export(String) var attack_target_key = "Player"

onready var typist = get_node("/root/World/Typist")

signal text_spawned(text, spawned)

# Spawns text targets. Null is returned if it could not be created.
func _spawn() -> Node2D:
  if has_attack_target_set():
    var text = _generate_text()
    if text:
      var s = spawn_scene.instance()
      s.set_text(text)
      s.follow(attack_target())
      emit_signal("text_spawned", text, s)
      typist.add_text_target(text, s)
      return s
  return null

func _generate_text() -> TypistText:
  var count = _random_word_count() if multiwords else 1
  return typist.text_gen.random_sized_word_list(_word_sizes(), count)

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

func has_attack_target_set():
  var bb = typist.blackboard
  return bb.has(attack_target_key) && bb[attack_target_key].get_ref()

func attack_target():
  return typist.blackboard[attack_target_key].get_ref()
