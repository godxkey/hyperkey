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
  if _total_currency >= cost:
    _total_currency -= cost
    emit_signal("currency_changed", _total_currency)
    match type:
      AbilityType.SHIELD:
        var shield = SHIELD_SCENE.instance()
        shield.position = parameters["position"]
        add_child(shield)
      AbilityType.STREAM:
        var stream = STREAM_SCENE.instance()
        stream.position = parameters["position"]
        add_child(stream)
      AbilityType.ATTRACTOR:
        var attractor = ATTRACTOR_SCENE.instance()
        attractor.position = parameters["position"]
        add_child(attractor)
  else:
    Sound.play("Mistype")

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
