extends Node

var _total_keypresses:int = 0
var _total_keyhits:int = 0
var _max_key_history:int = 100

var _typing_streak:int = 0
var _active_stats = {}
var _last_streak:int = 0
var _streak_high:int = 0

signal key_missed
signal key_missed_tracked(letter, position)
signal streak_changed(streak)
signal accuracy_changed(accuracy)

func get_last_streak() -> int:
  return _last_streak

func get_streak_high() -> int:
  return _streak_high

func add_keypress():
  _total_keypresses += 1
  emit_signal("accuracy_changed", accuracy())

func add_keyhit():
  _total_keyhits += 1
  _typing_streak += 1
  _streak_high = max(_streak_high, _typing_streak) as int
  emit_signal("streak_changed", _typing_streak)
  emit_signal("accuracy_changed", accuracy())
  _shift_down_keyhit_stats()

func mistype():
  _last_streak = _typing_streak
  _typing_streak = 0
  Sound.play("Mistype")
  emit_signal("key_missed")
  emit_signal("streak_changed", _typing_streak)

func mistype_tracked(letter:String, target):
  mistype()
  emit_signal("key_missed_tracked", letter, _screen_location(target))

func set_stats(target, stat):
  _active_stats[target] = stat
  target.connect("tree_exiting", self, "clear_stats", [weakref(target)], CONNECT_ONESHOT)

  var health = target.get_node("Health")
  health.connect("no_health", self, "_show_target_score", [weakref(target)], CONNECT_ONESHOT)

func clear_stats(target_wref):
  var target = target_wref.get_ref()
  if target:
    _active_stats.erase(target)

# Reduces key hit stats so players can regain higher accuracy.
# If we keep absolute stats, then after many, many key presses,
# it will would take an enternity to reach high accuracy again.
func _shift_down_keyhit_stats():
  if _total_keyhits >= _max_key_history:
    _total_keyhits /= 2
    _total_keypresses /= 2

func _show_target_score(target_wref):
  var target = target_wref.get_ref()
  if target:
    var stats = _active_stats[target]
    _active_stats.erase(target)
    Score.update_score(stats, _screen_location(target))

func accuracy() -> int:
  return ((_total_keyhits / _total_keypresses as float) * 100) as int

func _screen_location(target:Spatial) -> Vector2:
  var camera = get_viewport().get_camera()
  return camera.unproject_position(target.global_transform.origin) if camera else Vector2.ZERO
