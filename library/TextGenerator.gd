extends Reference
class_name TextGenerator

enum SelectionMode{
  UNIFORM,        # All letters have the same probability to be selected
  QUANTITY_BIAS   # Letters with more words associated have a higher chance to be selected
}

var word_dictionary := WordDictionary.new() setget _set_word_dictionary
var selection_mode = SelectionMode.UNIFORM setget _set_selection_mode

var _rng := RandomNumberGenerator.new()
var _letter_weights = {}

func _init():
  _rng.randomize()

func random_text(first_letter:String) -> TypistText:
  var chance:float = _rng.randf() < 0.8
  var words:Array= [random_word(first_letter)] + ([] if chance else random_words())
  var t = TypistText.new()
  t.text_list = words
  return t

func random_word(first_letter:String) -> String:
  var words = word_dictionary.words(first_letter)
  assert(words)
  var index = _rng.randi_range(0, words.size() - 1)
  return words[index]

func random_words() -> Array:
  var words = []
  for _i in _rng.randi_range(1, 3):
    words.append(random_word(random_letter()))
  return words

func random_letter() -> String:
  if selection_mode == SelectionMode.QUANTITY_BIAS:
    return ""

  # Uniform selection
  return char(_rng.randi_range(ord("a"), ord("z")))

func _set_word_dictionary(value):
  word_dictionary = value
  _set_letter_weights()

func _set_selection_mode(value):
  selection_mode = value
  _set_letter_weights()

func _set_letter_weights():
  if selection_mode == SelectionMode.QUANTITY_BIAS:
    _set_quantity_weights()

static func alphabet_range():
  return range(ord("a"), ord("z"))

func _set_quantity_weights():
  _letter_weights.clear()
  for a in alphabet_range():
    var letter = char(a)
    var count = word_dictionary.words(letter).size()
    var total = word_dictionary.count_total_words()
    _letter_weights[letter] = count / total # TODO: Implement a proper bias
