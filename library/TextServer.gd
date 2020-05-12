extends Node
class_name TextServer

onready var _word_dictionary = $WordDictionary

var _rng := RandomNumberGenerator.new()

const A_UNICODE = ord("a")
const Z_UNICODE = ord("z")

enum ConditionType{NONE, UNUSED_LETTER}

# Delegate to test if a letter is not used.
var unused_letter_condition:FuncRef = funcref(self, "default_unused_letter_condition")

func _init():
  _rng.randomize()

func default_unused_letter_condition(_letter:String) -> bool:
  return true

# Returns a random word from the given specifications.
# If the conditions could not be met, an empty string is returned.
func request_word_with_letter(language:int, size:int, letter:String, condition:int = ConditionType.UNUSED_LETTER) -> String:
  match condition:
    ConditionType.NONE:
      return pick_word(_word_dictionary.words(language, size, letter))
    ConditionType.UNUSED_LETTER:
      if unused_letter_condition.call_func(letter):
        return pick_word(_word_dictionary.words(language, size, letter))
  return ""

# Get a word in the language of said size of any letter.
# If the conditions could not be met, an empty string is returned.
func request_word_with_size(language:int, size:int, condition:int = ConditionType.UNUSED_LETTER) -> String:
  var letter = random_letter()
  # We subtract one since we already have a random letter for the first pass.
  # Linearly try each letter to see if a word could be requested if the current letter failed.
  var tries = Z_UNICODE - A_UNICODE - 1
  for _i in tries:
    var word = request_word_with_letter(language, size, letter, condition)
    if not word.empty():
      return word
    letter = next_letter(letter)
  return ""

# Get a word in the language of any size and letter.
# If the conditions could not be met, an empty string is returned.
func request_word_in_language(language:int, condition:int = ConditionType.UNUSED_LETTER) -> String:
  var size = _rng.randi() % WordDictionary.WordSize.COUNT
  # We subtract one since we already have a random size for the first pass and COUNT
  # Linearly try each size to see if a word could be requested if the current letter failed.
  var tries = WordDictionary.WordSize.COUNT - 1
  for _i in tries:
    var word = request_word_with_size(language, size, condition)
    if not word.empty():
      return word
    size = next_size(size)
  return ""

# Get any word from any language and of any size
# If the conditions could not be met, an empty string is returned.
func request_word(condition:int = ConditionType.UNUSED_LETTER) -> String:
  var lang = _rng.randi() % WordDictionary.LangType.COUNT
  var tries = WordDictionary.LangType.COUNT - 1
  for _i in tries:
    var word = request_word_in_language(lang, condition)
    if not word.empty():
      return word
    lang = next_lang(lang)
  return ""

# Uniformly select a word at random.
func pick_word(words:Array) -> String:
  return "" if words.empty() else words[_rng.randi() % words.size()]

# Uniformly select a letter at random.
func random_letter() -> String:
  return char(_rng.randi_range(A_UNICODE, Z_UNICODE))

# Goes to the next letter and wrap around z to a.
func next_letter(letter:String) -> String:
  var next = ord(letter) + 1
  return char(wrapi(next, A_UNICODE, Z_UNICODE + 1))

func next_size(size:int) -> int:
  return (size + 1) % WordDictionary.WordSize.COUNT

func next_lang(lang:int):
  return (lang + 1) % WordDictionary.LangType.COUNT
