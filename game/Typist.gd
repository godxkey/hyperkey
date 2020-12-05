extends Node

var _text_targets := TextTargets.new()
var _current_tracker:HitTracker = null

signal target_keyhit(target_path)
signal target_acquired(target_path)

func _process(delta):
  if _current_tracker:
    _current_tracker.process(delta)

func _unhandled_input(event):
  if event as InputEventKey and event.is_pressed() and not event.echo:
    if event.scancode >= KEY_A and event.scancode <= KEY_Z:
      var input_letter = char(event.scancode).to_lower()
      _attack_letter(input_letter)

func is_letter_unused(letter:String) -> bool:
  return not _text_targets.has_letter(letter)

func _attack_letter(letter:String):
  if _current_tracker == null:
    var text = _text_targets.text(letter)
    if text != null:
      acquire_target(text)
    else:
      Stats.add_keypress()
      Stats.mistype()
  else:
    continue_hit_target(letter)

func acquire_target(text:String):
  assert(_current_tracker == null)
  var target = _text_targets.target(text)
  _on_target_acquired(target)
  _current_tracker = HitTracker.new(target, target.text())
  Stats.add_keypress()
  var result = _current_tracker.hit(text[0])
  if result.is_hit:
    _on_target_keyhit(target)
    Stats.add_keyhit()

func continue_hit_target(letter:String):
  assert(_current_tracker != null)
  Stats.add_keypress()
  var result = _current_tracker.hit(letter)
  if result.is_hit:
      var target = _current_tracker.get_target()
      _on_target_keyhit(target)
      Stats.add_keyhit()
      if _current_tracker.is_done():
          Stats.set_stats(target, _current_tracker.stats())
          _clear_tracked()
  else:
    Stats.mistype_tracked(letter, _current_tracker.get_target())

func _on_target_keyhit(target):
  target.on_hit()
  emit_signal("target_keyhit", target.get_path())

func _on_target_acquired(target):
  emit_signal("target_acquired", target.get_path() if target else NodePath(""))

# Add a text target. Text targets are game objects the player can type to shoot.
# Will fail if adding a text target with an already used starting letter.
# Empty text is not allowed and will fail.
func add_text_target(text:TypistText, target):
  var merged_text = text.merged_text()
  assert(not merged_text.empty())
  assert(not _text_targets.has_letter(merged_text[0]))
  target.connect(
    "tree_exiting",
    self,
    "_remove_exited_target",
    [merged_text, weakref(target)],
    CONNECT_ONESHOT)
  _text_targets.add_text_target(merged_text, target)

func _remove_target_word(text:String):
  _text_targets.remove_text_target(text)

func _clear_tracked():
  assert(_current_tracker != null)
  _current_tracker.get_target().hide_label()
  _remove_target_word(_current_tracker.text())
  _current_tracker = null
  _on_target_acquired(null)

func _remove_exited_target(text:String, target_wref):
  var target = target_wref.get_ref()
  if _text_targets.target(text) == target:
    if _current_tracker and _current_tracker.text() == text:
      _clear_tracked()
    else:
      _remove_target_word(text)
