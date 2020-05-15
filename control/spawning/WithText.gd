extends Spawner
class_name WithTextSpawner, "res://icons/text_icon.png"

const LABEL_SCENE = preload("res://ui/TypistLabel.tscn")

func spawn(tick:SpawnTick) -> Node2D:
  var typist = tick.blackboard["Typist"]
  var text = typist.generate_text()
  if text:
    var s = spawner.spawn(tick)
    if s:
      _setup_label_for_target(text, s)
      _set_text_target_health(text, s)
      _set_text_target_motion(text, s)
      typist.add_text_target(text, s)
    return s
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
