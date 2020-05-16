extends Node

onready var text_server = $TextServer

# Generates random text for available letters.
# If conditions could not be met, null is returned.
func random_text() -> TypistText:
  var chance = randf() < 0.9

  var first_word = random_word()
  if first_word.empty():
    return null

  var words = [first_word] + ([] if chance else random_words())
  var t = TypistText.new()
  t.text_list = words
  return t

# Generates random text for available letters.
# If conditions could not be met, an empty string is returned.
func random_word() -> String:
  return text_server.request_word_in_language(WordDictionary.LangType.ENGLISH)

# Generates random text without any conditions.
# Result may be an empty Array if words could not be obtained. e.g. empty word dictionaries
func random_words() -> Array:
  var words = []
  var count = (randi() % 2) + 1
  for _i in count:
    var word = text_server.request_word_in_language(
      WordDictionary.LangType.ENGLISH,
      TextServer.ConditionType.NONE)
    if not word.empty():
      words.append(word)
  return words

func random_sized_word_list(sizes:Array, count) -> TypistText:
  var word_list = []
  for _i in count:
    var size = sizes[randi() % sizes.size()]
    var word = text_server.request_word_with_size(WordDictionary.LangType.ENGLISH, size)
    if word:
      word_list.append(word)
  if not word_list.empty():
    var t = TypistText.new()
    t.text_list = word_list
    return t
  return null
