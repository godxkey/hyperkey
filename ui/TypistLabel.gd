extends RichTextLabel
class_name TypistLabel

var word_text = "" setget _set_word_text

var cursor:int = -1 setget set_cursor, get_cursor

var _typist_effect = preload("res://ui/TypistEffect.gd").new()

func _init():
  # This makes sure the effect is unique per label
  install_effect(_typist_effect)

func increment_cursor():
  set_cursor(cursor + 1)

func reset_cursor():
  set_cursor(-1)

func _set_word_text(value:String):
  word_text = value
  clear()
  reset_cursor()
  push_align(ALIGN_CENTER)
  append_bbcode("[typist]")
  add_text(value)
  fit_to_word()

func get_cursor() -> int:
  return cursor

func set_cursor(index:int):
  cursor = clamp(index, -1, word_text.length()) as int
  _typist_effect.cursor = cursor

func fit_to_word():
  var word_size = get("custom_fonts/normal_font").get_string_size(word_text)
  word_size.x *= 1.4
  set_size(word_size)
  rect_position.x = -word_size.x / 2

