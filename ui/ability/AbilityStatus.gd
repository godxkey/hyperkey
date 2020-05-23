extends VBoxContainer

export(int) var display_cost = 10 setget _set_display_cost
export(float) var display_duration = 1.0 setget _set_display_duration

onready var cost := $CostLabel
onready var currency_progress := $CurrencyProgress
onready var duration_progress := find_node("Duration")
onready var texture := find_node("Texture")
onready var not_ready := find_node("NotReady")

const READY_ALPHA:float = 1.0
const NOT_READY_ALPHA:float = 0.4

var tracked_ability_timer := WeakRef.new() setget _set_tracked_ability_timer

func _ready():
  currency_progress.value = 0
  duration_progress.value = 0.0
  texture.modulate.a = NOT_READY_ALPHA

func _process(_delta):
  var timer = tracked_ability_timer.get_ref()
  if timer:
    set_time_left(timer.time_left)

func set_time_left(time:float):
  duration_progress.value = time

func set_currency(currency:int):
  currency_progress.value = currency
  _set_ready_status()

func _set_tracked_ability_timer(value):
  tracked_ability_timer = weakref(value)

func _set_display_duration(time:float):
  duration_progress.max_value = time

func _set_ready_status():
  var is_ready:bool = currency_progress.max_value <= currency_progress.value
  not_ready.visible = not is_ready
  texture.modulate.a = READY_ALPHA if is_ready  else NOT_READY_ALPHA

func _set_display_cost(value:int):
  display_cost = value
  cost.text = String(value)
  currency_progress.max_value = value
  _set_ready_status()
