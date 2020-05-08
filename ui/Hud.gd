extends Control

export(NodePath) var planet_path
export(NodePath) var typist_path
export(PackedScene) var score_message_scene
export(Gradient) var streak_gradient

const PENALTY_COLOR = Color("ff5e5e")

var min_streak_to_display:int = 5
var high_streak_limit = 200
var silver_streak_limit = 400
var gold_streak_limit = 8000

# UI components
onready var _accuracy_stat = find_node("Accuracy")
onready var _health_stat = find_node("Health")
onready var _score_stat = find_node("Score")
onready var _streak_stat = find_node("Streak")
onready var _streak_label = find_node("StreakLabel")
onready var _streak_high_field = find_node("StreakHigh")

# World components
onready var _planet = get_node(planet_path)
onready var _typist = get_node(typist_path)

var _last_streak:int = 0
var _streak_high:int = 0

func _ready():
  var planet_health = _planet.get_node("Health")
  planet_health.connect("health_changed", self, "set_planet_health")
  set_planet_health(planet_health.hit_points)

  _typist.connect("keyhits_stat_changed", self, "set_accuracy_percent")
  _typist.connect("key_missed", self, "play_reduced_accuracy_effect")
  _typist.connect("streak_changed", self, "update_streak")

  GameEvent.connect("score_changed", self, "update_score")

func set_planet_health(value:int):
  _health_stat.text = String(value)

func set_accuracy_percent(hits:int, total:int):
  var percent = (hits / total as float) * 100
  _accuracy_stat.text = String(percent as int) + " %"

func update_score(score:int):
  _score_stat.text = String(score)

func play_reduced_accuracy_effect():
  var tween = _accuracy_stat.get_node("Tween")
  tween.interpolate_property(
    _accuracy_stat,
    "modulate",
    PENALTY_COLOR,
    Color.white,
    0.3,
    Tween.TRANS_QUART,
    Tween.EASE_IN)
  tween.interpolate_property(
    _accuracy_stat,
    "rect_scale",
    Vector2.ONE * 1.5,
    Vector2.ONE,
    0.2,
    Tween.TRANS_QUAD,
    Tween.EASE_OUT)
  tween.start()

func update_streak(streak:int):
  var is_above_min = streak > min_streak_to_display
  _streak_stat.visible = is_above_min
  _streak_label.visible = is_above_min

  if is_above_min:
    var color = streak_color(streak)
    _streak_stat.text = String(streak)
    _streak_stat.modulate = color
    _streak_label.modulate = color

    _streak_high = max(_streak_high, streak) as int
    _streak_high_field.text = String(_streak_high)

    var tween = _streak_stat.get_node("Tween")
    tween.interpolate_property(
      _streak_stat,
      "rect_scale",
      Vector2.ONE * 1.5,
      Vector2.ONE,
      0.2,
      Tween.TRANS_QUAD,
      Tween.EASE_IN)
    tween.start()

  # Streak was reset, show the last streak value
  if streak == 0 and _last_streak > min_streak_to_display:
    _display_last_streak()
  _last_streak = streak

func _display_last_streak():
  var streak_message = score_message_scene.instance()
  streak_message.position = _streak_stat.rect_position

  var to_view_center = _streak_stat.rect_position.direction_to(get_viewport_rect().size)
  streak_message.move_angle = to_view_center.angle()

  streak_message.score_prefix = "x"
  streak_message.positive_score_color = streak_color(_last_streak)
  streak_message.scale = Vector2.ONE * lerp(1.0, 1.5, _last_streak / high_streak_limit as float)
  streak_message.set_displayed_score(_last_streak, 0)
  add_child(streak_message)

func streak_color(streak:int) -> Color:
  if streak > gold_streak_limit:
    return Color.gold
  elif streak > silver_streak_limit:
    return Color.silver
  else:
    return streak_gradient.interpolate(streak / high_streak_limit as float)
