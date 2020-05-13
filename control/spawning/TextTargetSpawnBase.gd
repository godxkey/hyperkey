extends "res://addons/godot-behavior-tree-plugin/action.gd"

# Base class for all spawners that create text targets.
# Text targets are objects that the player can type to shoot.

const LABEL_SCENE = preload("res://ui/TypistLabel.tscn")

var _target_spawner_delegate = funcref(self, "_spawn")

var _current_tick:Tick = null

func tick(tick: Tick) -> int:
  var typist = tick.actor
  _current_tick = tick
  typist.create_text_target(_target_spawner_delegate)
  return OK

func _spawn(text:TypistText) -> Node2D:
  var target = spawn_target(text)
  var spawn_area = get_node_or_null("SpawnArea")
  if spawn_area:
    target.position = spawn_area.spawn_position()
  _setup_label_for_target(text, target)
  _set_text_target_health(text, target)
  _set_text_target_motion(text, target)
  add_child(target)
  return target

func _setup_label_for_target(text:TypistText, target):
  var label_root = LABEL_SCENE.instance()
  label_root.get_node("TypistLabel").display_text = text
  label_root.position.y = 30
  target.add_child(label_root)

func _set_text_target_health(text:TypistText, target):
  var health = target.get_node("Health")
  health.hit_points = text.merged_text().length()

func _set_text_target_motion(text:TypistText, target):
  # Make longer text objects slower
  var motion = target.get_node("FollowMotion")
  motion.max_speed /= text.text_list.size()
  motion.acceleration /= text.text_list.size()

  var max_speed = motion.max_speed
  var starting_speed = rand_range(0.2 * max_speed, 0.8 * max_speed)

  var attack_target:Node2D = _current_tick.blackboard.get("AttackTarget")
  if attack_target:
    motion.set_velocity(starting_speed * target.position.direction_to(attack_target.position))
    motion.target = attack_target

# Extended classes should override the following for custom behavior
func spawn_target(_text:TypistText) -> Node2D:
  return null
