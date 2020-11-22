extends Node

onready var text_server = $TextServer

var _history := History.new()

# Use a history to prevent generating the same word too frequently.
var enable_history = true

func random_sized_word_list(sizes:PoolIntArray, count) -> TypistText:
  var word_list = []
  for _i in count:
    var size = sizes[randi() % sizes.size()]
    var word = _request_word(size)
    if word:
      word_list.append(word)
  if not word_list.empty():
    var t = TypistText.new()
    t.text_list = word_list
    return t
  return null

func _request_word(size:int) -> TypistText:
  # Only use history for medium, and long words
  # The word pool for tiny and short words is too small for history.
  if enable_history and _is_medium_or_longer_size(size):
    var tries:int = 100
    for _i in tries:
      var word = text_server.request_word_with_size(size)
      if not _history.has(word):
        _history.add(word)
        return word
    return null
  else:
    return text_server.request_word_with_size(size)

func _is_medium_or_longer_size(size:int) -> bool:
  return size != WordDictionary.WordSize.TINY and size != WordDictionary.WordSize.SHORT
