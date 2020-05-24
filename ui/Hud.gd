extends Control

export(NodePath) var planet_path
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
onready var _currency_total = find_node("CurrencyTotal")
onready var _shield = find_node("Shield")
onready var _attractor = find_node("Attractor")
onready var _stream = find_node("Stream")
onready var _ability_status_bar = find_node("AbilityStatusBar")

# World components
# TODO: Replace this with stats or score.
# Health handling in HUD should be abstracted from Planet
onready var _planet = get_node(planet_path)

func _ready():
  var planet_health = _planet.get_node("Health")
  planet_health.connect("health_changed", self, "set_planet_health")
  set_planet_health(planet_health.hit_points)

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

  res = Abilities.connect("currency_changed", self, "set_currency")
  assert(res == OK)

  res = Abilities.connect("ability_activated", self, "set_ability_timer")
  assert(res == OK)

  _set_ability_display_values()

  _streak_label.hide()
  _streak_stat.hide()

func set_planet_health(value:int):
  _health_stat.text = String(value)

func set_accuracy_percent(percent:int):
  _accuracy_stat.text = "%s %%" % percent

func set_score(score:int):
  _score_stat.text = String(score)
  _score_stat.get_node("ChangeEffect").start()

func set_currency(currency:int):
  _currency_total.text = "$ %s" % currency
  _currency_total.get_node("ChangeEffect").start()
  for ability in _ability_status_bar.get_children():
    ability.set_currency(currency)

func set_ability_timer(type, ability):
  match type:
    Abilities.AbilityType.SHIELD:
      _shield.tracked_ability_timer = ability.get_node("Timer")
    Abilities.AbilityType.ATTRACTOR:
      _attractor.tracked_ability_timer = ability.get_node("Timer")
    Abilities.AbilityType.STREAM:
      _stream.tracked_ability_timer = ability.get_node("Timer")

func play_decrease_accuracy_effect():
  _accuracy_stat.get_node("ChangeEffect").start()

func set_streak(streak:int):
  var is_above_min = streak > min_streak_to_display
  _streak_stat.visible = is_above_min
  _streak_label.visible = is_above_min

  if is_above_min:
    var color = streak_color(streak)
    _streak_label.modulate = color
    _streak_stat.text = String(streak)
    _streak_stat.modulate = color
    _streak_stat.get_node("ChangeEffect").start()
    _streak_high.text = String(Stats.get_streak_high())

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

# Set ability display costs and durations
func _set_ability_display_values():
  _shield.display_duration = Abilities.shield.duration
  _shield.display_cost = Abilities.shield.cost

  _attractor.display_duration = Abilities.attractor.duration
  _attractor.display_cost = Abilities.attractor.cost

  _stream.display_duration = Abilities.stream.duration
  _stream.display_cost = Abilities.stream.cost
