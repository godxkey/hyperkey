extends Reference
class_name WordDictionary

# Specialized dictionary that stores list of words by first letter
# [a] -> [alpha, actually, attack]
# ...
# [z] -> [zeta, zoo, zebra]

# Organizes words by letter.
var _alpha_map = {}

func read_dictionary(words_file:String):
  var file = File.new()
  file.open(words_file, File.READ)
  assert(file.is_open())
  _alpha_map.clear()

  var min_word_length = 4
  while not file.eof_reached():
    var line = file.get_line()
    if line.length() >= min_word_length:
      _add_to_alpha_map(line)
  file.close()

func _add_to_alpha_map(word:String):
  var first_letter = word[0]
  var word_list = _alpha_map.get(first_letter)
  if word_list == null:
    _alpha_map[first_letter] = [word]
  else:
    word_list.append(word)

func words(letter:String) -> Array:
  return _alpha_map[letter]

