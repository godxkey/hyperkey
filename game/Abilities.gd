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

var _ability_scenes := {
  AbilityType.SHIELD : preload("res://actor/ability/Shield.tscn"),
  AbilityType.ATTRACTOR : preload("res://actor/ability/MassAttractor.tscn"),
  AbilityType.STREAM : preload("res://actor/ability/TimeStream.tscn")
}

var ability_costs := {
  AbilityType.SHIELD : 0,
  AbilityType.ATTRACTOR : 0,
  AbilityType.STREAM : 0
}

var _active_abilities := {
  AbilityType.SHIELD : false,
  AbilityType.ATTRACTOR : false,
  AbilityType.STREAM : false
}

var _total_currency:int = 0

# Flags if the player loaded the attractor for the next shot.
var _is_attractor_selected := false

signal currency_changed(currency)

func _ready():
  var res = Score.connect("scored_target", self, "add_currency_from_score")
  assert(res == OK)

func add_currency_from_score(target_score):
  _total_currency += _typing_score_currency(target_score.typing_score)
  _total_currency += _speed_bonus_currency(target_score.speed_bonus)
  _total_currency += _super_bonus_currency(target_score.super_bonus)
  emit_signal("currency_changed", _total_currency)

func cast_ability(type:int, parameters:Dictionary):
  var cost = ability_costs[type]
  if not is_ability_active(type) and _total_currency >= cost:
    _total_currency -= cost
    emit_signal("currency_changed", _total_currency)

    var ability = _ability_scenes[type].instance()
    ability.connect("tree_exiting", self, "_set_ability_inactive", [type], CONNECT_ONESHOT)
    ability.position = parameters["position"]
    add_child(ability)

    _active_abilities[type] = true
  else:
    Sound.play("Mistype")

func is_ability_active(type:int) -> bool:
  return false if not _active_abilities.has(type) else _active_abilities[type]

func _set_ability_inactive(type:int):
  _active_abilities[type] = false

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
