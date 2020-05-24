extends Node

enum AbilityType{
  SHIELD,
  ATTRACTOR,
  STREAM,
  # CANON,
  # LASER,
  # TURRET,
  # AUTO
}

# Ability description resources which contain information such as cost and duration.
export(Resource) var shield
export(Resource) var attractor
export(Resource) var stream
export(bool) var no_cost = false

# Maps the enumeration to interface with the ability resource to simplify direct access.
onready var abilities := {
  AbilityType.SHIELD : shield,
  AbilityType.ATTRACTOR : attractor,
  AbilityType.STREAM : stream,
}

var _active_abilities := {
  AbilityType.SHIELD : false,
  AbilityType.ATTRACTOR : false,
  AbilityType.STREAM : false
}

var _total_currency:int = 0

signal currency_changed(currency)
signal ability_activated(type, object)
signal ability_inactive(type)

func _ready():
  var res = Score.connect("scored_target", self, "add_currency_from_score")
  assert(res == OK)

func add_currency_from_score(target_score):
  var gained = _typing_score_currency(target_score.typing_score)
  gained += _speed_bonus_currency(target_score.speed_bonus)
  gained += _super_bonus_currency(target_score.super_bonus)
  if gained > 0:
    _total_currency += gained
    emit_signal("currency_changed", _total_currency)

func cast_ability(type:int, parameters:Dictionary):
  if _can_use_ability(type):
    _use_up_currency(type)
    var ability = abilities[type].scene.instance()
    ability.duration = abilities[type].duration
    ability.connect("tree_exiting", self, "_set_ability_inactive", [type], CONNECT_ONESHOT)
    ability.position = parameters["position"]
    add_child(ability)

    _active_abilities[type] = true
    emit_signal("ability_activated", type, ability)
  else:
    Sound.play("Mistype")

func is_ability_active(type:int) -> bool:
  return false if not _active_abilities.has(type) else _active_abilities[type]

func _can_use_ability(type:int) -> bool:
  var is_inactive = not is_ability_active(type)
  var cost = abilities[type].cost
  return is_inactive and (no_cost or _total_currency >= cost)

func _use_up_currency(type:int) -> void:
  if not no_cost:
    _total_currency -= abilities[type].cost
    emit_signal("currency_changed", _total_currency)

func _set_ability_inactive(type:int):
  _active_abilities[type] = false
  emit_signal("ability_inactive", type)

func _typing_score_currency(score:int) -> int:
  if score < 200:
    return 0
  if score < 400:
    return 1
  return 2

func _speed_bonus_currency(score:int) -> int:
  return 1 if score > 0 else 0

func _super_bonus_currency(score:int) -> int:
  return 2 if score > 0 else 0
