tool
extends Node2D
class_name Spawner

export(PackedScene) var spawn_type
export(NodePath) var planet_path
export(Rect2) var spawn_area = Rect2(0, 0, 400, 200) setget _set_spawn_area

const LABEL_SCENE = preload("res://ui/TypistLabel.tscn")

onready var timer = $Timer as Timer
onready var _planet = get_node(planet_path)

var _debug_spawn_area_color = Color(0.8, 0.4, 0.0, 0.3)

func spawn(packed_scene) -> Node2D:
  var x = rand_range(spawn_area.position.x, spawn_area.end.x)
  var y = rand_range(spawn_area.position.y, spawn_area.end.y)
  var spawn_object = packed_scene.instance()

  spawn_object.position = transform.xform(Vector2(x, y))
  return spawn_object

func _set_spawn_area(value):
  spawn_area = value
  if Engine.editor_hint:
    update()

func _draw():
  if Engine.editor_hint:
    draw_rect(spawn_area, _debug_spawn_area_color)

func spawn_text_target(text:TypistText) -> Node2D:
  var target = spawn(spawn_type)
  _setup_label_for_target(text, target)
  _set_text_target_health(text, target)
  _set_text_target_motion(text, target)
  return target

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
  motion.set_velocity(starting_speed * target.position.direction_to(_planet.position))
  motion.target = _planet

func _setup_label_for_target(text:TypistText, target):
  var label = LABEL_SCENE.instance()
  label.display_text = text
  target.add_child(_create_zcontrol_for_label(label))

func _create_zcontrol_for_label(label) -> Node2D:
  var zcontrol = Node2D.new()
  zcontrol.name = "ZControl"
  zcontrol.z_index = 1000
  zcontrol.position.y = 30.0
  zcontrol.add_child(label)
  return zcontrol
