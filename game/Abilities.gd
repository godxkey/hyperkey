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
  AbilityType.SHIELD : 5,
  AbilityType.ATTRACTOR : 5,
  AbilityType.STREAM : 12
}

const SHIELD_SCENE = preload("res://actor/ability/Shield.tscn")
const STREAM_SCENE = preload("res://actor/ability/TimeStream.tscn")
const ATTRACTOR_SCENE = preload("res://actor/ability/MassAttractor.tscn")

var _total_currency:int = 0

# Flags if the player loaded the attractor for the next shot.
var _is_attractor_loaded := false

signal currency_changed(currency)
signal attractor_ready_changed(enabled)

func _ready():
  var res = Score.connect("scored_target", self, "add_currency_from_score")
  assert(res == OK)

  res = GameEvent.connect("bullet_created", self, "_try_attach_attractor_to_bullet")
  assert(res == OK)

func add_currency_from_score(target_score):
  _total_currency += _typing_score_currency(target_score.typing_score)
  _total_currency += _speed_bonus_currency(target_score.speed_bonus)
  _total_currency += _super_bonus_currency(target_score.super_bonus)
  emit_signal("currency_changed", _total_currency)

func ready_ability(type:int):
  var cost = ability_costs[type]
  if _total_currency >= cost:
    match type:
      # toggle
      AbilityType.ATTRACTOR:
        _is_attractor_loaded = not _is_attractor_loaded
        emit_signal("attractor_ready_changed", _is_attractor_loaded)
  else:
    Sound.play("Mistype")
    match type:
      AbilityType.ATTRACTOR:
        _is_attractor_loaded = false
        emit_signal("attractor_ready_changed", _is_attractor_loaded)

func cast_ability(type:int, parameters:Dictionary):
  var cost = ability_costs[type]
  if _total_currency >= cost:
    _total_currency -= cost
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

func _try_attach_attractor_to_bullet(bullet):
  if _is_attractor_loaded:
    bullet.connect("target_hit", self, "_cast_attractor")
    _is_attractor_loaded = false
    _total_currency -= ability_costs[AbilityType.ATTRACTOR]
    emit_signal("attractor_ready_changed", _is_attractor_loaded)

func _cast_attractor(position:Vector2, _impact_rotation):
    var attractor = ATTRACTOR_SCENE.instance()
    attractor.position = position
    add_child(attractor)

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
