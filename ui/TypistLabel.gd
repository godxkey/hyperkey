extends RichTextLabel

var raw_text := String() setget set_raw_text

var cursor:int = -1 setget set_cursor, get_cursor

# This makes sure the effect is unique per label
var _typist_effect = preload("res://ui/TypistEffect.gd").new()

func _ready():
  install_effect(_typist_effect)

func increment_cursor():
  set_cursor(cursor + 1)

func reset_cursor():
  set_cursor(-1)

func set_raw_text(text:String):
  raw_text = text
  clear()
  reset_cursor()
  push_align(ALIGN_CENTER)
  append_bbcode("[typist]")
  add_text(text)

func get_cursor() -> int:
  return cursor

func set_cursor(index:int):
  cursor = clamp(index, -1, raw_text.length()) as int
  _typist_effect.cursor = cursor
