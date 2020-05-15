extends Spawner
class_name TextSpawner, "res://icons/text_icon.png"

export(int, FLAGS, "Tiny", "Short", "Medium", "Long") var sizes

# The blackboard key for the attack target that spawns will follow.
export(String) var attack_target_key

const LABEL_SCENE = preload("res://ui/TypistLabel.tscn")

# Spawns text targets. Null is returned if it could not be created.
func _spawn() -> Node2D:
  var typist = blackboard.get("Typist")
  var text = typist.generate_text()
  if text:
    var s = _spawn_text_target(text)
    if s:
      _setup_label_for_target(text, s)
      _set_text_target_health(text, s)
      _set_text_target_motion(text, s)
      _set_text_target_follow(s)
      typist.add_text_target(text, s)
    return s
  return null

# Extended classes need to implement this to create the spawn with text.
func _spawn_text_target(_text:TypistText) -> Node2D:
  return null

func _setup_label_for_target(text:TypistText, target):
  var label_root = LABEL_SCENE.instance()
  label_root.get_node("TypistLabel").display_text = text
  label_root.position.y = 30
  target.add_child(label_root)

func _set_text_target_health(text:TypistText, target):
  var health = target.get_node("Health")
  health.hit_points = text.merged_text().length()

func _set_text_target_motion(text:TypistText, target):
  var motion = target.get_node("FollowTarget")
  if motion:
    motion.max_speed /= text.text_list.size()
    motion.acceleration /= text.text_list.size()

func _set_text_target_follow(target):
  if blackboard.has(attack_target_key):
    var motion = target.get_node("FollowTarget")
    var attack = blackboard[attack_target_key].get_ref()
    if motion and attack:
      motion.target = attack
      var start_speed = rand_range(0.2 * motion.max_speed, 0.8 * motion.max_speed)
      motion.set_velocity(start_speed * target.position.direction_to(attack.position))
