extends Reference
class_name HitTracker

var _target = null setget ,get_target
var _label = null
var _text = ""
var _hit_cursor:int = 0

func _init(target, label):
  _target = target
  _label = label
  _text = label.display_text.merged_text()

func get_target():
  return _target

func text() -> String:
  return _text

func is_done() -> bool:
  return _hit_cursor >= _text.length()

func remove_label():
  _label.queue_free()

func get_cursor() -> int:
  return _hit_cursor

func hit(letter:String) -> bool:
  if not is_done() and letter == _text[_hit_cursor]:
    _label.increment_cursor()
    _hit_cursor += 1
    return true
  return false
