extends Reference
class_name TypistText

var _merged_text := String()
var text_list := Array() setget _set_text_list

func _init(texts := []):
  text_list = texts

func _set_text_list(value):
  text_list = value
  _merged_text = ""
  for t in text_list:
    _merged_text += t

func merged_text():
  return _merged_text

