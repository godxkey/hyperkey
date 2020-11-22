extends Node
class_name WordDictionary

export(String, FILE, "*.txt") var english_words_file

# Specialized dictionary that stores list of words by language, size, and first letter
# [english] -> [medium] -> [a] -> [alpha, actually, attack]

enum LangType{ENGLISH, SPANISH, COUNT}
enum WordSize{TINY, SHORT, MEDIUM, LONG, COUNT}

# Stores the word sized maps for a language
var _language_dictionaries = {}

# Organizes words by letter and length.
class WordSizedMaps:
  func _init(all_words:Array):
    for w in all_words:
      var size = word_size(w)
      var dict = word_dict(size)
      _add_word(dict, w)

  var tiny_words = {}
  var short_words = {}
  var medium_words = {}
  var long_words = {}

  static func _add_word(dict, word:String):
    var first_letter = word[0]
    var word_list = dict.get(first_letter)
    if word_list == null:
      dict[first_letter] = [word]
    else:
      word_list.append(word)

  static func word_size(word:String) -> int:
      match word.length():
        1, 2:
          return WordSize.TINY
        3, 4:
          return WordSize.SHORT
        5, 6, 7:
          return WordSize.MEDIUM
        _:
          return WordSize.LONG

  func word_dict(size:int) -> Dictionary:
    match size:
      WordSize.TINY:
        return tiny_words
      WordSize.SHORT:
        return short_words
      WordSize.MEDIUM:
        return medium_words
      _:
        return long_words

func _ready():
  if not english_words_file.empty():
    read_dictionary(LangType.ENGLISH, english_words_file)

# Dictionaries are assumed to be unique.
# NOTE: To make things straightforward and fast, the input dictionary is curated beforehand.
func read_dictionary(language, words_file:String):
  var file = File.new()
  file.open(words_file, File.READ)
  assert(file.is_open())
  var words = []
  while not file.eof_reached():
    var line = file.get_line()
    if not line.empty():
      words.append(line)
  file.close()
  _language_dictionaries[language] = WordSizedMaps.new(words)

# Return the list of words given the input specification.
# If no such list exits, return an empty array
func words(language:int, size:int, letter:String) -> Array:
  var lang_words = _language_dictionaries.get(language)
  if lang_words:
    var words_for_letter = lang_words.word_dict(size).get(letter)
    if words_for_letter:
      return words_for_letter
  return []