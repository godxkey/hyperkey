extends Node

export(String, FILE, "*.txt") var words_file
export(NodePath) var projectile_manager_path
export(NodePath) var player_path

onready var _player = get_node(player_path)
onready var _projectile_manager = get_node(projectile_manager_path)
onready var _spawner = $Spawner as Spawner
onready var _mistype_player = $MistypePlayer

var _text_targets := TextTargets.new()
var _text_generator := TextGenerator.new()
var _current_tracker:HitTracker = null

func create_tracker(target) -> HitTracker:
  var label = target.find_node("TypistLabel", true, false)
  return HitTracker.new(target, label)

# Called when the node enters the scene tree for the first time.
func _ready():
  _text_generator.word_dictionary = WordDictionary.new(words_file)
  _spawner.timer.connect("timeout", self, "spawn_target")
  _spawner.timer.start()

func available_first_letter() -> String:
  var max_tries = 100
  for _try in max_tries:
    var letter = _text_generator.random_letter()
    if not _text_targets.has_letter(letter):
      return letter
  return ""

func _input(event):
  if event as InputEventKey and event.is_pressed() and not event.echo:
    if event.scancode >= KEY_A and event.scancode <= KEY_Z:
      var input_letter = char(event.scancode).to_lower()
      _attack_letter(input_letter)

func _attack_letter(letter:String):
  if _current_tracker == null:
    var text = _text_targets.text(letter)
    if text != null:
      acquire_target(text)
    else:
      _mistype_player.play()
  else:
    continue_hit_target(letter)

func acquire_target(text:String):
  assert(_current_tracker == null)
  var target = _text_targets.target(text)
  _player.aimed_target = target
  _current_tracker = create_tracker(target)
  if _current_tracker.hit(text[0]):
    spawn_bullet(target)

func continue_hit_target(letter:String):
  assert(_current_tracker != null)
  if _current_tracker.hit(letter):
      spawn_bullet(_current_tracker.get_target())
      if _current_tracker.is_done():
          clear_tracked()
  else:
    _mistype_player.play()

func spawn_bullet(target):
  var bullet = _projectile_manager.spawn_projectile(_player.position, target)
  target.connect("tree_exiting", bullet, "queue_free")

func create_target(text:TypistText) -> Node2D:
  var target = _spawner.spawn_text_target(text)
  target.connect(
    "tree_exiting",
    self,
    "remove_exited_target",
    [text.merged_text(), weakref(target)],
    CONNECT_ONESHOT)
  add_child(target)
  return target

func spawn_target():
  var letter = available_first_letter()
  if not letter.empty():
    var text:TypistText = _text_generator.random_text(letter)
    _text_targets.add_text_target(text.merged_text(), create_target(text))

func remove_target_word(text:String):
  _text_targets.remove_text_target(text)

func clear_tracked():
  assert(_current_tracker != null)
  remove_target_word(_current_tracker.text())
  _current_tracker.remove_label()
  _current_tracker = null
  _player.aimed_target = null

func remove_exited_target(text:String, target_wref):
  if _text_targets.target(text) == target_wref.get_ref():
    if _current_tracker and _current_tracker.text() == text:
      clear_tracked()
    else:
      remove_target_word(text)
