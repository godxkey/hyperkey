extends RichTextLabel
class_name TypistLabel

var display_text := TypistText.new() setget _set_display_text

var cursor:int = -1 setget set_cursor, get_cursor

var _typist_effect = preload("res://ui/TypistEffect.gd").new()

func _init():
  # This makes sure the effect is unique per label
  install_effect(_typist_effect)

func increment_cursor():
  set_cursor(cursor + 1)

func reset_cursor():
  set_cursor(-1)

func _set_display_text(value:TypistText):
  display_text = value
  clear()
  reset_cursor()
  push_align(ALIGN_CENTER)
  append_bbcode("[typist]")

  if display_text.text_list.size() == 1:
    add_text(display_text.merged_text())
  else:
    for text in display_text.text_list:
      add_text(text)
      newline()

  fit_to_text()
  _typist_effect.newline_indices = newline_indices(display_text.text_list)

func get_cursor() -> int:
  return cursor

func set_cursor(index:int):
  cursor = clamp(index, -1, display_text.merged_text().length()) as int
  _typist_effect.cursor = cursor

func fit_to_text():
  var word_size:Vector2 = max_extents(display_text.text_list)
  word_size.x *= 1.4
  set_size(word_size)
  rect_position.x = -word_size.x / 2

func max_extents(words:Array) -> Vector2:
  var sizes = word_sizes(words)
  var widths = Array()
  var sum_height = 0
  for s in sizes:
    widths.append(s.x)
    sum_height += s.y
  return Vector2(widths.max(), sum_height)

func word_size(word:String) -> Vector2:
  return get("custom_fonts/normal_font").get_string_size(word)

func word_sizes(words:Array) -> Array:
  var sizes = Array()
  for w in words:
    sizes.append(word_size(w))
  return sizes

func newline_indices(words:Array) -> Array:
  var indices = []
  var sum = 0
  for w in words:
    var length = w.length()
    indices.append(sum + length)
    sum += length
  return indices


