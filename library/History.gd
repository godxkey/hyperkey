extends Reference

var max_history = 10 setget _set_max_history
var _history := []

func add(item):
  var index:int = _history.find(item)

  # Remove old entry of item
  if index != -1:
    _history.remove(index)

  _history.push_back(item)

  # Remove front if excess
  if _history.size() > max_history:
    _history.pop_front()


func has(item) -> bool:
  return _history.has(item)

func clear():
  _history.clear()

func _set_max_history(value):
  max_history = value
  # Truncate history
  if _history.size() > max_history:
    _history.resize(max_history)

