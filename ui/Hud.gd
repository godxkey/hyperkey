extends Control

export(NodePath) var typist_path
export(PackedScene) var score_info_scene
export(PackedScene) var text_info_scene
export(Gradient) var streak_gradient
export(int) var min_streak_to_display = 5

const PENALTY_COLOR = Color("ff5e5e")

# UI components
onready var _accuracy_stat = find_node("Accuracy")
onready var _health_stat = find_node("Health")
onready var _score_stat = find_node("Score")
onready var _streak_stat = find_node("Streak")
onready var _streak_label = find_node("StreakLabel")
onready var _streak_high = find_node("StreakHigh")

func _ready():
  var res = Stats.connect("accuracy_changed", self, "set_accuracy_percent")
  assert(res == OK)

  res = Stats.connect("key_missed", self, "play_decrease_accuracy_effect")
  assert(res == OK)

  res = Stats.connect("key_missed_tracked", self, "show_mistyped_letter")
  assert(res == OK)

  res = Stats.connect("streak_changed", self, "set_streak")
  assert(res == OK)

  res = Score.connect("score_changed", self, "set_score")
  assert(res == OK)

  res = Score.connect("scored_target", self, "show_target_score")
  assert(res == OK)

func set_accuracy_percent(percent:int):
  _accuracy_stat.text = "%s %%" % percent

func set_score(score:int):
  _score_stat.text = String(score)
  _score_stat.get_node("ChangeEffect").start()

func play_decrease_accuracy_effect():
  _accuracy_stat.get_node("ChangeEffect").start()

func set_streak(streak:int):
  var is_above_min = streak > min_streak_to_display

  if is_above_min:
    var color = streak_color(streak)
    _streak_label.modulate = color
    _streak_stat.text = String(streak)
    _streak_stat.modulate = color
    _streak_stat.get_node("ChangeEffect").start()
    _streak_high.text = String(Stats.get_streak_high())
  else:
    # Not high enough, just show dash to reprsent irrelevant.
    _streak_label.modulate = Color.white
    _streak_stat.modulate = Color.white
    _streak_stat.text = "-"

  # Streak was reset, show the last streak value
  if streak == 0 and Stats.get_last_streak() > min_streak_to_display:
    _show_last_streak(Stats.get_last_streak())

func show_target_score(score):
  var info = score_info_scene.instance()
  info.score = score.typing_score
  info.bonus_score = score.speed_bonus
  info.rect_position = score.position
  info.move_angle = to_view_center_angle(score.position)

  add_child(info)
  _show_super_bonus(score.super_bonus, score.position)

  if score.speed_bonus > 0:
    Sound.play("SpeedBonus")

func _show_super_bonus(super_bonus:int, position:Vector2):
  if super_bonus > 0:
    var info = score_info_scene.instance()
    info.positive_score_color = Color.gold
    info.rect_position = position
    info.move_angle = to_view_center_angle(position) + 0.5
    info.move_distance = 140
    info.score = super_bonus
    add_child(info)
    Sound.play("SuperBonus")

func _show_last_streak(streak:int):
  var info = score_info_scene.instance()
  info.rect_position = _streak_stat.rect_global_position
  info.move_angle = to_view_center_angle(_streak_stat.rect_global_position)
  info.score_prefix = "x"
  info.positive_score_color = streak_color(streak)
  info.rect_scale = Vector2.ONE * lerp(1.0, 1.5, streak / Score.high_streak_limit as float)
  info.score = streak
  add_child(info)

func show_mistyped_letter(letter:String, position:Vector2):
  var info = text_info_scene.instance()
  info.rect_position = position
  info.move_angle = (-PI/2) + rand_range(-0.5, 0.5)
  info.move_distance = 50.0
  info.display_time = 0.8
  var label = info.get_node("Label")
  label.modulate = PENALTY_COLOR
  label.text = letter
  add_child(info)

func to_view_center_angle(position:Vector2):
  var half = get_viewport_rect().end / 2.0
  return position.direction_to(half).angle()

func streak_color(streak:int) -> Color:
  if streak > Score.gold_streak_limit:
    return Color.gold
  elif streak > Score.silver_streak_limit:
    return Color.silver
  else:
    return streak_gradient.interpolate(streak / Score.high_streak_limit as float)
