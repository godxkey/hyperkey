extends RichTextEffect

var bbcode = "typist"

var cursor = 0

func _process_custom_fx(char_fx):
  if cursor == -1:
    char_fx.color = Color.white
    return true
  var index = char_fx.absolute_index
  if index <= cursor:
    char_fx.color = Color.gray
  elif index > cursor + 1:
    char_fx.color = Color.yellow
  else:
    char_fx.color = Color.orange
  return true