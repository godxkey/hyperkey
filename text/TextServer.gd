extends Node
class_name TextServer

export var _word_dictionary:Resource

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
func request_word_with_letter(
  size:int,
  letter:String,
  condition:int = ConditionType.UNUSED_LETTER) -> String:

  match condition:
    ConditionType.NONE:
      return pick_word(_word_dictionary.words(size, letter))
    ConditionType.UNUSED_LETTER:
      if unused_letter_condition.call_func(letter):
        return pick_word(_word_dictionary.words(size, letter))
  return ""

# Get a word of said size of any letter.
# If the conditions could not be met, an empty string is returned.
func request_word_with_size(
  size:int,
  condition:int = ConditionType.UNUSED_LETTER) -> String:

  var letter = random_letter()
  # Linearly try each letter to see if a word could be requested if the current letter failed.
  var tries = Z_UNICODE - A_UNICODE
  for _i in tries:
    var word = request_word_with_letter(size, letter, condition)
    if not word.empty():
      return word
    letter = next_letter(letter)
  return ""

# Get a word of any size and letter.
# If the conditions could not be met, an empty string is returned.
func request_word(condition:int = ConditionType.UNUSED_LETTER) -> String:
  var size = _rng.randi() % WordDictionary.WordSize.COUNT
  # We subtract one since we already have a random size for the first pass and COUNT
  # Linearly try each size to see if a word could be requested if the current letter failed.
  var tries = WordDictionary.WordSize.COUNT - 1
  for _i in tries:
    var word = request_word_with_size(size, condition)
    if not word.empty():
      return word
    size = next_size(size)
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
