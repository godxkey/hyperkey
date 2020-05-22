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

const SHIELD_SCENE = preload("res://actor/ability/Shield.tscn")
const STREAM_SCENE = preload("res://actor/ability/TimeStream.tscn")
const ATTRACTOR_SCENE = preload("res://actor/ability/MassAttractor.tscn")

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
    _active_abilities[type] = true
    emit_signal("currency_changed", _total_currency)
    var ability = ability_scene(type).instance()
    ability.connect("tree_exiting", self, "_set_ability_inactive", [type], CONNECT_ONESHOT)
    ability.position = parameters["position"]
    add_child(ability)
  else:
    Sound.play("Mistype")

func ability_scene(type:int) -> PackedScene:
  match type:
    AbilityType.SHIELD:
      return SHIELD_SCENE
    AbilityType.STREAM:
      return STREAM_SCENE
    AbilityType.ATTRACTOR:
      return ATTRACTOR_SCENE
  return null

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
