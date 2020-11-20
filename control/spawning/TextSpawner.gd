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
export(String) var attack_target_key

onready var typist = get_node("/root/World/Typist")

signal text_spawned(text, spawned)

# Spawns text targets. Null is returned if it could not be created.
func _spawn() -> Node2D:
  if typist.blackboard[attack_target_key].get_ref():
    var text = _generate_text()
    if text:
      var s = _spawn_text_target(text)
      if s:
        s.set_text(text)
        _set_text_target_follow(s)
        emit_signal("text_spawned", text, s)
        typist.add_text_target(text, s)
      return s
  return null

# Extended classes need to implement this to create the spawn with text.
func _spawn_text_target(_text:TypistText) -> Node2D:
  return spawn_scene.instance()

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

func _set_text_target_follow(target):
  if typist.blackboard.has(attack_target_key):
    var motion = target.get_node("FollowTarget")
    var attack = typist.blackboard[attack_target_key].get_ref()
    if motion and attack:
      motion.target = attack
      var start_speed = rand_range(0.2 * motion.max_speed, 0.8 * motion.max_speed)
      motion.set_velocity(start_speed * target.position.direction_to(attack.position))
