extends Reference
class_name HitTracker

class HitResult:
  var is_hit := false
  var hit_completed_word := false

var _target = null setget ,get_target
var _label = null
var _text = ""

# The global cursor for the entire text.
var _hit_cursor:int = 0

# Keeps of the currently tracked word
var _current_word_index:int = 0

# Keeps track of the local cursor of the current word.
var _current_word_cursor:int = 0

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

func hit(letter:String) -> HitResult:
  var result = HitResult.new()
  if not is_done() and letter == _text[_hit_cursor]:
    _label.increment_cursor()
    _hit_cursor += 1
    _current_word_cursor += 1
    result.is_hit = true
    result.hit_completed_word = _track_word_completed()
  return result

# Returns true if the current cursor completed a word in the text.
func _track_word_completed() -> bool:
  if _current_word_index < _word_count():
    if _current_word_cursor == _current_word().length():
      _current_word_index += 1 # Next word
      _current_word_cursor = 0 # Reset cursor for next word
      return true
  return false

func _word_count() -> int:
  return _label.display_text.text_list.size()

func _current_word() -> String:
  return _label.display_text.text_list[_current_word_index]
