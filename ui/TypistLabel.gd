extends RichTextLabel
class_name TypistLabel

var display_text := TypistText.new() setget _set_display_text
var cursor:int = -1 setget set_cursor, get_cursor

var _typist_effect = preload("res://ui/TypistEffect.gd").new()
var _default_font:Font = get("custom_fonts/normal_font")
var _width_adjust:float = 1.4
var _height_adjust:float = 4.0

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
  var line_size = max_extents(display_text.text_list)
  line_size.x *= _width_adjust
  line_size.y += _height_adjust
  set_size(line_size)
  rect_position.x = -line_size.x / 2

func max_extents(lines:Array) -> Vector2:
  var sizes = line_sizes(lines)
  var widths = []
  var sum_height = 0
  for s in sizes:
    widths.append(s.x)
    sum_height += s.y
  return Vector2(widths.max(), sum_height)

func line_size(line:String) -> Vector2:
  return _default_font.get_string_size(line)

func line_sizes(lines:Array) -> Array:
  var sizes = []
  for ln in lines:
    sizes.append(line_size(ln))
  return sizes

func newline_indices(words:Array) -> Array:
  var indices = []
  var sum = 0
  for w in words:
    var length = w.length()
    indices.append(sum + length)
    sum += length
  return indices