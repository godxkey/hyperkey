extends Control

export(NodePath) var planet_path

onready var _planet_health_amount = find_node("PlanetHealthAmount")
onready var _planet = get_node(planet_path)

func _ready():
  var planet_health = _planet.get_node("Health")
  planet_health.connect("health_changed", self, "set_planet_health")
  set_planet_health(planet_health.hit_points)

func set_planet_health(value:int):
  _planet_health_amount.text = String(value)
