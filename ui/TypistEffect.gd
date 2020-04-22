extends RichTextEffect

var bbcode = "typist"

var cursor = 0 setget _set_cursor

var unfocus_color = Color.azure
var focus_color = Color.aquamarine
var done_color = Color.slategray
var current_word_color = Color.sandybrown
var other_word_color = Color.gray

# The indices for the end of each word.
var newline_indices = []

# Caches the current newline index to avoid recalculating every frame.
var _current_word_end = 0

func _process_custom_fx(char_fx):
  # No cursor, show as unfocused
  if cursor == -1:
    char_fx.color = unfocus_color
    return true

  var index = char_fx.absolute_index

  # Next to cursor, highlight to show focus
  if index == focus():
    char_fx.color = focus_color
    return true

  # Before cursor, grey out as "done"
  if index < focus():
    char_fx.color = done_color
    return true

  # Remaining characters after cursor.
  if is_character_in_current_word(index):
    char_fx.color = current_word_color
  else:
    char_fx.color = other_word_color
  return true

func _set_cursor(value):
  cursor = value
  _current_word_end = _current_newline_index()

# The currently focused letter index
func focus() -> int:
  return cursor + 1

# If the focus is less than the newline index, then that is the current word end index.
func _current_newline_index() -> int:
  for i in newline_indices:
    if focus() < i:
      return i
  return 0

func is_character_in_current_word(index:int) -> bool:
  return index < _current_word_end
