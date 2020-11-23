extends Reference

class_name TextTargets

# A specialized dictionary that associates a text label with a target object

# Maps a text to a target.
var _text_targets = {}

# Maps letter to a text.
# The letter is the first letter of the text.
# The texts are the keys in _text_targets
# This makes it possible to indirectly map from a letter to a target
# e.g. [a] -> [alpha] -> [target]
var _letter_to_text = {}

func add_text_target(text:String, target):
  _letter_to_text[text[0]] = text
  _text_targets[text] = target
  assert(_letter_to_text.size() == _text_targets.size())

func remove_text_target(text:String):
  if _text_targets.has(text):
    _letter_to_text.erase(text[0])
    _text_targets.erase(text)
    assert(_letter_to_text.size() == _text_targets.size())

func target_with_letter(letter:String) -> Object:
  return target(text(letter))

func target(text:String) -> Object:
  return _text_targets.get(text)

func text(letter:String) -> String:
  return _letter_to_text.get(letter)

func has_letter(letter:String) -> bool:
  return _letter_to_text.has(letter)

func has_word(word:String) -> bool:
  return _text_targets.has(word)


