extends Reference
class_name TextServer

var word_dictionary:WordDictionary
var _rng := RandomNumberGenerator.new()

const A_UNICODE = ord("a")
const Z_UNICODE = ord("z")

var condition := funcref(self, "_pass_always")

func _init():
  _rng.randomize()

func _pass_always(_ignore):
  return true

# Returns a random word from the given specifications.
# If the conditions could not be met, an empty string is returned.
func request_word_with_letter(size:int, letter:String) -> String:
  return pick_word(word_dictionary.words(size, letter)) if condition.call_func(letter) else ""

# Get a word of said size of any letter.
# If the conditions could not be met, an empty string is returned.
func request_word_with_size(size:int) -> String:
  var letter = random_letter()
  # Linearly try each letter to see if a word could be requested if the current letter failed.
  var tries = Z_UNICODE - A_UNICODE
  for _i in tries:
    var word = request_word_with_letter(size, letter)
    if not word.empty():
      return word
    letter = next_letter(letter)
  return ""

# Get a word of any size and letter.
# If the conditions could not be met, an empty string is returned.
func request_word() -> String:
  var size = _rng.randi() % WordDictionary.WordSize.COUNT
  # We subtract one since we already have a random size for the first pass and COUNT
  # Linearly try each size to see if a word could be requested if the current letter failed.
  var tries = WordDictionary.WordSize.COUNT - 1
  for _i in tries:
    var word = request_word_with_size(size)
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
