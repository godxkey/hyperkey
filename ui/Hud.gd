extends Control

export(NodePath) var planet_path
export(NodePath) var typist_path

export(Color) var accuracy_penality_color

# UI components
onready var _accuracy_stat = find_node("Accuracy")
onready var _planet_health_amount = find_node("PlanetHealthAmount")
onready var _hits_stat = find_node("Hits")

# World components
onready var _planet = get_node(planet_path)
onready var _typist = get_node(typist_path)

func _ready():
  var planet_health = _planet.get_node("Health")
  planet_health.connect("health_changed", self, "set_planet_health")
  set_planet_health(planet_health.hit_points)

  _typist.connect("keyhits_stat_changed", self, "set_accuracy_percent")
  _typist.connect("key_missed", self, "play_reduced_accuracy_effect")

func set_planet_health(value:int):
  _planet_health_amount.text = String(value)

func set_accuracy_percent(hits:int, total:int):
  var percent = (hits / total as float) * 100
  _accuracy_stat.text = String(percent as int)
  _hits_stat.text = String(hits) + " - " + String(total)

func play_reduced_accuracy_effect():
  var color_tween = _accuracy_stat.get_node("ColorTween")
  var size_tween = _accuracy_stat.get_node("SizeTween")

  color_tween.interpolate_property(
    _accuracy_stat,
    "modulate",
    accuracy_penality_color,
    Color.white,
    0.3,
    Tween.TRANS_QUAD,
    Tween.EASE_OUT)

  size_tween.interpolate_property(
    _accuracy_stat,
    "rect_scale",
    Vector2.ONE * 1.5,
    Vector2.ONE,
    0.2,
    Tween.TRANS_QUAD,
    Tween.EASE_OUT)

  color_tween.start()
  size_tween.start()
