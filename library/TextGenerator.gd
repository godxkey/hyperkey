extends Node

onready var text_server = $TextServer

func random_text() -> TypistText:
  var chance = randf() < 0.9
  var words = [random_word()] + ([] if chance else random_words())
  var t = TypistText.new()
  t.text_list = words
  return t

func random_word() -> String:
  return text_server.request_word_in_language(WordDictionary.LangType.ENGLISH)

func random_words() -> Array:
  var words = []
  var count = (randi() % 2) + 1
  for _i in count:
    var word = text_server.request_word_in_language(WordDictionary.LangType.ENGLISH, TextServer.ConditionType.NONE)
    words.append(word)
  return words
